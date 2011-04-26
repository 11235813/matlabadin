using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin.Tests
{
    public class MatlabadinTest
    {
        public ulong GetState(Ability ability, int cd, ulong hp = 0)
        {
            return StateHelper.SetCooldownRemaining((ulong)hp, ability, cd, DefaultParameters);
        }
        public ulong GetState(Ability ability, int cd, Ability ability2, int cd2, ulong hp = 0)
        {
            return StateHelper.SetCooldownRemaining(GetState(ability2, cd2, hp), ability, cd, DefaultParameters);
        }
        public ulong GetState(Ability ability, int cd, Ability ability2, int cd2, Ability ability3, int cd3, ulong hp = 0)
        {
            return StateHelper.SetCooldownRemaining(GetState(ability2, cd2, ability3, cd3, hp), ability, cd, DefaultParameters);
        }
        public ulong GetState(Buff buff1, int cd1, ulong hp = 0)
        {
            return StateHelper.SetTimeRemaining((ulong)hp, buff1, cd1, DefaultParameters);
        }
        public ulong GetState(Buff buff1, int cd1, Buff buff2, int cd2, ulong hp = 0)
        {
            return StateHelper.SetTimeRemaining(GetState(buff1, cd1, hp), buff2, cd2, DefaultParameters);
        }
        public ulong GetState(Buff buff1, int cd1, Buff buff2, int cd2, Buff buff3, int cd3, ulong hp = 0)
        {
            return StateHelper.SetTimeRemaining(GetState(buff1, cd1, buff2, cd2, hp), buff3, cd3, DefaultParameters);
        }
        public GraphParameters NoMissNoProcsParameters
        {
            get
            {
                return new GraphParameters(3, false, 1, 1, 0, 0, 0);
            }
        }
        public GraphParameters NoMissParameters
        {
            get
            {
                return new GraphParameters(3, false, 1, 1, 0.5, 0.20, 0.30);
            }
        }
        public GraphParameters DefaultParameters
        {
            get
            {
                return new GraphParameters(3, false, 1 - 0.08 - 0.065 - 0.14, 1 - 0.08, 0.5, 0.2, 0.3);
            }
        }
    }
}
