using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Options;
using System.Diagnostics;
using System.Reflection.Metadata;
using XRefGenerator;

namespace VasmBuilder;

public class VasmWorker(string[] args, IOptions<BuildSettings> config, IHostApplicationLifetime lifetime) : BackgroundService
{
    private readonly string filetoBuild = Path.Combine(args[1], args[0]);
    private readonly BuildSettings settings = config.Value;
    private readonly IHostApplicationLifetime lifetime = lifetime;

    private string SymFile => Path.Combine(Path.GetDirectoryName(filetoBuild), Path.GetFileNameWithoutExtension(filetoBuild) + ".sym");
    private string ObjFile => Path.Combine(Path.GetDirectoryName(filetoBuild), Path.GetFileNameWithoutExtension(filetoBuild) + ".o");


    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        try
        {

            Console.WriteLine("Generating macro include file");
            GenerateMacroIncludeFile();

            Console.WriteLine($"Building {filetoBuild}");
            await Build();

            Console.WriteLine("Cleaning symbolfile");
            BeautifySym();

            if (filetoBuild.EndsWith(".as"))
            {
                Console.WriteLine("Linking");
                await Link();

                Console.WriteLine("Converting symbols.sym file to vasm format");
                ConvertLinkSymbol();

                Console.Write($"Moving binary to {settings.DestFolder}\\");
                CopyToOutput();
            }
        } 
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.Error.WriteLine(ex.Message);
            Console.ResetColor();
        }

        lifetime.StopApplication();
    }

    public void ConvertLinkSymbol()
    {
        string file = Path.Combine(settings.OutFolder, "symbols.sym");
        string[] strings = File.ReadAllLines(file);
        File.Delete(file);

        using var writer = new StreamWriter(file);
        writer.WriteLine("sections:");
        bool inSections = false;
        int sectionCount = 0;
        for (int i = 0; i < strings.Length; i++)
        {
            if (inSections && strings[i].StartsWith("  0000"))
            {
                var parts = strings[i].Trim().Split([" ", "(size ", ")", ","], StringSplitOptions.RemoveEmptyEntries);
                int start = int.Parse(parts[0], System.Globalization.NumberStyles.HexNumber);
                int size = int.Parse(parts[2], System.Globalization.NumberStyles.HexNumber);
                writer.WriteLine($"{sectionCount:D2}: \"{parts[1]}\" ({(start & 0xFFFF):X4}-{((start & 0xFFFF) + size):X4})");
                sectionCount++;
                continue;
            }
            if (strings[i].StartsWith("Section mapping"))
            {
                inSections = true;
                continue;
            }
            if (inSections && strings[i].Trim() == "")
            {
                inSections = false;
                writer.WriteLine();
                writer.WriteLine("Symbols by value:");
                continue;
            }

            if (strings[i].Trim().StartsWith("0x"))
            {
                var parts = strings[i].Trim().Split([" ", "0x", ":"], StringSplitOptions.RemoveEmptyEntries);
                writer.WriteLine($"    {parts[0][^4..]} {parts[1]}");
            }
        }
    }

    public void GenerateMacroIncludeFile()
    {
        File.Delete(settings.MacroFile);
        var root = new DirectoryInfo(settings.MacroRootFolder);
        var macroFiles = root.GetFiles("*.asm", SearchOption.AllDirectories);
        
        var handle = File.CreateText(settings.MacroFile);
        foreach (var file in macroFiles)
        {
            handle.WriteLine($"    .include \"{file.Name}\"");
        }
        handle.Close();
    }

    public List<string> GetObjectFiles()
    {
        var includefolders = settings.IncludeFolders;
        var dir = Path.GetDirectoryName(filetoBuild);
        if (dir != null)
        {
            includefolders.Add(dir);
        }

        // find all included files (recursively) and add them to the list of files to process
        List<string> allfiles = [];
        allfiles.Add(filetoBuild);   // add the main file to the list of files to process
        allfiles = allfiles.Concat(XrefHelper.FindIncludes(filetoBuild, includefolders)).Distinct().ToList();
        var ofileLabels = XrefHelper.MakeGlobalList(includefolders);

        List<string> allOFiles = [];
        while (allfiles.Count > 0)
        {
            var oFiles = XrefHelper.GetAllOFiles(allfiles, ofileLabels);

            allfiles = oFiles
                .Where(ofile => !allOFiles.Contains(ofile))
                .Select(ofile => Directory.GetFiles(Path.GetDirectoryName(ofile) ?? "", Path.GetFileNameWithoutExtension(ofile) + ".as?", SearchOption.AllDirectories).FirstOrDefault() ?? "")
                .Where(s => !string.IsNullOrEmpty(s))
                .ToList();

            allOFiles.AddRange(oFiles);
        }

        return allOFiles.Distinct().ToList();
    }

    public async Task Build()
    {
        // generate the include string for the vasm command
        string inc = settings.IncludeFolders
            .Select(folder => $"-I\"{folder}\"")
            .Aggregate((a, b) => $"{a} {b}");

        // BUILD
        var startInfo = new ProcessStartInfo
        {
            FileName = settings.Vasm, 
            Arguments = $"{filetoBuild} -Fvobj -nocase -chklabels -L {SymFile} -o {ObjFile} {inc}",
            RedirectStandardOutput = true, 
            RedirectStandardError = true,  
            UseShellExecute = false,   
            CreateNoWindow = true, 
            WorkingDirectory = Path.GetDirectoryName(settings.Vasm)
        };

        using Process process = new Process { StartInfo = startInfo };
        process.Start();

        string output = await process.StandardOutput.ReadToEndAsync();
        string error = await process.StandardError.ReadToEndAsync();
        await process.WaitForExitAsync();

        // hier kunnen we misschien iets slims mee.
        //if (!string.IsNullOrEmpty(output)) { Console.WriteLine(output); }
        if (!string.IsNullOrEmpty(error))
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.Error.WriteLine(error);
            Console.ResetColor();
        }
    }

    public void BeautifySym()
    {
        var lines = File.ReadAllLines(SymFile);

        using var writer = new StreamWriter(SymFile);
        foreach (var line in lines)
        {
            if (line.Contains(";;"))
            {
                continue;   // skip the double-semicolon lines, which are "rich"-comments in the symparser format
            }
            if (line.StartsWith("Source:"))
            {
                continue;   // skip Source file lines, which are not needed in the output
            }
            if (line.Contains("include"))
            {
                continue;   // file includes not needed to show
            }
            if (string.IsNullOrWhiteSpace(line))
            {
                continue;   // empty line: no info
            }

            writer.WriteLine(line);
        }
    }

    public async Task Link()
    {
        var objectFiles = GetObjectFiles();
        var startAddress = XrefHelper.FindStartAddress(filetoBuild);
    
        var path = Path.GetDirectoryName(filetoBuild) ?? "";
        var binfile = Path.GetFileNameWithoutExtension(filetoBuild) + ".bin";
        var binpath = Path.Combine(path, binfile);

        var args = $"-M{settings.OutFolder}\\symbols.sym -b rawbin -Ttext {startAddress} -o {binpath} ";

        // make sure the .o file for the main file is included as first one in the list of .o files to link
        var opath = Path.Combine(Path.GetDirectoryName(filetoBuild) ?? "", Path.GetFileNameWithoutExtension(filetoBuild) + ".o");
        args += opath + " ";
        args += string.Join(' ', objectFiles.Where(ofile => ofile != opath));


        // LINK
        var startInfo = new ProcessStartInfo
        {
            FileName = settings.Vlink,
            Arguments = args,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true,
            WorkingDirectory = Path.GetDirectoryName(settings.Vlink)
        };

        using var process = new Process { StartInfo = startInfo };
        process.Start();

        string output = await process.StandardOutput.ReadToEndAsync();
        string error = await process.StandardError.ReadToEndAsync();
        await process.WaitForExitAsync();

        // hier kunnen we misschien iets slims mee.
        //if (!string.IsNullOrEmpty(output)) { Console.WriteLine(output); }
        if (!string.IsNullOrEmpty(error))
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.Error.WriteLine(error);
            Console.ResetColor();
        }
    }

    public void CopyToOutput()
    {
        var sourceFile = Path.GetFileNameWithoutExtension(filetoBuild) + ".bin";
        var destFile = Path.GetFileNameWithoutExtension(filetoBuild) + ".com";

        // check if the source file has a .org line on 1st row, then its a .bin
        var firstline = File.ReadLines(filetoBuild).First();
        if (firstline.Contains(".org", StringComparison.OrdinalIgnoreCase))
        {
            destFile = sourceFile;
        }
        Console.WriteLine(destFile);

        var sourceFolder = Path.GetDirectoryName(filetoBuild);
        var source = Path.Combine(sourceFolder ?? "", sourceFile);
        var dest = Path.Combine(settings.DestFolder, destFile);
        File.Move(source, dest, true);
    }
}