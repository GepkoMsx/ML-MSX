namespace VasmBuilder;

public class BuildSettings
{
    public string Vasm { get; set; } = string.Empty;
    public string Vlink { get; set; } = string.Empty;
    public string OutFolder { get; set; } = string.Empty;
    public string DestFolder { get; set; } = string.Empty;
    public string MacroRootFolder { get; set; } = string.Empty;
    public string MacroFile { get; set; } = string.Empty;
    public List<string> IncludeFolders { get; set; } = new();
}
