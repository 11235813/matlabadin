using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Matlabadin.Tests
{
    [TestClass]
    public abstract class StateManagerTest<SM, T> : MatlabadinTest
        where SM : IStateManager<T>
    {
        public abstract SM StateManager { get; }
        [TestMethod]
        public void IncHolyPowerShouldCapAt5()
        {
            Assert.AreEqual(1, StateManager.HP(StateManager.IncHP(StateManager.SetHP(StateManager.InitialState(), 0))));
            Assert.AreEqual(2, StateManager.HP(StateManager.IncHP(StateManager.SetHP(StateManager.InitialState(), 1))));
            Assert.AreEqual(3, StateManager.HP(StateManager.IncHP(StateManager.SetHP(StateManager.InitialState(), 2))));
            Assert.AreEqual(4, StateManager.HP(StateManager.IncHP(StateManager.SetHP(StateManager.InitialState(), 3))));
            Assert.AreEqual(5, StateManager.HP(StateManager.IncHP(StateManager.SetHP(StateManager.InitialState(), 4))));
            Assert.AreEqual(5, StateManager.HP(StateManager.IncHP(StateManager.SetHP(StateManager.InitialState(), 5))));
        }
        [TestMethod]
        public void HPShouldRoundTrip()
        {
            Assert.AreEqual(0, StateManager.HP(StateManager.SetHP(StateManager.InitialState(), 0)));
            Assert.AreEqual(1, StateManager.HP(StateManager.SetHP(StateManager.InitialState(), 1)));
            Assert.AreEqual(2, StateManager.HP(StateManager.SetHP(StateManager.InitialState(), 2)));
            Assert.AreEqual(3, StateManager.HP(StateManager.SetHP(StateManager.InitialState(), 3)));
            Assert.AreEqual(4, StateManager.HP(StateManager.SetHP(StateManager.InitialState(), 4)));
            Assert.AreEqual(5, StateManager.HP(StateManager.SetHP(StateManager.InitialState(), 5)));
        }
        [TestMethod]
        public void CooldownRemainingShouldReturnZeroForNoCDAbilities()
        {
            Assert.AreEqual(0, StateManager.CooldownRemaining(StateManager.InitialState(), Ability.SotR));
            Assert.AreEqual(0, StateManager.CooldownRemaining(StateManager.InitialState(), Ability.WoG));
        }
        [TestMethod]
        public void TimeRemainingShouldRoundTrip()
        {
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                Buff b = (Buff)i;
                for (int j = 0; j <= 5; j++)
                {
                    Assert.AreEqual(j, StateManager.TimeRemaining(StateManager.SetTimeRemaining(StateManager.InitialState(), b, j), b));
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
                Ability.Cons
            })
            {
                for (int j = 0; j <= 5; j++)
                {
                    Assert.AreEqual(j, StateManager.CooldownRemaining(StateManager.SetCooldownRemaining(StateManager.InitialState(), a, j), a));
                }
            }
        }
        [TestMethod]
        public void HotRAndCSShouldShareCD()
        {
            Assert.AreEqual(3, StateManager.CooldownRemaining(StateManager.SetCooldownRemaining(StateManager.InitialState(), Ability.CS, 3), Ability.HotR));
            Assert.AreEqual(3, StateManager.CooldownRemaining(StateManager.SetCooldownRemaining(StateManager.InitialState(), Ability.HotR, 3), Ability.CS));
        }
        [TestMethod]
        public void AdvanceTimeShouldReduceCDDuration()
        {
            Assert.AreEqual(1, StateManager.CooldownRemaining(
                StateManager.AdvanceTime(StateManager.SetCooldownRemaining(StateManager.InitialState(), Ability.CS, 3), 2),
                Ability.CS));
            Assert.AreEqual(3, StateManager.CooldownRemaining(
                StateManager.AdvanceTime(StateManager.SetCooldownRemaining(StateManager.InitialState(), Ability.CS, 5), 2),
                Ability.CS));
            Assert.AreEqual(0, StateManager.CooldownRemaining(
                StateManager.AdvanceTime(StateManager.SetCooldownRemaining(StateManager.InitialState(), Ability.CS, 1), 2),
                Ability.CS));
        }
        [TestMethod]
        public void AdvanceTimeShouldReduceBuffDuration()
        {
            Assert.AreEqual(1, StateManager.TimeRemaining(
                StateManager.AdvanceTime(StateManager.SetTimeRemaining(StateManager.InitialState(), Buff.GC, 3), 2),
                Buff.GC));
            Assert.AreEqual(3, StateManager.TimeRemaining(
                StateManager.AdvanceTime(StateManager.SetTimeRemaining(StateManager.InitialState(), Buff.GC, 5), 2),
                Buff.GC));
            Assert.AreEqual(0, StateManager.TimeRemaining(
                StateManager.AdvanceTime(StateManager.SetTimeRemaining(StateManager.InitialState(), Buff.GC, 1), 2),
                Buff.GC));
        }
        [TestMethod]
        public void AdvanceTimeShouldNotChangeHP()
        {
            Assert.AreEqual(3, StateManager.HP(StateManager.AdvanceTime(StateManager.SetHP(StateManager.InitialState(), 3), 100)));
        }
        [TestMethod]
        public void ZeroCooldownRemainingForAllAbilities_ShouldBeTrueIffAllAbilitiesAreOffCD()
        {
            Assert.IsTrue(StateManager.ZeroCooldownRemainingForAllAbilities(StateManager.InitialState()));
            Assert.IsTrue(StateManager.ZeroCooldownRemainingForAllAbilities(StateManager.SetHP(StateManager.InitialState(), 1)));
            Assert.IsTrue(StateManager.ZeroCooldownRemainingForAllAbilities(StateManager.SetHP(StateManager.InitialState(), 2)));
            Assert.IsTrue(StateManager.ZeroCooldownRemainingForAllAbilities(StateManager.SetHP(StateManager.InitialState(), 3)));
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                Assert.IsTrue(StateManager.ZeroCooldownRemainingForAllAbilities(StateManager.SetTimeRemaining(StateManager.InitialState(), (Buff)i, 1)));
            }
            for (int i = (int)Ability.CooldownIndicator + 1; i < (int)Ability.Count; i++)
            {
                Assert.IsFalse(StateManager.ZeroCooldownRemainingForAllAbilities(StateManager.SetCooldownRemaining(StateManager.InitialState(), (Ability)i, 1)));
            }
            Assert.IsFalse(StateManager.ZeroCooldownRemainingForAllAbilities(
                StateManager.SetCooldownRemaining(StateManager.SetCooldownRemaining(StateManager.InitialState(), Ability.Cons, 1), Ability.CS, 1)
                ));
        }
    }
}
