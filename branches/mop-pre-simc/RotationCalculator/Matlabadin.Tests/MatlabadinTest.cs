using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin.Tests
{
    public class MatlabadinTest
    {
        public static BitVectorState GetState(IStateManager<BitVectorState> sm, Ability ability, int cd)
        {
            return GetState(sm, ability, cd, new BitVectorState());
        }
        public static BitVectorState GetState(IStateManager<BitVectorState> sm, Ability ability, int cd, BitVectorState state)
        {
            return sm.SetCooldownRemaining(state, ability, cd);
        }
        public static BitVectorState GetState(IStateManager<BitVectorState> sm, Ability ability, int cd, Ability ability2, int cd2)
        {
            return GetState(sm, ability, cd, ability2, cd2, new BitVectorState());
        }
        public static BitVectorState GetState(IStateManager<BitVectorState> sm, Ability ability, int cd, Ability ability2, int cd2, BitVectorState hp)
        {
            return sm.SetCooldownRemaining(GetState(sm, ability2, cd2, hp), ability, cd);
        }
        public static BitVectorState GetState(IStateManager<BitVectorState> sm, Ability ability, int cd, Ability ability2, int cd2, Ability ability3, int cd3)
        {
            return GetState(sm, ability, cd, ability2, cd2, ability3, cd3, new BitVectorState());
        }
        public static BitVectorState GetState(IStateManager<BitVectorState> sm, Ability ability, int cd, Ability ability2, int cd2, Ability ability3, int cd3, BitVectorState state)
        {
            return sm.SetCooldownRemaining(GetState(sm, ability2, cd2, ability3, cd3, state), ability, cd);
        }
        public static BitVectorState GetState(IStateManager<BitVectorState> sm, Buff buff1, int cd1)
        {
            return GetState(sm, buff1, cd1, new BitVectorState());
        }
        public static BitVectorState GetState(IStateManager<BitVectorState> sm, Buff buff1, int cd1, BitVectorState state)
        {
            return sm.SetTimeRemaining(state, buff1, cd1);
        }
        public static BitVectorState GetState(IStateManager<BitVectorState> sm, int stacks, Buff buff1, int cd1)
        {
            return GetState(sm, stacks, buff1, cd1, new BitVectorState());
        }
        public static BitVectorState GetState(IStateManager<BitVectorState> sm, int stacks, Buff buff1, int cd1, BitVectorState hp)
        {
            return sm.SetStacks(sm.SetTimeRemaining(hp, buff1, cd1), buff1, stacks);
        }
        public static BitVectorState GetState(IStateManager<BitVectorState> sm, Buff buff1, int cd1, Buff buff2, int cd2)
        {
            return GetState(sm, buff1, cd1, buff2, cd2, new BitVectorState());
        }
        public static BitVectorState GetState(IStateManager<BitVectorState> sm, Buff buff1, int cd1, Buff buff2, int cd2, BitVectorState hp)
        {
            return sm.SetTimeRemaining(GetState(sm, buff1, cd1, hp), buff2, cd2);
        }
        public static BitVectorState GetState(IStateManager<BitVectorState> sm, Buff buff1, int cd1, Buff buff2, int cd2, Buff buff3, int cd3)
        {
            return GetState(sm, buff1, cd1, buff2, cd2, buff3, cd3, new BitVectorState());
        }
        public static BitVectorState GetState(IStateManager<BitVectorState> sm, Buff buff1, int cd1, Buff buff2, int cd2, Buff buff3, int cd3, BitVectorState hp)
        {
            return sm.SetTimeRemaining(GetState(sm, buff1, cd1, buff2, cd2, hp), buff3, cd3);
        }
        public static Int64GraphParameters NoMiss(string rotation, int steps = 3, double haste = 0)
        {
            return new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>(rotation), PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.GoWoG, steps, haste, haste, 1, 1);
        }
        public static Int64GraphParameters NoMissNoTalents(string rotation, int steps = 3, double haste = 0)
        {
            return new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>(rotation), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, steps, haste, haste, 1, 1);
        }
        public static Int64GraphParameters NoHitExpertise(string rotation, int steps = 3, double haste = 0)
        {
            return new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>(rotation), PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.GoWoG, steps, haste, haste, 1 - 0.08 - 0.065 - 0.14, 1 - 0.08);
        }
        public static RotationPriorityQueue<BitVectorState> AllAbilityRotation { get { return defaultParameters.Rotation; } }
        public static IStateManager<BitVectorState> AllAbilityStateManager { get { return defaultParameters; } }
        public static Int64GraphParameters AllAbilityGraphParameters { get { return defaultParameters; } }
        // Short-hand defaults tests where we just need a parameter passed and we don't particularly care what it contains
        public static RotationPriorityQueue<BitVectorState> R { get { return AllAbilityRotation; } }
        public static IStateManager<BitVectorState> SM { get { return AllAbilityStateManager; } }
        public static Int64GraphParameters GP { get { return AllAbilityGraphParameters; } }
        public static Int64GraphParameters GPNoMiss { get { return NoMiss(AllAbilityRotation.PriorityQueue); } }
        public static Int64GraphParameters GPFullHaste { get { return NoMiss(AllAbilityRotation.PriorityQueue, 3, 0.5); } }
        private static Int64GraphParameters defaultParameters = NoHitExpertise("AW>SS>EF>SotR>HotR>WoG>CS>J>AS>Cons>HW>HoW>FoL>ES>LH>HPr");
    }
}
