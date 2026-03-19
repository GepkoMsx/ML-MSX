// Ok de bron is dan een wav file.
// Deze kan ik met een windows tool al op de 7,8 khz samplerate zetten en Mono, en opslaan als 8 bit PCM.
// 
// 8-bit Unsigned PCM WAV (waarbij 128  stilte is,  0  maximaal negatief en 255 maximaal positief),
// hoeven we eigenlijk alleen de header (de eerste 44 bytes) te negeren en de ruwe bytes op te slaan.
//
// Echter, om het de MSX makkelijk te maken, kunnen we met dit C#-programma de samples direct naar een .bin bestand
// schrijven dat precies op een 4 KB grens past.
//
// C# Converter (WAV naar MSX Binair)

/*
Belangrijke stap in Windows:
Zorg dat je in je audio-editor (zoals Audacity) bij het exporteren kiest voor:
•	WAV(Microsoft)
•	Encoding: Unsigned 8 - bit PCM
*/


using System.Runtime.InteropServices;
using WAVConvert;



if (args.Length == 0)
{
    Console.WriteLine("Geef een 8-bit WAV, mono 7,8 Khz sample rate bestand op.");
    return;
}

string inputPath = args[0];
string outputPath = Path.ChangeExtension(inputPath, ".bin");

var handle = File.OpenRead(inputPath);

byte[] headerBytes = new byte[44];
byte[] wavBytes = new byte[handle.Length - 44];

handle.ReadExactly(headerBytes, 0, 44); // Lees de eerste 44 bytes (WAV header)
handle.ReadExactly(wavBytes); // Lees de rest van het bestand (PCM data)

WAVHeader header = MemoryMarshal.Read<WAVHeader>(headerBytes);
Console.WriteLine($"WAV Header Info:");
Console.WriteLine($"Audio Format: {header.audioFormat} (1 = PCM)");
Console.WriteLine($"Channels: {header.numChannels}");
Console.WriteLine($"Sample Rate: {header.sampleRate} Hz");
Console.WriteLine($"Bits per Sample: {header.bitsPerSample}");
Console.WriteLine($"Data Size: {header.subchunk2Size} bytes. File data: {wavBytes.Length}");

if (header.audioFormat != 1 || header.numChannels != 1 ||  header.bitsPerSample != 8)
{
    Console.ForegroundColor = ConsoleColor.Yellow;
    Console.WriteLine("Waarschuwing: Dit programma verwacht een 8-bit PCM WAV bestand, Mono, ~7,8 kHz. Controleer je bestand!");
    Console.ForegroundColor = ConsoleColor.Gray;
    return;
}



int dataSize = wavBytes.Length;
byte[] msxData = new byte[4096*4]; // We reserveren precies 4 KB

for (int i = 0; i < 4096*4; i++)
{
    if (i < dataSize)
    {
        // 1. Haal de unsigned byte (0-255)
        int raw = wavBytes[i];

        // 2. Maak er signed van (-128 tot 127)
        int signed = raw;// - 128;

        // 3. Deel door 2 (voorbereiding op mixen van 2 kanalen)
        int halved = signed;// / 2;

        // 4. Maak er weer een byte van die we op de MSX simpel kunnen optellen
        // Stilte is nu 64. 64 + 64 = 128 (midden van de LUT)
        msxData[i] = (byte)(halved);// + 64);
    }
    else
    {
        msxData[i] = 128;// 64; // Stilte-padding
    }
}

File.WriteAllBytes(outputPath, msxData);


/*
In een standaard WAV is 128 stilte. Als je twee van die samples optelt (128 + 128), krijg je 256. Dat stroomt over naar 0 en veroorzaakt verschrikkelijke vervorming.
Het plan voor de C# converter:
1.	Normaliseren: Trek 128 af van elke byte. Nu is 0 stilte, zijn positieve waarden 1 tot 127 en negatieve waarden -1 tot -128.
2.	Delen door 2: Omdat we twee instrumenten mixen, moeten we elke sample halveren (waarde / 2). Anders krijg je "clipping" als ze allebei hard spelen.
3.	Terug naar Unsigned: Tel er weer 64 bij op (omdat we ze gehalveerd hebben, is het bereik nu -64 tot +64).
*/
