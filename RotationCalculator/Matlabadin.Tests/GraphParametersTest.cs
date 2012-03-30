using Matlabadin;
using NUnit.Framework;
using System;

namespace Matlabadin.Tests
{
    [TestFixture]
    public class GraphParametersTest : MatlabadinTest
    {
        [Test]
        public void PropertyValuesShouldCorrespondToConstructorArguments()
        {
            int stepsPerGcd = 3;
            double mehit = 0.8;
            double rhit = 0.9;
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, stepsPerGcd, mehit, rhit);
            Assert.AreEqual(0.8, gp.MeleeHit);
            Assert.AreEqual(0.9, gp.SpellHit);
            Assert.AreEqual(stepsPerGcd, gp.StepsPerGcd);
            Assert.AreEqual(0.5, gp.StepDuration);
        }
        [Test]
        public void AbilityTriggersGCD_ShouldTriggerForCDAbilities()
        {
            GraphParameters<ulong> gp = new GraphParameters<ulong>(AllAbilityRotation, 3, 1, 1);
            Assert.IsFalse(gp.AbilityTriggersGcd(Ability.Nothing));
            Assert.IsFalse(gp.AbilityTriggersGcd(Ability.SotR));
            Assert.IsFalse(gp.AbilityTriggersGcd(Ability.WoG));
            Assert.IsFalse(gp.AbilityTriggersGcd(Ability.EF));
            Assert.IsFalse(gp.AbilityTriggersGcd(Ability.SS));
            Assert.IsTrue(gp.AbilityTriggersGcd(Ability.HotR));
            Assert.IsTrue(gp.AbilityTriggersGcd(Ability.CS));
            Assert.IsTrue(gp.AbilityTriggersGcd(Ability.J));
            Assert.IsTrue(gp.AbilityTriggersGcd(Ability.AS));
            Assert.IsTrue(gp.AbilityTriggersGcd(Ability.Cons));
        }
        [Test]
        public void AbilityOnGCD_ShouldBeTrueForCDAbilities()
        {
            GraphParameters<ulong> gp = new GraphParameters<ulong>(AllAbilityRotation, 3, 1, 1);
            Assert.IsFalse(gp.AbilityOnGcd(Ability.Nothing));
            Assert.IsFalse(gp.AbilityOnGcd(Ability.SotR));
            Assert.IsFalse(gp.AbilityOnGcd(Ability.WoG));
            Assert.IsFalse(gp.AbilityOnGcd(Ability.EF));
            Assert.IsFalse(gp.AbilityOnGcd(Ability.SS));
            Assert.IsTrue(gp.AbilityOnGcd(Ability.HotR));
            Assert.IsTrue(gp.AbilityOnGcd(Ability.CS));
            Assert.IsTrue(gp.AbilityOnGcd(Ability.J));
            Assert.IsTrue(gp.AbilityOnGcd(Ability.AS));
            Assert.IsTrue(gp.AbilityOnGcd(Ability.Cons));
        }
        [Test]
        public void GcdDurationTriggeredByAbilityInSteps_ShouldBeGCDForGCDAbilities()
        {
            GraphParameters<ulong> gp = new GraphParameters<ulong>(AllAbilityRotation, 3, 1, 1);
            Assert.AreEqual(0, gp.GcdDurationTriggeredByAbilityInSteps(Ability.Nothing));
            Assert.AreEqual(0, gp.GcdDurationTriggeredByAbilityInSteps(Ability.SotR));
            Assert.AreEqual(0, gp.GcdDurationTriggeredByAbilityInSteps(Ability.WoG));
            Assert.AreEqual(0, gp.GcdDurationTriggeredByAbilityInSteps(Ability.EF));
            Assert.AreEqual(0, gp.GcdDurationTriggeredByAbilityInSteps(Ability.SS));
            Assert.AreEqual(gp.StepsPerGcd, gp.GcdDurationTriggeredByAbilityInSteps(Ability.HotR));
            Assert.AreEqual(gp.StepsPerGcd, gp.GcdDurationTriggeredByAbilityInSteps(Ability.CS));
            Assert.AreEqual(gp.StepsPerGcd, gp.GcdDurationTriggeredByAbilityInSteps(Ability.J));
            Assert.AreEqual(gp.StepsPerGcd, gp.GcdDurationTriggeredByAbilityInSteps(Ability.AS));
            Assert.AreEqual(gp.StepsPerGcd, gp.GcdDurationTriggeredByAbilityInSteps(Ability.Cons));
        }
        [Test]
        public void AbilityCooldownsShouldMatchMoPTalentCalculator()
        {
            Int64GraphParameters target = NoHitExpertise("");
            Assert.AreEqual(15, target.StepDuration * target.AbilityCooldownInSteps(Ability.AS));
            Assert.AreEqual(9, target.StepDuration * target.AbilityCooldownInSteps(Ability.Cons));
            Assert.AreEqual(4.5, target.StepDuration * target.AbilityCooldownInSteps(Ability.CS));
            Assert.AreEqual(4.5, target.StepDuration * target.AbilityCooldownInSteps(Ability.HotR));
            Assert.AreEqual(9, target.StepDuration * target.AbilityCooldownInSteps(Ability.HW));
            Assert.AreEqual(6, target.StepDuration * target.AbilityCooldownInSteps(Ability.J));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.SotR));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.WoG));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.SS));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.EF));
            //Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.FoL));
        }
        [Test]
        public void GCProcRateShouldMatchMoPTalentCalculator()
        {
            // state space compression:
            Assert.AreEqual(0.2, GP.GCProcRate);
        }
        [Test]
        public void BuffDurationInStepsShouldMatchMoPTalentCalculator()
        {
            Int64GraphParameters target = new Int64GraphParameters(AllAbilityRotation, 3, 1, 1);
            Assert.AreEqual(6 + 0.5, target.StepDuration * target.BuffDurationInSteps(Buff.GC)); // extra 0.5s to model buff gain delay
            Assert.AreEqual(30, target.StepDuration * target.BuffDurationInSteps(Buff.SS));
            Assert.AreEqual(30, target.StepDuration * target.BuffDurationInSteps(Buff.EF));
            Assert.AreEqual(30, target.StepDuration * target.BuffDurationInSteps(Buff.WB));
            Assert.AreEqual(6, target.StepDuration * target.BuffDurationInSteps(Buff.SotRSB));
        }
        [Test]
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
        [Test]
        public void AbilityCastTimeInStepsShouldBe0()
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
                Assert.AreEqual(0, GP.AbilityCastTimeInSteps(a));
            }
        }
        [Test]
        public void AbilityCastTimeInSteps_Nothing_ShouldBeOneStep()
        {
            Assert.AreEqual(1, GP.AbilityCastTimeInSteps(Ability.Nothing));
        }
        [Test]
        public void ShouldHaveSameShapeIfParametersMatch()
        {
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, 3, 1.0, 1.0);
            Assert.IsTrue(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, 3, 1.0, 1.0)));
        }
        [Test]
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
        [Test]
        public void ShouldNotHaveSameShapeIfRotationsDiffer()
        {
            Assert.IsFalse(
                new Int64GraphParameters(new RotationPriorityQueue<ulong>("CS"), 3, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<ulong>("Cons"), 3 , 1.0, 1.0)
                ));
        }
        [Test]
        public void ShouldNotHaveSameShapeIfStepsPerGCDDiffer()
        {
            Assert.IsFalse(
                new Int64GraphParameters(AllAbilityRotation, 3, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(AllAbilityRotation, 1, 1.0, 1.0)
                ));
        }
        [Test]
        public void ShouldNotHaveSameShapeIfSHDiffers()
        {
            Assert.IsFalse(
                new Int64GraphParameters(AllAbilityRotation, 3, 1.0, 1.0, false)
                .HasSameShape(
                new Int64GraphParameters(AllAbilityRotation, 3, 1.0, 1.0, true)
                ));
        }
        [Test]
        public void HotRCDShouldMatchCS()
        {
            // state space compression:
            Assert.AreEqual(GP.AbilityCooldownInSteps(Ability.CS), GP.AbilityCooldownInSteps(Ability.HotR));
        }
        [Test]
        public void MaxBuffStacks_ShouldBe1ExceptForSH()
        {
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                Buff b = (Buff)i;
                int expectedStacks = b == Buff.SH ? 2 : 1;
                Assert.AreEqual(expectedStacks, GP.MaxBuffStacks(b));
            }
        }
        [Test]
        public void CanStack_ShouldBeSHOnly()
        {
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                Buff b = (Buff)i;
                Assert.AreEqual(b == Buff.SH, GP.CanStack(b));
            }
        }
    }
}
