Console.WriteLine("symparser 1.0");

var file = args[0];

var lines = File.ReadAllLines(file);

var writer = new StreamWriter(file);
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

writer.Flush();
writer.Close();
Console.WriteLine($"Done writing {file}");