using System.Text.RegularExpressions;

namespace XRefGenerator;

static class XrefHelper
{
    public static string FindStartAddress(string path)
    {
        var lines = File.ReadAllLines(path);
        // we are searching for a comment line that starts with a comment (;) and contains  .org followed by an address

        var addressinfile = lines.Where(line => line.StartsWith(';'))
            .Where(line => line.Contains(".org ", StringComparison.OrdinalIgnoreCase))
            .Select(line => line.ToLower().Split(".org")[1].Trim())
            .Select(line => line.Split(' ')[0].Trim())
            .FirstOrDefault();

        if (!string.IsNullOrWhiteSpace(addressinfile))
        {
            return addressinfile;
        }

        return "0x0100";  // if we can't find an .org directive, we return a default start address of msxdos
    }

    public static IEnumerable<string> GetAllOFiles(IEnumerable<string> allfiles, Dictionary<string, string> ofileLabels)
    {
        List<string> allOFiles = [];
        foreach (var sourcefile in allfiles)
        {
            var declaredLabels = XrefHelper.FindDeclaredLabels(sourcefile);
            var usedLabels = XrefHelper.FindUsedLabels(sourcefile).Distinct();
            var usedNotDeclared = usedLabels.Where(l => !declaredLabels.Contains(l)).Distinct().ToList();

            // find all .o files that contain the cross-references
            var ofiles = XrefHelper.FindOfiles(usedNotDeclared, ofileLabels);
            // search all .o files for the cross-references
            allOFiles.AddRange(ofiles);
            // now do this recursively for the .o files we found, to find more cross-references

        }
        return allOFiles;
    }


    // find all included files (recursively) and add them to the list of files to process
    public static IEnumerable<string> FindIncludes(string path, IEnumerable<string> includeFolders)
    {
        List<string> includes = [];
        // read the file line by line, if we find an include directive, we add the included file to the list of includes
        var lines = File.ReadAllLines(path);
        foreach (var lineWcomment in lines)
        {
            var line = lineWcomment.Split(';')[0]; // remove comments
            if (line.Contains(".include ") || line.Contains(".INCLUDE "))
            {
                // extract the included file name
                var include = line.Split('"')[1];
                // search for the included file in the include folders
                foreach (var folder in includeFolders)
                {
                    var includePath = Path.Combine(folder, include);
                    if (File.Exists(includePath))
                    {
                        includes.Add(includePath);
                        // recursively find includes in the included file
                        includes = includes.Concat(FindIncludes(includePath, includeFolders)).ToList();
                        break;
                    }
                }
            }
        }

        return includes;
    }

    // find all declared labels
    public static IEnumerable<string> FindDeclaredLabels(string path)
    {
        var declaredLabels = new List<string>();
        var lines = File.ReadAllLines(path);
        foreach (var line in lines)
        {
            string nocommentLine = line.Split(';')[0]; // remove comments

            // if the line ends with a colon, we consider it a label declaration
            if (nocommentLine.Trim().EndsWith(':'))
            {
                // extract the label name
                var label = nocommentLine.Trim().TrimEnd(':');
                declaredLabels.Add(label);
            }
        }

        return declaredLabels;
    }

    // find all used labels
    public static IEnumerable<string> FindUsedLabels(string path)
    {
        var usedLabels = new List<string>();    
        var lines = File.ReadAllLines(path);
        foreach (var line in lines)
        {
            string nocommentLine = line.Split(';')[0]; // remove comments

            // split the line into tokens and check if any token is a label (we consider a label any token that is not an instruction or a register)
            var tokens = GetTokens(nocommentLine);

            foreach (var token in tokens)
            {
                var t = token.Trim();
                if (t.Length > 0 && !IsInstructionOrRegister(t) && !IsConstant(t) && !t.EndsWith(':') && !IsCreated(t, lines))
                {
                    usedLabels.Add(t);
                }
            }
        }

        return usedLabels;
    }

    public static Dictionary<string, string> MakeGlobalList(IEnumerable<string> includeFolders)
    {
        var allOfiles = includeFolders.SelectMany(folder => Directory.GetFiles(folder, "*.o", SearchOption.AllDirectories)).ToList();
        Dictionary<string, string> ofileLabels = [];  // label,file
        foreach (var ofile in allOfiles)
        {
            var sourceFile = Directory.GetFiles(Path.GetDirectoryName(ofile) ?? "", Path.GetFileNameWithoutExtension(ofile) + ".as?", SearchOption.AllDirectories).FirstOrDefault();
            if (sourceFile != null)
            {
                // find all .global labels in the source file, as these are the only labels that can be referenced from other files (and thus can be cross-references)
                var lines = File.ReadAllLines(sourceFile);

                foreach (var line in lines)
                {
                    if (line.Contains(".global ") || line.Contains(".GLOBAL "))
                    {
                        var afterGlobal = line.Split([".global ", ".GLOBAL "], StringSplitOptions.None)[1].Trim();
                        var afterGlobalLabels = afterGlobal.Split(',');
                        foreach (var label in afterGlobalLabels)
                        {
                            var l = label.Trim();
                            if (l.Length > 0 && !ofileLabels.ContainsKey(l))
                            {
                                ofileLabels.Add(l, ofile);
                            }
                        }
                    }
                }
            }
        }

        return ofileLabels;
    }

