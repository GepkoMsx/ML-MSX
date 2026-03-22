using XRefGenerator;

Console.WriteLine("XRef Generator V0.1");

var file = args[0];
var root = args[1];
var startaddress = args[2];
var includefolders = File.ReadAllLines("includefolders.txt");

// find all included files (recursively) and add them to the list of files to process
List<string> allfiles = [];
allfiles.Add(file);   // add the main file to the list of files to process
allfiles = allfiles.Concat(Searcher.FindIncludes(file, includefolders)).Distinct().ToList();


// find all declared labels
// find all used labels
List<string> allOFiles = [];
foreach (var sourcefile in allfiles)
{
    var declaredLabels = Searcher.FindDeclaredLabels(sourcefile);
    var usedLabels = Searcher.FindUsedLabels(sourcefile).Distinct();

    // find all used labels that are not declared (these are the "cross-references")
    var usedNotDeclared = usedLabels.Where(l => !declaredLabels.Contains(l)).Distinct().ToList();

    // find all .o files that contain the cross-references
    var ofiles = Searcher.FindOfiles(usedNotDeclared, includefolders);
    // search all .o files for the cross-references
    allOFiles.AddRange(ofiles);

    // add those to the file as xref. (so used labels, or 'labels' found, that are not labels, become xrefs.)
    // not needed for std?
    // Writer.WriteXRef(sourcefile, usedNotDeclared);
}

var linkOFiles = allOFiles.Distinct().ToList();

// generate a cmd file to run the linker with the .o files and the xrefs
Writer.GenerateLinkCmd(file, linkOFiles, root, startaddress);

