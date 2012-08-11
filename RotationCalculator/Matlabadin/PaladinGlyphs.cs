using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    [Flags]
    public enum PaladinGlyphs
    {
        None = 0x0,
        GoHotR = 0x1,
        GoWoG = 0x2,
        All = 0x3, 
    }
    public static class PaladinGlyphsHelper
    {
        public static bool TryParse(string s, out PaladinGlyphs result)
        {
            if (String.IsNullOrWhiteSpace(s))
            {
                result = PaladinGlyphs.None;
                return true;
            }
            return Enum.TryParse<PaladinGlyphs>((s ?? "").Replace("|", ",").Replace(";", ",").Replace(":", ","), true, out result);
        }
        public static bool Includes(this PaladinGlyphs glyphs, PaladinGlyphs glyph)
        {
            return (glyphs & glyph) != PaladinGlyphs.None;
        }
        public static string ToLongString(this PaladinGlyphs g)
        {
            if (g == PaladinGlyphs.None) return "None";
            string s = "";
            for (int i = 1; i <= (int)g; i <<= 1)
            {
                PaladinGlyphs it = (PaladinGlyphs)i;
                if (g.Includes(it))
                {
                    s += it.ToString() + ';';
                }
            }
            return s.Trim(';');
        }
    }
}
