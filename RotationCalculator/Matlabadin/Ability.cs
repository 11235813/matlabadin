using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public enum Ability
    {
        Nothing,
        Inq,
        SotR,
        HotR, // treated as a special case
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
