using Melanchall.DryWetMidi.Core;
using Melanchall.DryWetMidi.Interaction;

namespace MidiConvert;

struct Msxnote
{
    public long Frame; // V-Sync frames (50Hz)
    public byte FineFreq; // register 0, 2, of 4
    public byte CoarseFreq; // register 1, 3, of 5
    public byte Volume; // Velocity 0-127 naar PSG 0-15
    public int Channel; // the midichannel (0-15)
}

internal class ChannelConverter
{

    static public List<byte[]> ConvertChannelToMsxEvents(int channel, MidiFile midiFile)
    {
        Console.WriteLine($"Converting channel {channel + 1} to PSG format...");

        var tempoMap = midiFile.GetTempoMap();

        var obj = midiFile.GetObjects(ObjectType.TimedEvent);

        var noteEvents = obj
            .OfType<TimedEvent>()
            .Where(e => e.Event.EventType == MidiEventType.NoteOn || e.Event.EventType == MidiEventType.NoteOff)
            .Where(e => e.Event is NoteEvent)
            .Select(e => new Msxnote
            {
                Frame = (long)((e.TimeAs<MetricTimeSpan>(tempoMap).TotalMilliseconds * 50) / 1000),       // V-Sync frames (50Hz)
                FineFreq = NoteExtentions.ToFineFreq(((NoteEvent)e.Event).NoteNumber),               // register 0, 2, of 4
                CoarseFreq = NoteExtentions.ToCourseFreq(((NoteEvent)e.Event).NoteNumber),           // register 1, 3, of 5
                Volume = (byte)(((NoteEvent)e.Event).Velocity / 8),                                  // Velocity 0-127 naar PSG 0-15
                Channel = ((NoteEvent)e.Event).Channel                                               // the midichannel (0-15)
            });
            
        
        // We pakken de eerste track met noten
        var notes = noteEvents.Where(n => n.Channel == channel).OrderBy(n => n.Frame);
        var msxEvents = new List<byte[]>();

        // er kunnen meerdere events op dezelfde tijd zijn, dus we moeten de absolute tijd bijhouden
        // We gaan ervan uit dat de events al gesorteerd zijn op tijd, dus we kunnen gewoon de delta-tijd tussen opeenvolgende events berekenen
        // Er kunnen meerdere notes tegelijk spelen.
        // meerdere noten spelen doen we door snel te wisselen tussen de noten
        OrderedDictionary<int, Msxnote> notesOn = [];
        int lasteNotePlayed = 0; 
        long endFrame = notes.Max(n => n.Frame);

        for (long frame = 0; frame < endFrame; frame++)
        {
            var eventsAtThisFrame = notes.Where(n => (long)n.Frame == frame).ToList();
            // notesOn lijst bijwereken op basis van de events die op dit frame plaatsvinden
            foreach (var evt in eventsAtThisFrame)
            {
                int noteValue = evt.FineFreq + evt.CoarseFreq * 256;
                if (evt.Volume == 0)
                {
                    // Dit is een Note Off event, we verwijderen de noot uit de lijst van actieve noten
                    notesOn.Remove(noteValue);
                }
                else
                {
                    notesOn.TryAdd(noteValue, evt);
                }
            }
            // schrijf nu de PSG events voor eerstvolgende noot die aanstaat (of een rust als er geen noten aanstaan)
            int noteToPlay = notesOn.Keys.Where( k => k > lasteNotePlayed).FirstOrDefault();
            if (noteToPlay == 0)
            {
                noteToPlay = notesOn.Keys.FirstOrDefault();
            }

            if (noteToPlay == 0)
            {
                msxEvents.Add([1, 0, 0, 0]); // Rust 
            }
            else
            {
                var evt = notesOn[noteToPlay];
                msxEvents.Add([1,evt.FineFreq,evt.CoarseFreq,evt.Volume]);
                lasteNotePlayed = noteToPlay;
            }
        }


        // Voeg een 'Einde' marker toe (Delta 0, Note 0)
        msxEvents.Add([0,0,0,0]);
        return msxEvents;
    }

    static public IEnumerable<byte> Compress(List<byte[]> msxEvents)
    {
        // Nu compressie toepassen: we kunnen opeenvolgende events met dezelfde noot samenvoegen door de delta-tijd op te tellen    
        // we slaan de events plat als bytearray: groepjes van: [Delta, FineFreq, CoarseFreq, Volume]
        var compressedEvents = new List<byte>();

        byte[] lastEvent = [0, 0, 0, 0];
        byte duration = 0;
        foreach (var evt in msxEvents)
        {
            if (evt[1] == lastEvent[1] && evt[2] == lastEvent[2] && evt[3] == lastEvent[3] && duration < 254)   // msx 254 frames "wachten"
            {
                // zelfde noot, we tellen de delta-tijd op
                duration += evt[0];
            }
            else
            {
                // andere noot, we voegen het vorige event toe aan de lijst en beginnen een nieuw event
                if (duration > 0)
                {
                    compressedEvents.Add(duration);
                    compressedEvents.Add(lastEvent[1]);
                    compressedEvents.Add(lastEvent[2]);
                    compressedEvents.Add(lastEvent[3]);
                }
                lastEvent = evt;
                duration = evt[0];
            }
        }
        // add last event
        compressedEvents.Add(duration);
        compressedEvents.Add(lastEvent[1]);
        compressedEvents.Add(lastEvent[2]);
        compressedEvents.Add(lastEvent[3]);

        return compressedEvents;
    }
}
