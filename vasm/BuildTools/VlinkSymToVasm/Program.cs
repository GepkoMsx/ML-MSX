// See https://aka.ms/new-console-template for more information
Console.WriteLine("Vlink Symbol file converter to Vasm style");

string file = args[0];
string[] strings = File.ReadAllLines(file);
File.Delete(file);

var writer = new StreamWriter(file);

writer.WriteLine("sections:");
bool inSections = false;    
int sectionCount = 0;
for (int i=0; i< strings.Length;i++)
{
    if (inSections && strings[i].StartsWith("  0000"))
    {
        var parts = strings[i].Trim().Split([" ","(size ", ")",","], StringSplitOptions.RemoveEmptyEntries);
        int start = int.Parse(parts[0], System.Globalization.NumberStyles.HexNumber);
        int size = int.Parse(parts[2], System.Globalization.NumberStyles.HexNumber);
        writer.WriteLine($"{sectionCount:D2}: \"{parts[1]}\" ({(start & 0xFFFF):X4}-{((start &0xFFFF)+ size):X4})");
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
        var parts = strings[i].Trim().Split([" ","0x", ":"], StringSplitOptions.RemoveEmptyEntries);
        writer.WriteLine($"    {parts[0][^4..]} {parts[1]}");
    }
}



writer.Close();
Console.WriteLine("Done converting " + file);
