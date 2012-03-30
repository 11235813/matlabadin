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
        /// Global Cooldown tracked as a buff
        /// </summary>
        GCD,
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
        // ----- tracked buffs that we record and output go above this line ----- 
        // if you want to track additional buffs, UptimeTrackedBuffs needs to be changed
        /// <summary>
        /// Grand Crusader
        /// </summary>
        GC,
        /// <summary>
        /// Selfless Healer
        /// </summary>
        SH,
        // AW, HA
        Count,
        UptimeTrackedBuffs = SotRSB + 1,
    }
}
