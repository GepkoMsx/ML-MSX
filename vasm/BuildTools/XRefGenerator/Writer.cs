namespace XRefGenerator;

public static class Writer
{
    // write (update) the xrefs on the file 
    public static void WriteXRef(string path, IEnumerable<string> labels)
    {
        var lines = File.ReadAllLines(path).ToList();
        File.Delete(path);

        var handle = File.CreateText(path);
        labels.Chunk(10).ToList().ForEach(chunk =>
        {
            handle.WriteLine("    .xref " + string.Join(", ", chunk));
        });

        foreach (var line in lines)
        {
            if (!line.Contains(".xref "))
            {
                handle.WriteLine(line);
            }
        }

        handle.Close();
    }

    // generate a cmd file to run the linker with the .o files and the xrefs
    public static void GenerateLinkCmd(string path, IEnumerable<string> oFiles, string outputFolder, string address)
    {
        var handle = File.CreateText(Path.Combine(outputFolder, "link.cmd"));

        var binpath = Path.GetFileNameWithoutExtension(path) + ".bin";
        handle.Write($"bin\\vlink.exe -Msymbols.sym -b rawbin -Ttext {address} -o {binpath} ");

        // make sure the .o file for the main file is included as first one in the list of .o files to link
        var opath = Path.Combine(Path.GetDirectoryName(path) ?? "", Path.GetFileNameWithoutExtension(path) + ".o");
        handle.Write(opath + " ");

        oFiles = oFiles.Where(ofile => ofile != opath).ToList();
        handle.WriteLine(string.Join(' ', oFiles));

        // call the vlinksymtovasm
        handle.WriteLine($"D:\\MSX\\code\\vasm\\BuildTools\\VlinkSymToVasm\\bin\\Release\\net9.0\\vlinksymtovasm.exe D:\\MSX\\code\\vasm\\symbols.sym");

        handle.Close();
    }
}
