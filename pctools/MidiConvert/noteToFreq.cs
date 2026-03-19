using Melanchall.DryWetMidi.Common;
using Melanchall.DryWetMidi.Interaction;

namespace MidiConvert;

internal static class NoteExtentions
{
    static readonly double psgClock = 1789772.5; // Standaard MSX klok


    public static byte[] ToFreq(this Note note)
    {
        // Bereken de 12-bit 'Period' waarde voor de PSG registers
        double frequency = 440.0 * Math.Pow(2, (note.NoteNumber - 69) / 12.0);
        int period = (int)(psgClock / (16 * frequency));

        byte fineTune = (byte)(period & 0xFF);              // Register 0, 2, of 4
        byte coarseTune = (byte)((period >> 8) & 0x0F);     // Register 1, 3, of 5

        return [fineTune, coarseTune];
    }

    public static byte ToFineFreq(SevenBitNumber noteNumber)
    {
        // Bereken de 12-bit 'Period' waarde voor de PSG registers
        double frequency = 440.0 * Math.Pow(2, (noteNumber - 69) / 12.0);
        int period = (int)(psgClock / (16 * frequency));
        return  (byte)(period & 0xFF);              // Register 0, 2, of 4
    }
    public static byte ToCourseFreq(SevenBitNumber noteNumber)
    {
        // Bereken de 12-bit 'Period' waarde voor de PSG registers
        double frequency = 440.0 * Math.Pow(2, (noteNumber - 69) / 12.0);
        int period = (int)(psgClock / (16 * frequency));
        return (byte)((period >> 8) & 0x0F);     // Register 1, 3, of 5
    }

}
