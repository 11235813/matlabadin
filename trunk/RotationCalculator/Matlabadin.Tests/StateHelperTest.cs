using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Matlabadin.Tests
{
    [TestClass]
    public class StateHelperTest : MatlabadinTest
    {
        [TestMethod]
        public void HolyPowerShouldUseLowestBits()
        {
            Assert.AreEqual(0, StateHelper.HP(0, DefaultParameters));
            Assert.AreEqual(1, StateHelper.HP(1, DefaultParameters));
            Assert.AreEqual(2, StateHelper.HP(2, DefaultParameters));
            Assert.AreEqual(3, StateHelper.HP(3, DefaultParameters));
        }
        [TestMethod]
        public void IncHolyPowerShouldCapAt3()
        {
            Assert.AreEqual(1, StateHelper.HP(StateHelper.IncHP(0, DefaultParameters), DefaultParameters));
            Assert.AreEqual(2, StateHelper.HP(StateHelper.IncHP(1, DefaultParameters), DefaultParameters));
            Assert.AreEqual(3, StateHelper.HP(StateHelper.IncHP(2, DefaultParameters), DefaultParameters));
            Assert.AreEqual(3, StateHelper.HP(StateHelper.IncHP(3, DefaultParameters), DefaultParameters));
        }
        [TestMethod]
        public void CooldownRemainingShouldReturnZeroForNoCDAbilities()
        {
            Assert.AreEqual(0, StateHelper.CooldownRemaining(0, Ability.SotR, DefaultParameters));
        }
        [TestMethod]
        public void TimeRemainingShouldRoundTrip()
        {
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                Buff b = (Buff)i;
                for (int j = 0; j <= DefaultParameters.BuffDurationInSteps(b); j++) {
                    Assert.AreEqual(j, StateHelper.TimeRemaining(StateHelper.SetTimeRemaining(0, b, j, DefaultParameters), b, DefaultParameters));
                }
            }
        }
        [TestMethod]
        public void CooldownRemainingShouldRoundTrip()
        {
            foreach (Ability a in new Ability[] {
                Ability.WoG,
                Ability.CS,
                Ability.J,
                Ability.AS,
                Ability.Cons,
                Ability.HW,
                Ability.HoW, })
            {
                for (int j = 0; j <= DefaultParameters.AbilityCooldownInSteps(a); j++)
                {
                    Assert.AreEqual(j, StateHelper.CooldownRemaining(StateHelper.SetCooldownRemaining(0, a, j, DefaultParameters), a, DefaultParameters));
                }
            }
        }
        [TestMethod]
        public void HotRAndCSShouldShareCD()
        {
            Assert.AreEqual(1, StateHelper.CooldownRemaining(StateHelper.SetCooldownRemaining(0, Ability.CS, 1, DefaultParameters), Ability.HotR, DefaultParameters));
            Assert.AreEqual(1, StateHelper.CooldownRemaining(StateHelper.SetCooldownRemaining(0, Ability.HotR, 1, DefaultParameters), Ability.CS, DefaultParameters));
        }
        [TestMethod]
        public void AdvanceTimeShouldReduceCDDuration()
        {
            Assert.AreEqual(1, StateHelper.CooldownRemaining(StateHelper.AdvanceTime(GetState(Ability.CS, 3), 2, DefaultParameters), Ability.CS, DefaultParameters));
            Assert.AreEqual(0, StateHelper.CooldownRemaining(StateHelper.AdvanceTime(GetState(Ability.CS, 3), 5, DefaultParameters), Ability.CS, DefaultParameters));
        }
        [TestMethod]
        public void AdvanceTimeShouldReduceBuffDuration()
        {
            Assert.AreEqual(1, StateHelper.TimeRemaining(StateHelper.AdvanceTime(GetState(Buff.Inq, 3), 2, DefaultParameters), Buff.Inq, DefaultParameters));
            Assert.AreEqual(0, StateHelper.TimeRemaining(StateHelper.AdvanceTime(GetState(Buff.Inq, 3), 5, DefaultParameters), Buff.Inq, DefaultParameters));
        }
        [TestMethod]
        public void AdvanceTimeShouldNotChangeHP()
        {
            Assert.AreEqual(3, StateHelper.HP(StateHelper.AdvanceTime(3, 100, DefaultParameters), DefaultParameters));
        }
        [TestMethod]
        public void UseAbilityShouldSetAbilityCDAndAdvanceOneGCD()
        {
            foreach (Ability a in new Ability[] {
                Ability.Nothing,
                Ability.Inq,
                Ability.SotR,
                Ability.HotR,
                Ability.WoG,
                Ability.CS,
                Ability.J,
                Ability.AS,
                Ability.Cons,
                Ability.HW,
                Ability.HoW,
            })
            {
                Assert.AreEqual(Math.Max(0, DefaultParameters.AbilityCooldownInSteps(a) - 3), StateHelper.CooldownRemaining(StateHelper.UseAbility(0, DefaultParameters, a), a, DefaultParameters));
            }
        }
        [TestMethod]
        public void UseAbility_CSShouldGiveHPOnHitOnly()
        {
            Assert.AreEqual(1, StateHelper.HP(StateHelper.UseAbility(0, DefaultParameters, Ability.CS, hit: true), DefaultParameters));
            Assert.AreEqual(0, StateHelper.HP(StateHelper.UseAbility(0, DefaultParameters, Ability.CS, hit: false), DefaultParameters));
        }
        [TestMethod]
        public void UseAbility_HPShouldCapAt3()
        {
            Assert.AreEqual(3, StateHelper.HP(StateHelper.UseAbility(3, DefaultParameters, Ability.CS, hit: true), DefaultParameters));
            Assert.AreEqual(3, StateHelper.HP(StateHelper.UseAbility(GetState(Buff.GC, 1, 3), DefaultParameters, Ability.AS, hit: true), DefaultParameters));
        }
        [TestMethod]
        public void UseAbility_HotRShouldGiveHPOnHitOnly()
        {
            Assert.AreEqual(1, StateHelper.HP(StateHelper.UseAbility(0, DefaultParameters, Ability.HotR, hit: true), DefaultParameters));
            Assert.AreEqual(0, StateHelper.HP(StateHelper.UseAbility(0, DefaultParameters, Ability.HotR, hit: false), DefaultParameters));
        }
        [TestMethod]
        public void UseAbility_SotRShouldConsumeHPOnHitOnly()
        {
            Assert.AreEqual(0, StateHelper.HP(StateHelper.UseAbility(2, DefaultParameters, Ability.SotR, hit: true), DefaultParameters));
            Assert.AreEqual(2, StateHelper.HP(StateHelper.UseAbility(2, DefaultParameters, Ability.SotR, hit: false), DefaultParameters));
        }
        [TestMethod]
        public void UseAbility_WoGShouldConsumeHP()
        {
            Assert.AreEqual(0, StateHelper.HP(StateHelper.UseAbility(2, DefaultParameters, Ability.WoG), DefaultParameters));
        }
        [TestMethod]
        public void UseAbility_WoGEGShouldNotConsumeHP()
        {
            Assert.AreEqual(3, StateHelper.HP(StateHelper.UseAbility(3, DefaultParameters, Ability.WoG, egProc: true), DefaultParameters));
        }
        [TestMethod]
        public void UseAbility_WoGEGShouldSetICD()
        {
            Assert.AreNotEqual(0, StateHelper.TimeRemaining(StateHelper.UseAbility(3, DefaultParameters, Ability.WoG, egProc: true), Buff.EGICD, DefaultParameters));
        }
        [TestMethod]
        public void UseAbility_InqShouldConsumeHP()
        {
            Assert.AreEqual(0, StateHelper.HP(StateHelper.UseAbility(2, DefaultParameters, Ability.Inq), DefaultParameters));
        }
        [TestMethod]
        public void UseAbility_InqDurationShouldBeDeterminedByHP()
        {
            Assert.AreEqual(12 * 2 - 3, StateHelper.TimeRemaining(StateHelper.UseAbility(3, DefaultParameters, Ability.Inq), Buff.Inq, DefaultParameters));
            Assert.AreEqual(8 * 2 - 3, StateHelper.TimeRemaining(StateHelper.UseAbility(2, DefaultParameters, Ability.Inq), Buff.Inq, DefaultParameters));
            Assert.AreEqual(4 * 2 - 3, StateHelper.TimeRemaining(StateHelper.UseAbility(1, DefaultParameters, Ability.Inq), Buff.Inq, DefaultParameters));
        }
        [TestMethod]
        public void UseAbility_SDBuffShouldBeSetForSDProc()
        {
            Assert.AreNotEqual(0, StateHelper.TimeRemaining(StateHelper.UseAbility(0, DefaultParameters, Ability.J, hit:true, sdProc: true), Buff.SD, DefaultParameters));
            Assert.AreNotEqual(0, StateHelper.TimeRemaining(StateHelper.UseAbility(0, DefaultParameters, Ability.AS, hit: true, sdProc: true), Buff.SD, DefaultParameters));
        }
        [TestMethod]
        public void UseAbility_SDShouldResetSDDuration()
        {
            Assert.AreNotEqual(1, StateHelper.TimeRemaining(StateHelper.UseAbility(GetState(Buff.SD, 4), DefaultParameters, Ability.J, hit: true, sdProc: true), Buff.SD, DefaultParameters));
            Assert.AreNotEqual(1, StateHelper.TimeRemaining(StateHelper.UseAbility(GetState(Buff.SD, 4), DefaultParameters, Ability.AS, hit: true, sdProc: true), Buff.SD, DefaultParameters));
        }
        [TestMethod]
        public void UseAbility_GCSProcShouldSetGCBuff()
        {
            Assert.AreNotEqual(0, StateHelper.TimeRemaining(StateHelper.UseAbility(0, DefaultParameters, Ability.CS, hit: true, gcProc: true), Buff.GC, DefaultParameters));
        }
        [TestMethod]
        public void UseAbility_GCUseShouldConsumeGC()
        {
            Assert.AreEqual(0, StateHelper.TimeRemaining(StateHelper.UseAbility(GetState(Buff.GC, 4), DefaultParameters, Ability.AS, hit: true), Buff.GC, DefaultParameters));
        }
        [TestMethod]
        public void UseAbility_ASShouldGiveHP() // UseAbility_ASShouldGiveHPIffGCActiveAndHit() // 4.1 patch change: AS cast on-hit
        {
            Assert.AreEqual(0, StateHelper.HP(StateHelper.UseAbility(0, DefaultParameters, Ability.AS, hit: true), DefaultParameters));
            Assert.AreEqual(0, StateHelper.HP(StateHelper.UseAbility(0, DefaultParameters, Ability.AS, hit: false), DefaultParameters));
            Assert.AreEqual(1, StateHelper.HP(StateHelper.UseAbility(GetState(Buff.GC, 1), DefaultParameters, Ability.AS, hit: true), DefaultParameters));
            Assert.AreEqual(1, StateHelper.HP(StateHelper.UseAbility(GetState(Buff.GC, 1), DefaultParameters, Ability.AS, hit: false), DefaultParameters));
        }
        [TestMethod]
        public void UseAbility_ASMissShouldConsumeGC()
        {
            var state = StateHelper.UseAbility(GetState(Buff.GC, 4), DefaultParameters, Ability.AS, hit: false);
            Assert.AreEqual(0, StateHelper.TimeRemaining(state, Buff.GC, DefaultParameters));
        }
        [TestMethod]
        public void UseAbility_ASHitShouldConsumeGC()
        {
            Assert.AreEqual(0, StateHelper.TimeRemaining(StateHelper.UseAbility(GetState(Buff.GC, 4), DefaultParameters, Ability.AS, hit: true), Buff.GC, DefaultParameters));
        }
    }
}
