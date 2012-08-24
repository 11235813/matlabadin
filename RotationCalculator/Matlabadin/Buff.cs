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
        /// Avenging Wrath
        /// </summary>
        AW,
        /// <summary>
        /// SotR Shield Block buff
        /// </summary>
        SotRSB,
        /// <summary>
        /// Weakened Blows
        /// </summary>
        WB,
        /// <summary>
        /// Glyph of WoG
        /// </summary>
        GoWoG,
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
        /// <summary>
        /// Bastion of Glory
        /// </summary>
        BoG,
        /// <summary>
        /// Divine Purpose
        /// </summary>
        DP,
        /// <summary>
        /// Holy Avenger
        /// </summary>
        HA,
        Count,
        UptimeTrackedBuffs = GoWoG + 1,
    }
}
