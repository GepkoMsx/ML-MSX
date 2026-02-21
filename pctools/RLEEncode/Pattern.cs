using System.Data;

namespace RLEEncoder;

public static class Pattern
{
    public static IEnumerable<byte[]> getPatterns(FileStream inhandle)
    {
        // 3 byte pattern
        var patterns = new Dictionary<string, int>();

        for (int i = 0; i < inhandle.Length -3; i++)
        {
            var buf = new byte[4];
            inhandle.Position = i;
            inhandle.ReadExactly(buf, 0, 3);

            var key = $"{buf[0]:X2}{buf[1]:X2}{buf[2]:X2}";
            patterns.TryAdd(key, 0);
            patterns[key] += 1;
        }

        int c = 0;
        int d = 0;
        var list = patterns.OrderByDescending(kv => kv.Value).Take(256);
        foreach (var kv in list)
        {
            Console.WriteLine($"{kv.Key}: {kv.Value}");
            c++;
            d += kv.Value;
        }
        Console.WriteLine($"aantal:{c}, totaal:{d}");

        return list.Select(kv => new byte[] {
            Convert.ToByte(kv.Key.Substring(0, 2), 16),
            Convert.ToByte(kv.Key.Substring(2, 2), 16),
            Convert.ToByte(kv.Key.Substring(4, 2), 16)
        });
    }

    public static void writePatterns(FileStream outhandle, IEnumerable<byte[]> patterns)
    {
        foreach (var pattern in patterns)
        {
            outhandle.Write(pattern, 0, 3);
        }
    }

    public static void Encode(FileStream inhandle, FileStream outhandle, byte controlByte, IEnumerable<byte[]> patterns)
    {
        var dict = patterns.Select((p, index) => new { p, index }).ToDictionary(x => $"{x.p[0]:X2}{x.p[1]:X2}{x.p[2]:X2}", x => x.index);

        var readAhead = new Queue<byte>();
        for (int i = 0; i < inhandle.Length -3; i++)
        {
            byte b1 = (readAhead.Count > 0) ? readAhead.Dequeue() : (byte)inhandle.ReadByte();
            byte b2 = (readAhead.Count > 0) ? readAhead.Dequeue() : (byte)inhandle.ReadByte();
            byte b3 = (readAhead.Count > 0) ? readAhead.Dequeue() : (byte)inhandle.ReadByte();

            if (dict.TryGetValue($"{b1:X2}{b2:X2}{b3:X2}", out int patternIndex))
            {
                outhandle.WriteByte(controlByte);
                outhandle.WriteByte((byte)patternIndex);
                i += 2;
                continue;
            }

            outhandle.WriteByte((byte)b1);
            if (b1 == controlByte)
            {
                outhandle.WriteByte((byte)b1);
            }
            readAhead.Enqueue(b2);
            readAhead.Enqueue(b3);
        }
        // schrijf de resterende bytes onveranderd
        while (inhandle.Position < inhandle.Length)
        {
            outhandle.WriteByte((byte)inhandle.ReadByte());
        }
    }
}
