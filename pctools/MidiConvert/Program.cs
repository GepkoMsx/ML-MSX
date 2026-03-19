using Melanchall.DryWetMidi.Core;
using Melanchall.DryWetMidi.Interaction;
using MidiConvert;

Console.WriteLine("MidiConvert");


if (args.Length == 0 || !args[0].Contains(".mid", StringComparison.CurrentCultureIgnoreCase))
{
    Console.WriteLine("Specify a midi file to convet.");
    return;
}

string inputPath = args[0];
var midiFile = MidiFile.Read(inputPath);

// Voorbeeld: Alle noten en hun bijbehorende PSG waarden tonen
var notes = midiFile.GetNotes();
foreach (var note in notes)
{
    byte[] bytes = note.ToFreq();
  //  Console.WriteLine($"Noot: {note.NoteName}, PSG Period Low: {bytes[0]}, High: {bytes[1]})");
}

// Analyseer de kanalen en instrumenten in het MIDI bestand
Analyzer a = new Analyzer();
var channels  = a.AnalyzeMidiFile(inputPath);

//foreach (var channel in channels)
//{
//    var events = ChannelConverter.ConvertChannelToMsxEvents(channel, midiFile); // Converteer kanaal 1 (index 0) naar PSG events
//    var msxbytes = ChannelConverter.Compress(events).ToArray();
//    for (int i = 0; i < msxbytes.Length; i += 4)
//    {
//        Console.WriteLine($"Delta: {msxbytes[i]:D3}, Freq: {msxbytes[i + 2]:D1}:{msxbytes[i + 1]:D3}, Vol: {msxbytes[i + 3]:D2}");
//    }

//    var msxfile = Path.Combine(Path.GetDirectoryName(inputPath) ?? string.Empty, Path.GetFileNameWithoutExtension(inputPath) + (channel+1) + ".snd");
//    File.WriteAllBytes(msxfile, msxbytes);
//}