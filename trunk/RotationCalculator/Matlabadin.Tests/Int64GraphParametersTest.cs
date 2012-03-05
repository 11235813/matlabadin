﻿using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Matlabadin.Tests
{
    [TestClass]
    public class Int64GraphParametersTest : MatlabadinTest
    {
        [TestMethod]
        public void HolyPowerShouldUseLowestBits()
        {
            Assert.AreEqual(0, AllAbilityStateManager.HP(0));
            Assert.AreEqual(1, AllAbilityStateManager.HP(1));
            Assert.AreEqual(2, AllAbilityStateManager.HP(2));
            Assert.AreEqual(3, AllAbilityStateManager.HP(3));
        }
        [TestMethod]
        public void IncHolyPowerShouldCapAt5()
        {
            Assert.AreEqual(1, AllAbilityStateManager.HP(AllAbilityStateManager.IncHP(0)));
            Assert.AreEqual(2, AllAbilityStateManager.HP(AllAbilityStateManager.IncHP(1)));
            Assert.AreEqual(3, AllAbilityStateManager.HP(AllAbilityStateManager.IncHP(2)));
            Assert.AreEqual(4, AllAbilityStateManager.HP(AllAbilityStateManager.IncHP(3)));
            Assert.AreEqual(5, AllAbilityStateManager.HP(AllAbilityStateManager.IncHP(4)));
            Assert.AreEqual(5, AllAbilityStateManager.HP(AllAbilityStateManager.IncHP(5)));
        }
        [TestMethod]
        public void CooldownRemainingShouldReturnZeroForNoCDAbilities()
        {
            Assert.AreEqual(0, AllAbilityStateManager.CooldownRemaining(0, Ability.SotR));
        }
        [TestMethod]
        public void CalculateBitOffsetsShouldPackAbilitiesAfterHP()
        {
            Int64GraphParameters target = new Int64GraphParameters(R, 3, 0, 0);
            Assert.AreEqual(3, target.AbilityCooldownStartBit[(int)Ability.CS]); // 3 bits for HP
            Assert.AreEqual(4, target.AbilityCooldownBits[(int)Ability.CS]); // 4.5s = 9 + 1 steps = 4 bits
            Assert.AreEqual(7, target.AbilityCooldownStartBit[(int)Ability.J]);
            Assert.AreEqual(4, target.AbilityCooldownBits[(int)Ability.J]); // 6s = 12 + 1 steps = 4 bits
        }
        [TestMethod]
        public void NoCDShouldHaveZeroBitSize()
        {
            Int64GraphParameters target = new Int64GraphParameters(R, 3, 0, 0);
            Assert.AreEqual(0, target.AbilityCooldownBits[(int)Ability.SotR]);
            Assert.AreEqual(0, target.AbilityCooldownBits[(int)Ability.WoG]);
        }
        [TestMethod]
        public void HotRShouldHaveSameBitsAsCS()
        {
            Int64GraphParameters target = new Int64GraphParameters(R, 3, 0, 0);
            Assert.AreEqual(target.AbilityCooldownStartBit[(int)Ability.HotR], target.AbilityCooldownStartBit[(int)Ability.CS]);
            Assert.AreEqual(target.AbilityCooldownBits[(int)Ability.HotR], target.AbilityCooldownBits[(int)Ability.CS]);
        }
        [TestMethod]
        public void UnusedAbilitiesShouldHaveZeroBitSize()
        {
            // state space compression:
            Int64GraphParameters target = new Int64GraphParameters(new RotationPriorityQueue<ulong>("CS>J"), 3, 0, 0);
            Assert.AreEqual(0, target.AbilityCooldownBits[(int)Ability.Cons]);
            Assert.AreEqual(0, target.AbilityCooldownBits[(int)Ability.AS]);
            Assert.AreNotEqual(0, target.AbilityCooldownBits[(int)Ability.CS]);
            Assert.AreNotEqual(0, target.AbilityCooldownBits[(int)Ability.J]);

            // Don't break CS if we have HotR in the rotation
            target = new Int64GraphParameters(new RotationPriorityQueue<ulong>("HotR"), 3, 0, 0);
            Assert.AreNotEqual(0, target.AbilityCooldownBits[(int)Ability.CS]);
        }
        [TestMethod]
        public void TimeRemainingShouldRoundTrip()
        {
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                Buff b = (Buff)i;
                for (int j = 0; j <= AllAbilityGraphParameters.BuffDurationInSteps(b); j++) {
                    Assert.AreEqual(j, AllAbilityStateManager.TimeRemaining(AllAbilityStateManager.SetTimeRemaining(0, b, j), b));
                }
            }
        }
        [TestMethod]
        public void CooldownRemainingShouldRoundTrip()
        {
            foreach (Ability a in new Ability[] {
                Ability.CS,
                Ability.J,
                Ability.AS,
                Ability.Cons,
                })
            {
                for (int j = 0; j <= AllAbilityGraphParameters.AbilityCooldownInSteps(a); j++)
                {
                    Assert.AreEqual(j, SM.CooldownRemaining(SM.SetCooldownRemaining(0, a, j), a));
                }
            }
        }
        [TestMethod]
        public void HotRAndCSShouldShareCD()
        {
            Assert.AreEqual(1, SM.CooldownRemaining(SM.SetCooldownRemaining(0, Ability.CS, 1), Ability.HotR));
            Assert.AreEqual(1, SM.CooldownRemaining(SM.SetCooldownRemaining(0, Ability.HotR, 1), Ability.CS));
        }
        [TestMethod]
        public void AdvanceTimeShouldReduceCDDuration()
        {
            Assert.AreEqual(1, SM.CooldownRemaining(SM.AdvanceTime(GetState(SM, Ability.CS, 3), 2), Ability.CS));
            Assert.AreEqual(0, SM.CooldownRemaining(SM.AdvanceTime(GetState(SM, Ability.CS, 3), 5), Ability.CS));
        }
        [TestMethod]
        public void AdvanceTimeShouldReduceBuffDuration()
        {
            Assert.AreEqual(1, SM.TimeRemaining(SM.AdvanceTime(GetState(SM, Buff.GC, 3), 2), Buff.GC));
            Assert.AreEqual(0, SM.TimeRemaining(SM.AdvanceTime(GetState(SM, Buff.GC, 3), 5), Buff.GC));
        }
        [TestMethod]
        public void AdvanceTimeShouldNotChangeHP()
        {
            Assert.AreEqual(3, SM.HP(SM.AdvanceTime(3, 100)));
        }
    }
}
