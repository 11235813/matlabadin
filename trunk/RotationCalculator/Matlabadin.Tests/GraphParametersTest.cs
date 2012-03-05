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
            double mehit = 0.8;
            double rhit = 0.9;
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, stepsPerGcd, mehit, rhit);
            Assert.AreEqual(0.8, gp.MeleeHit);
            Assert.AreEqual(0.9, gp.RangeHit);
            Assert.AreEqual(stepsPerGcd, gp.StepsPerGcd);
            Assert.AreEqual(0.5, gp.StepDuration);
        }
        [TestMethod]
        public void AbilityCooldownsShouldMatchMoPTalentCalculator()
        {
            Int64GraphParameters target = NoHitExpertise("");
            Assert.AreEqual(9, target.StepDuration * target.AbilityCooldownInSteps(Ability.AS));
            Assert.AreEqual(9, target.StepDuration * target.AbilityCooldownInSteps(Ability.Cons));
            Assert.AreEqual(4.5, target.StepDuration * target.AbilityCooldownInSteps(Ability.CS));
            Assert.AreEqual(4.5, target.StepDuration * target.AbilityCooldownInSteps(Ability.HotR));
            Assert.AreEqual(6, target.StepDuration * target.AbilityCooldownInSteps(Ability.J));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.SotR));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.WoG));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.SS));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.EF));
            //Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.FoL));
        }
        [TestMethod]
        public void GCProcRateShouldMatchMoPTalentCalculator()
        {
            // state space compression:
            Assert.AreEqual(0.4, GP.GCProcRate);
        }
        [TestMethod]
        public void BuffDurationInStepsShouldMatchMoPTalentCalculator()
        {
            Int64GraphParameters target = new Int64GraphParameters(AllAbilityRotation, 3, 1, 1);
            Assert.AreEqual(6 + 0.5, target.StepDuration * target.BuffDurationInSteps(Buff.GC)); // extra 0.5s to model buff gain delay
            Assert.AreEqual(30, target.StepDuration * target.BuffDurationInSteps(Buff.SS));
            Assert.AreEqual(30, target.StepDuration * target.BuffDurationInSteps(Buff.EF));
            Assert.AreEqual(30, target.StepDuration * target.BuffDurationInSteps(Buff.WB));
            Assert.AreEqual(6, target.StepDuration * target.BuffDurationInSteps(Buff.SotRSB));
        }
        [TestMethod]
        public void WoGSotRShouldBeOffGCD()
        {
            foreach (Ability a in new Ability[] {
                Ability.SotR,
                Ability.WoG,
            })
            {
                Assert.AreEqual(0, GP.AbilityCastTimeInSteps(a));
            }
        }
        [TestMethod]
        public void AbilityCastTimeInStepsShouldBe1GCD()
        {
            foreach (Ability a in new Ability[] {
                Ability.HotR,
                Ability.CS,
                Ability.J,
                Ability.AS,
                Ability.Cons,
                Ability.SS,
                Ability.EF,
            })
            {
                Assert.AreEqual(GP.StepsPerGcd, GP.AbilityCastTimeInSteps(a));
            }
        }
        [TestMethod]
        public void AbilityCastTimeInSteps_Nothing_ShouldBeSingleStep()
        {
            Assert.AreEqual(1, GP.AbilityCastTimeInSteps(Ability.Nothing));
        }
        [TestMethod]
        public void ShouldHaveSameShapeIfParametersMatch()
        {
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, 3, 1.0, 1.0);
            Assert.IsTrue(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, 3, 1.0, 1.0)));
        }
        [TestMethod]
        public void ShouldHaveSameShapeIfOnlyDifferByNonZeroTransitionMagnitides()
        {
            Action<double, double, double, double, bool> DoTest = (mehit1, rhit1, mehit2, rhit2, result) =>
            {
                Assert.AreEqual(result, new Int64GraphParameters(AllAbilityRotation, 3, mehit1, rhit1)
                    .HasSameShape(new Int64GraphParameters(AllAbilityRotation, 3, mehit2, rhit2)));
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
                new Int64GraphParameters(new RotationPriorityQueue<ulong>("CS"), 3, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<ulong>("Cons"), 3 , 1.0, 1.0)
                ));
        }
        [TestMethod]
        public void ShouldNotHaveSameShapeIfStepsPerGCDDiffer()
        {
            Assert.IsFalse(
                new Int64GraphParameters(AllAbilityRotation, 3, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(AllAbilityRotation, 1, 1.0, 1.0)
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
