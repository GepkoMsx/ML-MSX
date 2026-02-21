using System.Drawing;
using System.Reflection.Metadata;
using System.Runtime.Versioning;
using System.Text.RegularExpressions;

internal class Program
{
    private static void Help()
    {
        Console.WriteLine("png2msxSc8");
        Console.WriteLine("Converting a png image of 256x192 pixels into an msx screen 8 file.");
        Console.WriteLine("byte info: GGGRRRBB");
        Console.WriteLine("Arguments:");
        Console.WriteLine("PNGpath: Mandatory path to png file");
        Console.WriteLine("start: Optional startadres to make bloadable ex: D000");
        Console.WriteLine("color: Optional color to make bloadable in vram directly (mask: GGGRRRBB) ex: 0000 E0");
        Console.WriteLine("");
        Console.WriteLine("The splash option centers the image horizontally at 256 pixels wide");
        Console.WriteLine("Image width must be max 256 pixels");
        Console.WriteLine("Image height must be max 212 pixels");
        Environment.Exit(1);
    }

    private static void Banner()
    {
        Console.WriteLine("png2msxSc8 - Convert PNG to MSX Screen 8 format");
        Console.WriteLine("------------------------------------------------");
        Console.WriteLine("Converting a png image of 256x192 pixels into ");
        Console.WriteLine("msx screen 8 bytes.");
    }

    private static void WriteBloadHeader(FileStream handle, long startadres, long endadres, long runadres = 0)
    {
        runadres = (runadres == 0) ? startadres : 0;

        handle.WriteByte(0xFE);
        // start address
        handle.WriteByte((byte)(startadres & 0xFF));
        handle.WriteByte((byte)(startadres >> 8 & 0xFF));
        // end address
        handle.WriteByte((byte)(endadres & 0xFF));
        handle.WriteByte((byte)(endadres >> 8 & 0xFF));
        // start of program 
        handle.WriteByte((byte)(runadres & 0xFF));
        handle.WriteByte((byte)(runadres >> 8 & 0xFF));
    }

    private static void testPattern()
    {
        var handle = File.OpenWrite("pattern.bi8");
        WriteBloadHeader(handle,0, 256*212);

        byte y = 0;
        y = HalfTest(handle, y, 0);
        y = HalfTest(handle, y, 2);

        while (y <= 212)
        {
            for (int x = 0; x < 256; x++)
            {
                handle.WriteByte(0xFF);
            }
            y++;
        }

        handle.Close();
        Environment.Exit(1);
    }

    private static byte HalfTest(FileStream handle, byte y, byte bluestart)
    {
        for (byte rood = 0; rood < 8; rood++)
        {
            for (int j = 0; j < 9; j++)
            {
                int x = 0;
                for (byte blauw = 0; blauw < 2; blauw++)
                {
                    for (byte groen = 0; groen < 8; groen++)
                    {
                        byte color = (byte)(groen << 5 | rood << 2 | (blauw + bluestart));
                        for (int i = 0; i < 9; i++)
                        {
                            handle.WriteByte(color);
                            x++;
                        }
                        handle.WriteByte(0xFF);
                        x++;
                    }
                    for (int i = 0; i < 9; i++)
                    {
                        handle.WriteByte(0xFF);
                        x++;
                    }
                }
                while (x < 256)
                {
                    handle.WriteByte(0xFF);
                    x++;
                }
                y++;
            }

            int xx = 0;
            while (xx < 256)
            {
                handle.WriteByte(0xFF);
                xx++;
            }
            y++;
        }
        return y;
    }


    [SupportedOSPlatform("windows")]
    private static void Main(string[] args)
    {
        Banner();

        if (args.Length < 1 || args.Length > 3)
        {
            Help();
        }

        // check file
        var infile = args[0];
        if (infile.ToLower() == "test")
        {
            testPattern();
        }
        var image = (Bitmap)Image.FromFile(infile, true);
        if (image.Width > 256 || image.Height > 212)
        {
            Help();
        }

        // initialize
        var outfile = Path.ChangeExtension(infile, "sc8");
        var startarg = "";
        var useBload = false;
        if (args.Length > 1 && args[1].Length == 4)
        {
            startarg = args[1];
            useBload = true;
            outfile = Path.ChangeExtension(infile, "bi8");
        }
        var isSplash = args.Length > 2;
        

        var width = isSplash ? 256 : image.Width;
        var borderL = isSplash ? (256 - image.Width) / 2 : 0;
        var borderR = isSplash ? 256 - image.Width - borderL : 0;
        var borderColor = isSplash ? Convert.ToByte(startarg, 16) : (byte)0x00;

        var handle = File.OpenWrite(outfile);
        if (useBload)
        {
            long startadres = Convert.ToInt32(startarg, 16);
            long endadres = startadres + width * image.Height;
            WriteBloadHeader(handle, startadres, endadres);
        }

        for (int y = 0; y < image.Height; y++)
        {
            for (int x = 0; x < borderL; x++)
            {
                handle.WriteByte(borderColor);
            }

            for (int x = 0; x < image.Width; x++)
            {
                var pixel = image.GetPixel(x, y);
                var r = (byte)(pixel.R / 32);
                var g = (byte)(pixel.G / 32);
                var b = (byte)(pixel.B / 64);
                var color = (byte)(g << 5 | r << 2 | b);

                handle.WriteByte(color);
            }

            for (int x = 0; x < borderR; x++)
            {
                handle.WriteByte(borderColor);
            }
        }
        handle.Close();
    }
}