using System.Diagnostics;
using XRefGenerator;

Console.WriteLine("XRef Generator V0.1");

var file = args[0];
var root = args[1];
var includefolders = File.ReadAllLines("includefolders.txt").ToList();
var dir = Path.GetDirectoryName(file);
if (dir != null)
{ 
    includefolders.Add(dir);
}

var startaddress = Searcher.FindStartAddress(file);


// find all included files (recursively) and add them to the list of files to process
List<string> allfiles = [];
allfiles.Add(file);   // add the main file to the list of files to process
allfiles = allfiles.Concat(Searcher.FindIncludes(file, includefolders)).Distinct().ToList();
var ofileLabels = Searcher.MakeGlobalList(includefolders);

List<string> allOFiles = [];
while (allfiles.Count > 0)
{
    var oFiles = Searcher.GetAllOFiles(allfiles, ofileLabels);

    allfiles = oFiles
        .Where (ofile => !allOFiles.Contains(ofile))
        .Select(ofile => Directory.GetFiles(Path.GetDirectoryName(ofile) ?? "", Path.GetFileNameWithoutExtension(ofile) + ".as?", SearchOption.AllDirectories).FirstOrDefault() ?? "")
        .Where(s => !string.IsNullOrEmpty(s))
        .ToList();

    allOFiles.AddRange(oFiles);
}

var linkOFiles = allOFiles.Distinct().ToList();

// generate a cmd file to run the linker with the .o files and the xrefs
Writer.GenerateLinkCmd(file, linkOFiles, root, startaddress);