    // find all .o files that contain the cross-references, update usedNotDeclared by removing missing cross-references
    public static IEnumerable<string> FindOfiles(List<string> usedNotDeclared, Dictionary<string, string> ofileLabels)
    {
        List<string> ofiles = [];
        foreach (var label in usedNotDeclared)
        {
            if (ofileLabels.ContainsKey(label))
            {
                ofiles.Add(ofileLabels[label]);
            }
        }

        return ofiles;
    }


    private static bool IsInstructionOrRegister(string token)
    {
        var instructions = new List<string> {
            ".abort", ".align", ".balign", ".balignl", ".balignw", ".comm", ".equ", ".equiv", ".err", ".extern", ".fail", ".file", ".global", ".globl", ".hidden", ".incbin", ".incdir", ".include", ".internal", ".lcomm", ".local", ".org", 
            ".p2align", ".p2alignl", ".p2alignw", ".protected", ".set", ".size", ".skip", ".space", ".stabs", ".stabn", ".stabd", ".swbeg", ".type", ".weak", ".zero", ".else", ".elseif", ".endif", ".endm", ".endr", ".if", ".ifeq", ".ifne", 
            ".ifgt", ".ifge", ".iflt", ".ifle", ".ifb", ".ifnb", ".ifc", ".ifnc", ".ifdef", ".ifndef", ".irp", ".irpc", ".macro", ".list", ".nolist", ".rept", ".2byte", ".4byte", ".8byte", ".ascii", ".ds", ".deb", ".defw", ".defs", ".byte", 
            ".double", ".float", ".half", ".int", ".long", ".quad", ".short", ".single", ".string", ".uahalf", ".ualong", ".uaquad", ".uashort", ".uaword", ".word", ".bss", ".data", ".dpage", ".rodata", ".sbss", ".sdata", ".sdata2", 
            ".stab", ".stabstr", ".text", ".tocd", ".section", ".pushsection", ".popsection",
            
            "ADC", "ADD", "AND", "BIT", "CCF", "CP", "CPD", "CPDR", "CPI", "CPIR", "CPL", "DAA", "DEC", "DI", "EI", "EX", "EXX", "HALT", "IM", "IN", "INC", "IND", "INDR", "INI", "INIR", "LD", "LDD", "LDDR", "LDI", "LDIR", "NEG", "NOP", "NV", "OR", "OTDR", "OTIR", "OUT", "OUTD", "OUTI", "POP", "PUSH", "RES", "RL", "RLA", "RLC", "RLCA", "RLD", "RR", "RRA", "RRC", "RRCA", "RRD", "RST", "SBC", "SCF", "SET", "SLA", "SRA", "SRL", "SUB", "XOR",
            "jr", "jp", "call", "ret", "djnz",
            "c", "nc", "z", "nz", "p", "m", "pe", "po",
            "A", "B", "C", "D", "E", "F", "H", "L", "I", "R", "IX", "IY", "AF", "BC", "DE", "HL", "PC", "SP", "AF'"
        };
        // we can use a list of known instructions to check if the token is an instruction
        
        return instructions.Contains(token, StringComparer.OrdinalIgnoreCase);
    }

    private static bool IsConstant(string token)
    {
        // we consider a constant any token that starts with a digit or a dollar sign (for hex constants)
        return char.IsDigit(token[0]) || token.StartsWith("0b") || token.StartsWith("0x") || token.StartsWith("'") || token.StartsWith("\"") || token.StartsWith("\\");
    }

    private static bool IsCreated(string token, string[] lines)
    {
        // we consider a label (thats actually a variable) "created" if it is declared in the file
        // so a line needs to have the label and one of: ".set" , ".equ", ".equiv", ".assign"
        return lines.Any(line => {
            var l = line.Split(';')[0].Trim().ToLower();
            return l.Contains(token, StringComparison.OrdinalIgnoreCase) && (l.Contains(".set") || l.Contains(".equ") || l.Contains(".equiv") || l.Contains(".assign"));
        });
    }
    private static IEnumerable<string> GetTokens(string line)
    {
        string pattern = @"("".*?""|[^\s\t,()]+)";
        return Regex.Matches(line, pattern)
                    .Cast<Match>()
                    .Select(m => m.Value)
                    .ToArray();
    }
}