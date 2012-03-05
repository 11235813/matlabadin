using System;
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
        Nothing,
        Inq, // Inquisition removed in MoP
        SotR,
        HotR, // treated as a special case since it is linked with CS
        CooldownIndicator, // Abilities MUST be separated into those without cooldowns (above) and those with cooldowns (below)
        WoG,
        CS,
        J,
        AS,
        Cons,
        HW,
        HoW,
        Count,
    }
}
