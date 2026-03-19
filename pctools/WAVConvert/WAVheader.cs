namespace WAVConvert;

using System.Runtime.InteropServices;

// Ensure your struct has a defined layout
[StructLayout(LayoutKind.Sequential, Pack = 1)]
public struct WAVHeader
{
    public UInt32 chunkId;
    public UInt32 chunkSize;
    public UInt32 chunkFormat;

    public UInt32 subchunkId;
    public UInt32 subchunkSize;
    public UInt16 audioFormat;
    public UInt16 numChannels;
    public UInt32 sampleRate;
    public UInt32 byteRate;
    public UInt16 blockAlign;
    public UInt16 bitsPerSample;

    public UInt32 subchunk2Id;
    public UInt32 subchunk2Size;
};