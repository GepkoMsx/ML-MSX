using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace png2msxSc5;

public static class Extentions
{
    public static void Write(this FileStream handle, string text)
    {
        handle.Write(Encoding.ASCII.GetBytes(text));
    }
    public static void WriteLine(this FileStream handle, string text = "")
    {
        handle.Write(text + Environment.NewLine);
    }
}
