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
        // ----- buffs whose uptime depends on an ability outcome (eg WB depends on whether HotR hits or not) go between here and the untracked buffs marker -----  
        /// <summary>
        /// Weakened Blows
        /// </summary>
        WB,
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
        /// <summary>
        /// Glyph of WoG
        /// </summary>
        GoWoG,
        Count,
        UptimeTrackedUnforkedBuffs = SotRSB + 1,
        UptimeTrackedForkedBuffs = WB + 1,
        UptimeTrackedBuffs = WB + 1,
    }
}
