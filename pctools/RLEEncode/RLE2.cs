/*
    Nieuwe Bit-Protocol (8-bit)
    0xxxxxxx: Raw Data. De volgende x bytes (1-63) 1-op-1 kopiëren.
    1xxxxxxx: Run (Herhaling). De volgende byte x keer herhalen.  (xxxxxxx cant be all 1s, want dat is EOD) dus max 126 herhalingen.
    11111111: End of Data (EOD). Stop de decoder.
*/

namespace RLEEncoder;


public static class RLE2
{
    public static void Encode(FileStream inhandle, FileStream outhandle, bool isHMMC)
    {
        int start = (isHMMC) ? 1 : 0; // bij HMMC is de 1e kleur al verstuurd naar het scherm.
        inhandle.Position = start;

        int i = 0;
        int bi = 0; // buffer index
        byte[] buffer = new byte[126];               // 63 is max blocksize
        bool isRun = false;
        while (i < inhandle.Length - start)         // i is including the buffer
        {
            switch (bi)
            {
                case 0:
                    // first byte, just add to buffer
                    buffer[bi++] = (byte)inhandle.ReadByte();
                    i++;
                    isRun = false;
                    break;
                case 1:
                    // second byte, check if we have a run
                    buffer[bi++] = (byte)inhandle.ReadByte();
                    i++;
                    if (buffer[1] == buffer[0])
                    {
                        isRun = true;
                    }
                    break;
                case 126:
                     // we reached max blocksize, write the block
                    WriteBlock(outhandle, buffer, bi, isRun);
                    bi = 0;
                    isRun = false;
                    break;
                default:
                    byte c = (byte)inhandle.ReadByte();

                    if ((isRun && c == buffer[bi-1]) || (!isRun && c != buffer[bi-1]))
                    {
                        // we have type byte as the type of run
                        buffer[bi++] = c;
                        i++;
                    }
                    else
                    {
                        // we have different type byte, write the block and start a new one
                        WriteBlock(outhandle, buffer, bi, isRun);
                        bi = 1;
                        isRun = false;
                        buffer[0] = c;
                    }
                    break;
            }
        }
        // write last block and EOF
        WriteBlock(outhandle, buffer, bi, isRun);
        outhandle.WriteByte(0xff);
    }


    private static void WriteBlock(FileStream outhandle, byte[] buffer, int count, bool isRun)
    {
        if (isRun)
        {
            outhandle.WriteByte((byte)(0b10000000 | count)); // count is the number of bytes in the run block
            outhandle.WriteByte(buffer[0]);
        }
        else
        {
            outhandle.WriteByte((byte)(0b00000000 | count)); // count is the number of bytes in the raw block
            outhandle.Write(buffer, 0, count);
        }
    }
}