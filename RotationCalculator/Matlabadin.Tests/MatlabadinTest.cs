using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin.Tests
{
    public class MatlabadinTest
    {
        public static ulong GetState(IStateManager<ulong> sm, Ability ability, int cd, ulong hp = 0)
        {
            return sm.SetCooldownRemaining((ulong)hp, ability, cd);
        }
        public static ulong GetState(IStateManager<ulong> sm, Ability ability, int cd, Ability ability2, int cd2, ulong hp = 0)
        {
            return sm.SetCooldownRemaining(GetState(sm, ability2, cd2, hp), ability, cd);
        }
        public static ulong GetState(IStateManager<ulong> sm, Ability ability, int cd, Ability ability2, int cd2, Ability ability3, int cd3, ulong hp = 0)
        {
            return sm.SetCooldownRemaining(GetState(sm, ability2, cd2, ability3, cd3, hp), ability, cd);
        }
        public static ulong GetState(IStateManager<ulong> sm, Buff buff1, int cd1, ulong hp = 0)
        {
            return sm.SetTimeRemaining((ulong)hp, buff1, cd1);
        }
        public static ulong GetState(IStateManager<ulong> sm, Buff buff1, int cd1, Buff buff2, int cd2, ulong hp = 0)
        {
            return sm.SetTimeRemaining(GetState(sm, buff1, cd1, hp), buff2, cd2);
        }
        public static ulong GetState(IStateManager<ulong> sm, Buff buff1, int cd1, Buff buff2, int cd2, Buff buff3, int cd3, ulong hp = 0)
        {
            return sm.SetTimeRemaining(GetState(sm, buff1, cd1, buff2, cd2, hp), buff3, cd3);
        }
        public static Int64GraphParameters NoMiss(string rotation)
        {
            return new Int64GraphParameters(new RotationPriorityQueue<ulong>(rotation), 3, 1, 1);
        }
        public static Int64GraphParameters NoHitExpertise(string rotation)
        {
            return new Int64GraphParameters(new RotationPriorityQueue<ulong>(rotation), 3, 1 - 0.08 - 0.065 - 0.14, 1 - 0.08);
        }
        public static RotationPriorityQueue<ulong> AllAbilityRotation { get { return defaultParameters.Rotation; } }
        public static IStateManager<ulong> AllAbilityStateManager { get { return defaultParameters; } }
        public static Int64GraphParameters AllAbilityGraphParameters { get { return defaultParameters; } }
        // Short-hand defaults tests where we just need a parameter passed and we don't particularly care what it contains
        public static RotationPriorityQueue<ulong> R { get { return AllAbilityRotation; } }
        public static IStateManager<ulong> SM { get { return AllAbilityStateManager; } }
        public static Int64GraphParameters GP { get { return AllAbilityGraphParameters; } }
        private static Int64GraphParameters defaultParameters = NoHitExpertise("SS>EF>SotR>HotR>WoG>CS>J>AS>Cons");
    }
}
