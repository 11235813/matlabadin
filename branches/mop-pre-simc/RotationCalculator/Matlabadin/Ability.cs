﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    /// <summary>
    /// Defines a list of all possible abilities that can be used
    /// </summary>
    public enum Ability
    {
        /// <summary>
        /// Special case ability: do nothing
        /// </summary>
        Nothing, // modelled as an off-GCD 1 step cast time ability
        SotR,
        WoG,
        EF,
        FoL,
        HotR, // treated as a special case since it is linked with CS
        CooldownIndicator, // Abilities MUST be separated into those without cooldowns (above) and those with cooldowns (below)
        CS,
        J,
        HoW,
        AS,
        Cons,
        HW,
        AW,
        HPr, // Holy Prism, L90 talent
        HPrSC, //Holy Prism, self-cast
        LH, // Light's Hammer, L90 talent
        ES, // Execution Sentence, L90 talent
        HA, // Holy Avenger, L75 talent
        SS,
        Count,
    }
}