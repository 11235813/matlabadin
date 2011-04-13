using Matlabadin;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace Matlabadin.Tests
{
    [TestClass]
    public class GraphParametersTest
    {
        [TestMethod]
        public void PropertyValuesShouldCorrespondToConstructorArguments()
        {
            int stepsPerGcd = 3;
            bool useConsGlyph = false;
            double mehit = 0.8;
            double rhit = 0.9;
            double sdProcRate = 0.5;
            double gcProcRate = 0.2;
            double egProcRate = 0.3;
            GraphParameters gp = new GraphParameters(stepsPerGcd, useConsGlyph, mehit, rhit, sdProcRate, gcProcRate, egProcRate);
            Assert.AreEqual(0.8, gp.MeleeHit);
            Assert.AreEqual(0.9, gp.RangeHit);
            Assert.AreEqual(stepsPerGcd, gp.StepsPerGcd);
            Assert.AreEqual(0.5, gp.StepSize);
        }
        [TestMethod]
        public void AbilityCooldownInStepsShouldMatchGameCDs()
        {
            GraphParameters target = new GraphParameters(3, false, 0, 0, 0, 0, 0);
            Assert.AreEqual(15 * 2, target.AbilityCooldownInSteps(Ability.AS));
            Assert.AreEqual(30 * 2, target.AbilityCooldownInSteps(Ability.Cons));
            Assert.AreEqual(3 * 2, target.AbilityCooldownInSteps(Ability.CS));
            Assert.AreEqual(3 * 2, target.AbilityCooldownInSteps(Ability.HotR));
            Assert.AreEqual(6 * 2, target.AbilityCooldownInSteps(Ability.HoW));
            Assert.AreEqual(15 * 2, target.AbilityCooldownInSteps(Ability.HW));
            Assert.AreEqual(0 * 2, target.AbilityCooldownInSteps(Ability.Inq));
            Assert.AreEqual(8 * 2, target.AbilityCooldownInSteps(Ability.J));
            Assert.AreEqual(0 * 2, target.AbilityCooldownInSteps(Ability.SotR));
            Assert.AreEqual(20 * 2, target.AbilityCooldownInSteps(Ability.WoG));
        }
        [TestMethod]
        public void ConsGlyphShouldAdd20PercentToDuration()
        {
            GraphParameters target = new GraphParameters(3, true, 0, 0, 0, 0, 0);
            Assert.AreEqual(72, target.AbilityCooldownInSteps(Ability.Cons)); // 30s*1.2 = 72 0.5s steps
        }
        [TestMethod]
        public void BuffDurationInStepsShouldMatchGameCDs()
        {
            GraphParameters target = new GraphParameters(3, false, 0, 0, 0, 0, 0);
            Assert.AreEqual(15 * 2, target.BuffDurationInSteps(Buff.EGICD));
            Assert.AreEqual(6 * 2, target.BuffDurationInSteps(Buff.GC));
            Assert.AreEqual(3.5 * 2, target.BuffDurationInSteps(Buff.GCICD));
            Assert.AreEqual(4 * 3 * 2, target.BuffDurationInSteps(Buff.INQ)); // 4s * 3hp
            Assert.AreEqual(10 * 2, target.BuffDurationInSteps(Buff.SD));
        }
        [TestMethod]
        public void CalculateBitOffsetsShouldPackAbilitiesAfterHP()
        {
            GraphParameters target = new GraphParameters(3, false, 0, 0, 0, 0, 0);
            Assert.AreEqual(2, target.AbilityCooldownStartBit[(int)Ability.WoG]);
            Assert.AreEqual(6, target.AbilityCooldownBits[(int)Ability.WoG]); // 0-40 steps = 6 bits
            Assert.AreEqual(8, target.AbilityCooldownStartBit[(int)Ability.CS]);
            // TODO: we can save a bit since we always advance 1 GCD after using an ability which effectively reduces the CD by one step
            Assert.AreEqual(3, target.AbilityCooldownBits[(int)Ability.CS]); // 0-6 steps = 3 bits
            Assert.AreEqual(5, target.AbilityCooldownBits[(int)Ability.J]); // 16 ticks over to the 5th bit
            
        }
        [TestMethod]
        public void NoCDShouldHaveZeroBitSize()
        {
            GraphParameters target = new GraphParameters(3, false, 0, 0, 0, 0, 0);
            Assert.AreEqual(0, target.AbilityCooldownBits[(int)Ability.SotR]);
            Assert.AreEqual(0, target.AbilityCooldownBits[(int)Ability.Inq]);
        }
        [TestMethod]
        public void HotRShouldHaveSameBitsAsCS()
        {
            GraphParameters target = new GraphParameters(3, false, 0, 0, 0, 0, 0);
            Assert.AreEqual(target.AbilityCooldownStartBit[(int)Ability.HotR], target.AbilityCooldownStartBit[(int)Ability.CS]);
            Assert.AreEqual(target.AbilityCooldownBits[(int)Ability.HotR], target.AbilityCooldownBits[(int)Ability.CS]); // 15 options fits into 4 bits
        }
    }
}
