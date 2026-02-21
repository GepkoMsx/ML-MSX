using Microsoft.Win32.SafeHandles;

namespace RLEEncoder;

public static class RLE
{

    public static byte FindControlByte(FileStream inhandle)
    {
        // first check what byte is least used.
        int[] bytes = new int[256];
        for (int i = 0; i < 256; i++)
        {
            bytes[i] = 0;
        }

        for (int i = 0; i < inhandle.Length; i++)
        {
            int b = inhandle.ReadByte();
            bytes[b]++;
        }

        byte leastused = 0;
        int count = int.MaxValue;
        for (int i = 0; i < 256; i++)
        {
            if (bytes[i] < count)
            {
                count = bytes[i];
                leastused = (byte)i;
            }
        }

        return leastused;
    }

    public static void Encode(FileStream inhandle, FileStream outhandle, byte control, bool isHMMC)
    {
        outhandle.WriteByte(control);
        /*
            •	Bytes worden onveranderd doorgelaten (RAW), behalve $01
            $01 is de “control byte”
            •	Een dubbele $01 $00 -> escape, output 1x $01.
            •	$01 gevolgd door andere byte, 2e byte is aantal, 3e byte is de ‘herhaalbyte’ 
            Het heeft dus pas zin bij 4 bytes
            •	Max 254 herhalingen
            Dus AA AA AA AA
            Wordt 01 04 AA
        */
        byte next = 0;
        bool hasNext = false;
        int start = (isHMMC) ? 1 : 0; // bij HMMC is de 1e kleur al verstuurd naar het scherm.
        inhandle.Position = start;
        int i = 0;
        while  (i < inhandle.Length-start)
        {
            byte b;
            if (hasNext)
            {
                b = next;
                hasNext = false;
            } else
            {
                b = (byte)inhandle.ReadByte();
                i++;
            }

            if (b == control)
            {
                outhandle.WriteByte((byte)b);
                outhandle.WriteByte((byte)0);
                continue;
            }

            if (i >= inhandle.Length - 5)
            {
                // laatste 4 bytes, geen zin meer
                outhandle.WriteByte(b);
                continue;
            }

            int samebytecount = 1;
            byte c = (byte)inhandle.ReadByte();
            i++;

            while (b==c && i < inhandle.Length && samebytecount < 255)
            {
                samebytecount++;
                c = (byte)inhandle.ReadByte();
                i++;
            }

            if (samebytecount < 4)
            {
                for (int j = 0; j < samebytecount; j++)
                {
                    outhandle.WriteByte(b);
                }
            }
            else
            {
                // RLE truuk
                outhandle.WriteByte(control);
                outhandle.WriteByte((byte)samebytecount);
                outhandle.WriteByte(b);
            }
            next = c;
            hasNext = true;
        }
    }
}
