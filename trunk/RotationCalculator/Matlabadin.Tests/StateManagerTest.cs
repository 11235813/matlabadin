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
        public void IncHolyPowerShouldCapAt3()
        {
            Assert.AreEqual(1, StateManager.HP(StateManager.IncHP(StateManager.SetHP(StateManager.InitialState(), 0))));
            Assert.AreEqual(2, StateManager.HP(StateManager.IncHP(StateManager.SetHP(StateManager.InitialState(), 1))));
            Assert.AreEqual(3, StateManager.HP(StateManager.IncHP(StateManager.SetHP(StateManager.InitialState(), 2))));
            Assert.AreEqual(3, StateManager.HP(StateManager.IncHP(StateManager.SetHP(StateManager.InitialState(), 3))));
        }
        [TestMethod]
        public void HPShouldRoundTrip()
        {
            Assert.AreEqual(0, StateManager.HP(StateManager.SetHP(StateManager.InitialState(), 0)));
            Assert.AreEqual(1, StateManager.HP(StateManager.SetHP(StateManager.InitialState(), 1)));
            Assert.AreEqual(2, StateManager.HP(StateManager.SetHP(StateManager.InitialState(), 2)));
            Assert.AreEqual(3, StateManager.HP(StateManager.SetHP(StateManager.InitialState(), 3)));
        }
        [TestMethod]
        public void CooldownRemainingShouldReturnZeroForNoCDAbilities()
        {
            Assert.AreEqual(0, StateManager.CooldownRemaining(StateManager.InitialState(), Ability.SotR));
            Assert.AreEqual(0, StateManager.CooldownRemaining(StateManager.InitialState(), Ability.Inq));
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
                Ability.WoG,
                Ability.CS,
                Ability.J,
                Ability.AS,
                Ability.Cons,
                Ability.HW,
                Ability.HoW, })
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
                StateManager.AdvanceTime(StateManager.SetTimeRemaining(StateManager.InitialState(), Buff.Inq, 3), 2),
                Buff.Inq));
            Assert.AreEqual(3, StateManager.TimeRemaining(
                StateManager.AdvanceTime(StateManager.SetTimeRemaining(StateManager.InitialState(), Buff.Inq, 5), 2),
                Buff.Inq));
            Assert.AreEqual(0, StateManager.TimeRemaining(
                StateManager.AdvanceTime(StateManager.SetTimeRemaining(StateManager.InitialState(), Buff.Inq, 1), 2),
                Buff.Inq));
        }
        [TestMethod]
        public void AdvanceTimeShouldNotChangeHP()
        {
            Assert.AreEqual(3, StateManager.HP(StateManager.AdvanceTime(StateManager.SetHP(StateManager.InitialState(), 3), 100)));
        }
    }
}
