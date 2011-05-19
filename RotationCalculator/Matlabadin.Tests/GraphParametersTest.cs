using Matlabadin;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace Matlabadin.Tests
{
    [TestClass]
    public class GraphParametersTest : MatlabadinTest
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
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, stepsPerGcd, useConsGlyph, mehit, rhit, sdProcRate, gcProcRate, egProcRate);
            Assert.AreEqual(0.8, gp.MeleeHit);
            Assert.AreEqual(0.9, gp.RangeHit);
            Assert.AreEqual(stepsPerGcd, gp.StepsPerGcd);
            Assert.AreEqual(0.5, gp.StepDuration);
        }
        [TestMethod]
        public void AbilityCooldownInStepsShouldMatchGameCDs()
        {
            Int64GraphParameters target = NoHitExpertise("");
            Assert.AreEqual(15, target.StepDuration * target.AbilityCooldownInSteps(Ability.AS));
            Assert.AreEqual(30, target.StepDuration * target.AbilityCooldownInSteps(Ability.Cons));
            Assert.AreEqual(3, target.StepDuration * target.AbilityCooldownInSteps(Ability.CS));
            Assert.AreEqual(3, target.StepDuration * target.AbilityCooldownInSteps(Ability.HotR));
            Assert.AreEqual(6, target.StepDuration * target.AbilityCooldownInSteps(Ability.HoW));
            Assert.AreEqual(15, target.StepDuration * target.AbilityCooldownInSteps(Ability.HW));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.Inq));
            Assert.AreEqual(8, target.StepDuration * target.AbilityCooldownInSteps(Ability.J));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.SotR));
            Assert.AreEqual(20, target.StepDuration * target.AbilityCooldownInSteps(Ability.WoG));
        }
        [TestMethod]
        public void ConsGlyphShouldAdd20PercentToDuration()
        {
            Int64GraphParameters target = new Int64GraphParameters(AllAbilityRotation, 3, true, 0, 0, 0, 0, 0);
            Assert.AreEqual(36, target.StepDuration * target.AbilityCooldownInSteps(Ability.Cons)); // 30s*1.2 = 72 0.5s steps
        }
        [TestMethod]
        public void BuffDurationInStepsShouldMatchGameCDs()
        {
            Int64GraphParameters target = new Int64GraphParameters(AllAbilityRotation, 3, false, 0, 0, 0, 0, 0);
            Assert.AreEqual(15, target.StepDuration * target.BuffDurationInSteps(Buff.EGICD));
            Assert.AreEqual(6 + 0.5, target.StepDuration * target.BuffDurationInSteps(Buff.GC)); // extra 0.5s to model buff gain delay
            Assert.AreEqual(4 * 3, target.StepDuration * target.BuffDurationInSteps(Buff.Inq)); // 4s * 3hp
            Assert.AreEqual(10, target.StepDuration * target.BuffDurationInSteps(Buff.SD));
        }
        [TestMethod]
        public void ShouldHaveSameShapeIfParametersMatch()
        {
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, 3, true, 1.0, 1.0, 0.5, 0.2, 0.3);
            Assert.IsTrue(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, 3, true, 1.0, 1.0, 0.5, 0.2, 0.3)));
            Assert.IsFalse(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, 1, true, 1.0, 1.0, 0.5, 0.2, 0.3)));
            Assert.IsFalse(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, 3, false, 1.0, 1.0, 0.5, 0.2, 0.3)));
            Assert.IsFalse(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, 3, true, 0.9, 1.0, 0.5, 0.2, 0.3)));
            Assert.IsFalse(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, 3, true, 1.0, 0.9, 0.5, 0.2, 0.3)));
            Assert.IsFalse(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, 3, true, 0.0, 1.0, 0.5, 0.2, 0.3)));
            Assert.IsFalse(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, 3, true, 1.0, 0.0, 0.5, 0.2, 0.3)));
            Assert.IsFalse(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, 3, true, 1.0, 1.0, 0.0, 0.2, 0.3)));
            Assert.IsFalse(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, 3, true, 1.0, 1.0, 0.5, 0.0, 0.3)));
            Assert.IsFalse(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, 3, true, 1.0, 1.0, 0.5, 0.2, 0.0)));
        }
        [TestMethod]
        public void ShouldHaveSameShapeIfOnlyDifferByNonZeroTransitionMagnitides()
        {
            Action<double, double, double, double, bool> DoTest = (mehit1, rhit1, mehit2, rhit2, result) =>
            {
                Assert.AreEqual(result, new Int64GraphParameters(AllAbilityRotation, 3, true, mehit1, rhit1, 0.5, 0.2, 0.3)
                    .HasSameShape(new Int64GraphParameters(AllAbilityRotation, 3, true, mehit2, rhit2, 0.5, 0.2, 0.3)));
            };
            DoTest(1.0, 1.0, 0.9, 1.0, false);
            DoTest(0.8, 1.0, 0.9, 1.0, true);
            DoTest(0.8, 0.8, 0.9, 0.9, true);
            DoTest(0.8, 0.8, 0.0, 0.9, false);
            DoTest(0.8, 0.8, 0.9, 0.0, false);
        }
        [TestMethod]
        public void ShouldNotHaveSameShapeIfRotationsDiffer()
        {
            Assert.IsFalse(
                new Int64GraphParameters(new RotationPriorityQueue<ulong>("CS"), 3, true, 1.0, 1.0, 0.5, 0.2, 0.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<ulong>("HW"), 3, true, 1.0, 1.0, 0.5, 0.2, 0.0)
                ));
        }
        [TestMethod]
        public void HotRCDShouldMatchCS()
        {
            // state space compression:
            Assert.AreEqual(GP.AbilityCooldownInSteps(Ability.CS), GP.AbilityCooldownInSteps(Ability.HotR));
        }
    }
}
