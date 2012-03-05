using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    /// <summary>
    ///  Defines a list of all possible rotaiton-dependent self-buffs that can be used
    /// </summary>
    public enum Buff
    {
        /// <summary>
        /// Sacred Shield
        /// </summary>
        SS,
        /// <summary>
        /// Eternal Flame
        /// </summary>
        EF,
        /// <summary>
        /// Weakened Blows
        /// </summary>
        WB,
        /// <summary>
        /// SotR Shield Block buff
        /// </summary>
        SotRSB,
        UptimeTrackedBuffs = SotRSB + 1, // tracked buffs that we record and output go above this line
        /// <summary>
        /// Grand Crusader
        /// </summary>
        GC,
        // AW,
        // TODO: EF, Holy Avenger & Selfless Healer require stacks as well as a duration - these require extra state storage (similar to Holy Power).
        // HA, SH
        Count,
    }
}
