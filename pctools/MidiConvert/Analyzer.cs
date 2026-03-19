using Melanchall.DryWetMidi.Core;
using Melanchall.DryWetMidi.Interaction;

namespace MidiConvert;

internal class Analyzer
{
    public IEnumerable<byte> AnalyzeMidiFile(string file)
    {
        var midiFile = MidiFile.Read(file);

        // Haal alle unieke kanalen op die noten bevatten
        var activeChannels = midiFile.GetNotes()
            .Select(n => n.Channel)
            .Distinct()
            .OrderBy(c => c);

        Console.WriteLine("--- MIDI KANAAL ANALYSE ---");

        foreach (var channel in activeChannels)
        {
            // Zoek het instrument (Program Change) voor dit kanaal
            var instrumentEvent = midiFile.GetTrackChunks().SelectMany(c => c.Events)
                .OfType<ProgramChangeEvent>()
                .Where(e => e.Channel == channel);

            Console.Write("{0:D2}: ", channel + 1);
            if (channel == 9) // Kanaal 10 is per MIDI standaard voor percussie
            {
                Console.Write("0 Percussie");
            }
            foreach (var evt in instrumentEvent)
            {
                int programNumber = evt?.ProgramNumber ?? 0;
                string instrumentName = GetInstrumentName(programNumber);
                Console.Write($"{evt?.DeltaTime} {evt?.ProgramNumber}({instrumentName}) ");
            }
            Console.WriteLine();
        }
        Console.WriteLine();

        var maxtime = midiFile.GetNotes().Max(n => n.Time);
        var timeslot = maxtime / 80;
        foreach (var channel in activeChannels)
        {
            Console.Write("{0:D2}: [", channel + 1);
            var usagebar = midiFile.GetNotes()
                .Where(n => n.Channel == channel)
                .GroupBy(n => n.Time / timeslot)
                .Select(g => new { TimeSlot = g.Key, Count = g.Count() })
                .OrderBy(g => g.TimeSlot);

            char[] density = [' ', '·', '-', '=', '#'];
            int maxCount = usagebar.Max(g=>g.Count);
            int densitySteps = 1+ maxCount/ density.Length;

            for (int i=0; i < 80; i++)
            {
                if (!usagebar.Any(g => g.TimeSlot == i))
                {
                    Console.Write(' ');
                } else
                {
                    int count = usagebar.First(g => g.TimeSlot == i).Count;
                    int densityIndex = count / densitySteps;
                    Console.Write(density[densityIndex]);
                }
            }

            Console.WriteLine("]");

        }
        return activeChannels.Select(n => (byte)n);

    }
    // Hulpmethode voor General MIDI namen
    static string GetInstrumentName(int p)
    {
        return p switch
        {
            >= 0 and < 8 => "Piano",
            >= 8 and < 16 => "Chromatic Percussion",
            >= 16 and < 24 => "Organ",
            >= 24 and < 32 => "Guitar",
            >= 32 and < 40 => "Bass",
            >= 40 and < 48 => "Strings",
            >= 48 and < 56 => "Ensemble",
            >= 56 and < 64 => "Trumpet/Brass",
            >= 64 and < 72 => "Reed",
            >= 72 and < 80 => "Pipe",
            >= 80 and < 88 => "Lead Synth",
            _ => "Ander instrument"
        };
    }
}