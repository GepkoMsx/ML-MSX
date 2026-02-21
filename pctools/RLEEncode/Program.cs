using RLEEncoder;

Console.WriteLine("RLE Encoder 8 bits");

//args[0] is the filename.

/*
De Gepko variant..
•	Bytes worden onveranderd doorgelaten (RAW), behalve $01
$01 is de “control byte”
•	Een $01 gevolgd door $00 -> escape, output 1x $01.
•	$01 gevolgd door andere byte, 2e byte is aantal, 3e byte is de ‘herhaalbyte’ 
Het heeft dus pas zin bij 4 bytes
•	Max 254 herhalingen
Dus AA AA AA AA
Wordt 01 04 AA

Uitbreiding:
•	1e byte van het bestand is de controlbyte. (en wordt verder niet gebruikt)
Dit geeft de mogelijkheid om de “minst voorkomende” kleur te kiezen als control.

DAARNA:
•	De 256 meest voorkomende 3-byte patronen worden in een tabel gezet (3*256 = 768 bytes)
•   Bepaal opnieuw de conrolbyte. deze wordt weer als eerste byte van het bestand geschreven, gevolgd door de 768 bytes van de tabel.
•   De controlbyte wordt gebruikt als escape, gevolgd door een index in de tabel (1 byte) en de herhaalbyte (1 byte)

RLE decode doet dus het omgekeerde.
*/

string infile = args[0];
string midfile = Path.ChangeExtension(infile, ".RL8");  // gepko's RLE encoded bestand
string outfile = Path.ChangeExtension(infile, ".RP8");  // gepko's RLE + pattern encoded bestand
File.Delete(midfile);
File.Delete(outfile);

var inhandle = File.OpenRead(infile);
var midhandle = File.OpenWrite(midfile);

byte controlByte = RLE.FindControlByte(inhandle);
inhandle.Position = 0;

// basis en '2' geimplementeerd.
RLE.Encode(inhandle, midhandle, controlByte, true);

inhandle.Close();
midhandle.Flush();
midhandle.Close();


// nu de 256 meest voorkomende 3-byte patronen bepalen en vervangen enzo.
midhandle = File.OpenRead(midfile);
var patterns = Pattern.getPatterns(midhandle);
midhandle.Position = 0;
byte controlByte2 = RLE.FindControlByte(midhandle);
midhandle.Position = 0;

var outhandle = File.OpenWrite(outfile);
outhandle.WriteByte(controlByte2);
Pattern.writePatterns(outhandle, patterns);
Pattern.Encode(midhandle, outhandle, controlByte2, patterns);


outhandle.Flush();
outhandle.Close();
midhandle.Close();
