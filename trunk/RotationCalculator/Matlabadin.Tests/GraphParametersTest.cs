using Matlabadin;
using NUnit.Framework;
using System;

namespace Matlabadin.Tests
{
    [TestFixture]
    public class GraphParametersTest : MatlabadinTest
    {
        [Test]
        [ExpectedException(typeof(ArgumentException))]
        public void RotationShouldBeValidForTalents()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("SS"), 3, PaladinSpec.Prot, PaladinTalents.None, 0, 1, 1);
        }
        // SH is fine, the rotation just won't ever cast FoL in the case of FoL[#SH=3] rotations
        [Test]
        [ExpectedException(typeof(ArgumentException))]
        public void RotationShouldBeValidForTalents_EF()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("EF"), 3, PaladinSpec.Prot, PaladinTalents.None, 0, 1, 1);
        }
        [Test]
        [ExpectedException(typeof(ArgumentException))]
        public void RotationShouldBeValidForTalents_SS()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("SS"), 3, PaladinSpec.Prot, PaladinTalents.None, 0, 1, 1);
        }
        
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_Holy()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), 3, PaladinSpec.Holy, PaladinTalents.None, 0, 1, 1);
        }
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_Ret()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), 3, PaladinSpec.Ret, PaladinTalents.None, 0, 1, 1);
        }
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_HolyAvenger()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), 3, PaladinSpec.Prot, PaladinTalents.HolyAvenger, 0, 1, 1);
        }
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_SanctifiedWrath()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), 3, PaladinSpec.Prot, PaladinTalents.SanctifiedWrath, 0, 1, 1);
        }
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_DivinePurpose()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), 3, PaladinSpec.Prot, PaladinTalents.DivinePurpose, 0, 1, 1);
        }
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_ExecutionSentence()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), 3, PaladinSpec.Prot, PaladinTalents.ExecutionSentence, 0, 1, 1);
        }
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_LightsHammer()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), 3, PaladinSpec.Prot, PaladinTalents.LightsHammer, 0, 1, 1);
        }
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_HolyPrism()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), 3, PaladinSpec.Prot, PaladinTalents.HolyPrism, 0, 1, 1);
        }
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_BurdenOfGuilt()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), 3, PaladinSpec.Prot, PaladinTalents.BurdenOfGuilt, 0, 1, 1);
        }
        [Test]
        [ExpectedException(typeof(ArgumentException))]
        public void InvalidRotation_SSWithoutSS()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("SS"), 3, PaladinSpec.Prot, PaladinTalents.None, 0, 1, 1);
        }
        [Test]
        [ExpectedException(typeof(ArgumentException))]
        public void InvalidRotation_EFWithoutEF()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("SS"), 3, PaladinSpec.Prot, PaladinTalents.None, 0, 1, 1);
        }
        [Test]
        public void PropertyValuesShouldCorrespondToConstructorArguments()
        {
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, 3, PaladinSpec.Prot, PaladinTalents.All, 0.2, 0.8, 0.9);
            Assert.AreEqual(0.8, gp.MeleeHit);
            Assert.AreEqual(0.9, gp.SpellHit);
            Assert.AreEqual(3, gp.StepsPerGcd);
            Assert.AreEqual(PaladinTalents.All, gp.Talents);
            Assert.AreEqual(PaladinSpec.Prot, gp.Spec);
            Assert.AreEqual(0.2, gp.Haste);
            Assert.AreEqual(0.5, gp.StepDuration);
        }
        [Test]
        public void AbilityTriggersGCD_ShouldTriggerForCDAbilities()
        {
            // Ability.All test case
            Assert.IsFalse(GP.AbilityTriggersGcd(Ability.Nothing));
            Assert.IsFalse(GP.AbilityTriggersGcd(Ability.SotR));
            Assert.IsFalse(GP.AbilityTriggersGcd(Ability.WoG));
            Assert.IsFalse(GP.AbilityTriggersGcd(Ability.EF));
            Assert.IsFalse(GP.AbilityTriggersGcd(Ability.SS));
            Assert.IsFalse(GP.AbilityTriggersGcd(Ability.AW));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.HotR));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.CS));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.J));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.AS));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.Cons));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.FoL));
        }
        [Test]
        public void AbilityOnGCD_ShouldBeTrueForCDAbilities()
        {
            // Ability.All test case
            Assert.IsFalse(GP.AbilityOnGcd(Ability.Nothing));
            Assert.IsFalse(GP.AbilityOnGcd(Ability.SotR));
            Assert.IsFalse(GP.AbilityOnGcd(Ability.WoG));
            Assert.IsFalse(GP.AbilityOnGcd(Ability.EF));
            Assert.IsFalse(GP.AbilityOnGcd(Ability.SS));
            Assert.IsFalse(GP.AbilityOnGcd(Ability.AW));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.HotR));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.CS));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.J));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.AS));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.Cons));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.FoL));
        }
        [Test]
        public void GcdDurationTriggeredByAbilityInSteps_ShouldBeGCDForGCDAbilities()
        {
            // Ability.All test case
            Assert.AreEqual(0, GP.GcdDurationTriggeredByAbilityInSteps(Ability.Nothing));
            Assert.AreEqual(0, GP.GcdDurationTriggeredByAbilityInSteps(Ability.SotR));
            Assert.AreEqual(0, GP.GcdDurationTriggeredByAbilityInSteps(Ability.WoG));
            Assert.AreEqual(0, GP.GcdDurationTriggeredByAbilityInSteps(Ability.EF));
            Assert.AreEqual(0, GP.GcdDurationTriggeredByAbilityInSteps(Ability.SS));
            Assert.AreEqual(GP.StepsPerGcd, GP.GcdDurationTriggeredByAbilityInSteps(Ability.HotR));
            Assert.AreEqual(GP.StepsPerGcd, GP.GcdDurationTriggeredByAbilityInSteps(Ability.CS));
            Assert.AreEqual(GP.StepsPerGcd, GP.GcdDurationTriggeredByAbilityInSteps(Ability.J));
            Assert.AreEqual(GP.StepsPerGcd, GP.GcdDurationTriggeredByAbilityInSteps(Ability.AS));
            Assert.AreEqual(GP.StepsPerGcd, GP.GcdDurationTriggeredByAbilityInSteps(Ability.Cons));
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
            Assert.AreEqual(180, target.StepDuration * target.AbilityCooldownInSteps(Ability.AW));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.FoL));
        }
        [Test]
        public void GCProcRateShouldMatchMoPTalentCalculator()
        {
            Assert.AreEqual(0.2, GP.GrandCrusaderProcRate);
        }
        [Test]
        public void BuffDurationInStepsShouldMatchMoPTalentCalculator()
        {
            // Buff.All
            Assert.AreEqual(GP.StepsPerGcd, GP.BuffDurationInSteps(Buff.GCD));
            Assert.AreEqual(30, GP.StepDuration * GP.BuffDurationInSteps(Buff.SS));
            Assert.AreEqual(30, GP.StepDuration * GP.BuffDurationInSteps(Buff.EF));
            Assert.AreEqual(20, GP.StepDuration * GP.BuffDurationInSteps(Buff.AW));
            Assert.AreEqual(6, GP.StepDuration * GP.BuffDurationInSteps(Buff.SotRSB));
            Assert.AreEqual(30, GP.StepDuration * GP.BuffDurationInSteps(Buff.WB));
            Assert.AreEqual(6 + 0.5, GP.StepDuration * GP.BuffDurationInSteps(Buff.GC)); // extra 0.5s to model buff gain delay
            Assert.AreEqual(15, GP.StepDuration * GP.BuffDurationInSteps(Buff.SH));
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
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, 3, PaladinSpec.Prot, PaladinTalents.All, 0, 1.0, 1.0);
            Assert.IsTrue(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, 3, PaladinSpec.Prot, PaladinTalents.All, 0, 1.0, 1.0)));
        }
        [Test]
        public void ShouldHaveSameShapeIfOnlyDifferByNonZeroTransitionMagnitides()
        {
            Action<double, double, double, double, bool> DoTest = (mehit1, rhit1, mehit2, rhit2, result) =>
            {
                Assert.AreEqual(result, new Int64GraphParameters(AllAbilityRotation, 3, PaladinSpec.Prot, PaladinTalents.All, 0, mehit1, rhit1)
                    .HasSameShape(new Int64GraphParameters(AllAbilityRotation, 3, PaladinSpec.Prot, PaladinTalents.All, 0, mehit2, rhit2)));
            };
            DoTest(1.0, 1.0, 0.9, 1.0, false);
            DoTest(0.8, 1.0, 0.9, 1.0, true);
            DoTest(0.8, 0.8, 0.9, 0.9, true);
            DoTest(0.8, 0.8, 0.0, 0.9, false);
            DoTest(0.8, 0.8, 0.9, 0.0, false);
            DoTest(0.860152, 0.935152, 0.866212, 0.941212, true);
        }
        [Test]
        public void ShouldNotHaveSameShapeIfRotationsDiffer()
        {
            Assert.IsFalse(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), 3, PaladinSpec.Prot, PaladinTalents.All, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("Cons"), 3, PaladinSpec.Prot, PaladinTalents.All, 0, 1.0, 1.0)
                ));
        }
        [Test]
        public void ShouldNotHaveSameShapeIfTalentsDiffer()
        {
            Assert.IsTrue(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), 3, PaladinSpec.Prot, PaladinTalents.SelflessHealer, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), 3, PaladinSpec.Prot, PaladinTalents.SelflessHealer, 0, 1.0, 1.0)
                ));
            Assert.IsFalse(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), 3, PaladinSpec.Prot, PaladinTalents.SelflessHealer, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), 3, PaladinSpec.Prot, PaladinTalents.SelflessHealer | PaladinTalents.EternalFlame, 0, 1.0, 1.0)
                ));
        }
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void ShouldNotHaveSameShapeIfSpecsDiffer()
        {
            Assert.IsFalse(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), 3, PaladinSpec.Ret, PaladinTalents.None, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), 3, PaladinSpec.Prot, PaladinTalents.None, 0, 1.0, 1.0)
                ));
        }
        [Test]
        public void ShouldNotHaveSameShapeIfStepsPerGCDDiffer()
        {
            Assert.IsFalse(
                new Int64GraphParameters(AllAbilityRotation, 3, PaladinSpec.Prot, PaladinTalents.All, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(AllAbilityRotation, 1, PaladinSpec.Prot, PaladinTalents.All, 0, 1.0, 1.0)
                ));
        }
        [Test]
        public void ShouldNotHaveSameShapeIfHasteDiffer()
        {
            Assert.IsFalse(
                new Int64GraphParameters(AllAbilityRotation, 3, PaladinSpec.Prot, PaladinTalents.All, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(AllAbilityRotation, 1, PaladinSpec.Prot, PaladinTalents.All, 0.1, 1.0, 1.0)
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
