using Matlabadin;
using NUnit.Framework;
using System;

namespace Matlabadin.Tests
{
    [TestFixture]
    public class GraphParametersTest : MatlabadinTest
    {
        [Test]
        public void RotationShouldBeValidForTalents()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("SS"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1);
            Assert.IsFalse(String.IsNullOrEmpty(gp.Warnings));
        }
        // SH is fine, the rotation just won't ever cast FoL in the case of FoL[#SH=3] rotations
        [Test]
        public void RotationShouldBeValidForTalents_EF()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("EF"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1);
            Assert.IsFalse(String.IsNullOrEmpty(gp.Warnings));
        }
        [Test]
        public void RotationShouldBeValidForTalents_SS()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("SS"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1);
            Assert.IsFalse(String.IsNullOrEmpty(gp.Warnings));
        }
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_Holy()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), PaladinSpec.Holy, PaladinTalents.None, 3, 0, 1, 1);
        }
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_Ret()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), PaladinSpec.Ret, PaladinTalents.None, 3, 0, 1, 1);
        }
        [Test]
        //[ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_HolyAvenger()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), PaladinSpec.Prot, PaladinTalents.HolyAvenger, 3, 0, 1, 1);
        }
        //[Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_SanctifiedWrath()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), PaladinSpec.Prot, PaladinTalents.SanctifiedWrath, 3, 0, 1, 1);
        }
        //[Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_BurdenOfGuilt()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), PaladinSpec.Prot, PaladinTalents.BurdenOfGuilt, 3, 0, 1, 1);
        }
        [Test]
        public void InvalidRotation_SSWithoutSS()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("SS"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1);
            Assert.IsTrue(gp.Warnings.Contains("SS"));
        }
        [Test]
        public void InvalidRotation_EFWithoutEF()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("EF"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1);
            Assert.IsTrue(gp.Warnings.Contains("EF"));
        }
        [Test]
        public void Compression_Ability_ShouldHaveNoCooldownForUnusedAbilities()
        {
            var gp = new GraphParameters<int>(new RotationPriorityQueue<int>("SotR>HotR"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1);
            Assert.AreNotEqual(0, gp.AbilityCooldownInSteps(Ability.CS));
            Assert.AreNotEqual(0, gp.AbilityCooldownInSteps(Ability.HotR));
            Assert.AreEqual(0, gp.AbilityCooldownInSteps(Ability.J));
            Assert.AreEqual(0, gp.AbilityCooldownInSteps(Ability.HoW));
            Assert.AreEqual(0, gp.AbilityCooldownInSteps(Ability.AS));
            Assert.AreEqual(0, gp.AbilityCooldownInSteps(Ability.Cons));
            Assert.AreEqual(0, gp.AbilityCooldownInSteps(Ability.HW));
            Assert.AreEqual(0, gp.AbilityCooldownInSteps(Ability.AW));
            Assert.AreEqual(0, gp.AbilityCooldownInSteps(Ability.ES));
            Assert.AreEqual(0, gp.AbilityCooldownInSteps(Ability.LH));
            Assert.AreEqual(0, gp.AbilityCooldownInSteps(Ability.HPr));
        }
        [Test]
        public void Compression_Buff_SS_ShouldRequireInRotation_SS()
        {
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("SS"), PaladinSpec.Prot, PaladinTalents.SacredShield, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.SS));
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("CS"), PaladinSpec.Prot, PaladinTalents.SacredShield, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.SS));
        }
        [Test]
        public void Compression_Buff_EF_ShouldRequireInRotation_EF()
        {
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("EF"), PaladinSpec.Prot, PaladinTalents.EternalFlame, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.EF));
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("CS"), PaladinSpec.Prot, PaladinTalents.EternalFlame, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.EF));
        }
        [Test]
        public void Compression_Buff_AW_ShouldRequireInRotation_AW()
        {
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("AW"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.AW));
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("CS"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.AW));
        }
        [Test]
        public void Compression_Buff_SotRSB_ShouldRequireInRotation_SotR()
        {
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("SotR"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.SotRSB));
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("CS"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.SotRSB));
        }
        [Test]
        public void Compression_Buff_WB_ShouldRequireInRotation_HotR()
        {
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("HotR"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.WB));
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("CS"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.WB));
        }
        [Test]
        public void Compression_Buff_GC_ShouldRequireInRotation_HotRorCS()
        {
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("HotR"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.GC));
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("CS"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.GC));
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("Cons"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.GC));
        }
        [Test]
        public void Compression_Buff_SH_ShouldRequireInRotation_J()
        {
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("J"), PaladinSpec.Prot, PaladinTalents.SelflessHealer, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.SH));
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("Cons"), PaladinSpec.Prot, PaladinTalents.SelflessHealer, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.SH));
        }
        [Test]
        public void Compression_Buff_SH_ShouldRequireTalent_SelflessHealer()
        {
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("J"), PaladinSpec.Prot, PaladinTalents.SelflessHealer, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.SH));
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("J"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.SH));
        }
        [Test]
        public void ApproximationErrors_Should_Be_Set_For_Inexact_modelling()
        {
            // 1 step per GCD does not model 20s AW duration exactly
            Assert.IsFalse(String.IsNullOrEmpty(NoMiss(GP.Rotation.PriorityQueue, 1, 0).Warnings));
        }
        [Test]
        public void PropertyValuesShouldCorrespondToConstructorArguments()
        {
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, 2, 0.5, 0.8, 0.9);
            Assert.AreEqual(0.8, gp.MeleeHit);
            Assert.AreEqual(0.9, gp.RangedHit);
            Assert.AreEqual(PaladinTalents.All, gp.Talents);
            Assert.AreEqual(PaladinSpec.Prot, gp.Spec);
            Assert.AreEqual(2, gp.StepsPerHastedGcd);
            Assert.AreEqual(0.5, gp.Haste);
            Assert.AreEqual((1.5 / (1.0 + 0.5)) / 2, gp.StepDuration);
        }
        [Test]
        public void AbilityTriggersGCD_ShouldTriggerForCDAbilities()
        {
            // Ability.All test case
            Assert.IsFalse(GP.AbilityTriggersGcd(Ability.Nothing));
            Assert.IsFalse(GP.AbilityTriggersGcd(Ability.SotR));
            Assert.IsFalse(GP.AbilityTriggersGcd(Ability.WoG));
            Assert.IsFalse(GP.AbilityTriggersGcd(Ability.EF));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.SS));
            Assert.IsFalse(GP.AbilityTriggersGcd(Ability.AW));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.HotR));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.CS));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.J));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.AS));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.Cons));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.FoL));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.ES));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.HPr));
            Assert.IsTrue(GP.AbilityTriggersGcd(Ability.LH));
        }
        [Test]
        public void AbilityOnGCD_ShouldBeTrueForCDAbilities()
        {
            // Ability.All test case
            Assert.IsFalse(GP.AbilityOnGcd(Ability.Nothing));
            Assert.IsFalse(GP.AbilityOnGcd(Ability.SotR));
            Assert.IsFalse(GP.AbilityOnGcd(Ability.WoG));
            Assert.IsFalse(GP.AbilityOnGcd(Ability.EF));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.SS));
            Assert.IsFalse(GP.AbilityOnGcd(Ability.AW));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.HotR));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.CS));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.J));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.HoW));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.AS));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.Cons));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.FoL));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.ES));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.HPr));
            Assert.IsTrue(GP.AbilityOnGcd(Ability.LH));
        }
        [Test]
        public void GcdDurationTriggeredByAbilityInSteps_ShouldBeGCDForGCDAbilities()
        {
            // Ability.All test case
            Assert.AreEqual(0, GPFullHaste.GcdDurationTriggeredByAbilityInSteps(Ability.Nothing));
            Assert.AreEqual(0, GPFullHaste.GcdDurationTriggeredByAbilityInSteps(Ability.SotR));
            Assert.AreEqual(0, GPFullHaste.GcdDurationTriggeredByAbilityInSteps(Ability.WoG));
            Assert.AreEqual(0, GPFullHaste.GcdDurationTriggeredByAbilityInSteps(Ability.EF));
            Assert.AreEqual(GPFullHaste.StepsPerHastedGcd, GPFullHaste.GcdDurationTriggeredByAbilityInSteps(Ability.SS));
            Assert.AreEqual(GPFullHaste.StepsPerHastedGcd, GPFullHaste.GcdDurationTriggeredByAbilityInSteps(Ability.HotR));
            Assert.AreEqual(GPFullHaste.StepsPerHastedGcd, GPFullHaste.GcdDurationTriggeredByAbilityInSteps(Ability.CS));
            Assert.AreEqual(GPFullHaste.StepsPerHastedGcd, GPFullHaste.GcdDurationTriggeredByAbilityInSteps(Ability.J));
            Assert.AreEqual(GPFullHaste.StepsPerHastedGcd, GPFullHaste.GcdDurationTriggeredByAbilityInSteps(Ability.HoW));
            Assert.AreEqual(GPFullHaste.StepsPerHastedGcd, GPFullHaste.GcdDurationTriggeredByAbilityInSteps(Ability.AS));
            Assert.AreEqual(GPFullHaste.StepsPerHastedGcd, GPFullHaste.GcdDurationTriggeredByAbilityInSteps(Ability.Cons));
            Assert.AreEqual(GPFullHaste.StepsPerHastedGcd, GPFullHaste.GcdDurationTriggeredByAbilityInSteps(Ability.ES));
            Assert.AreEqual(GPFullHaste.StepsPerHastedGcd, GPFullHaste.GcdDurationTriggeredByAbilityInSteps(Ability.HPr));
            Assert.AreEqual(GPFullHaste.StepsPerHastedGcd, GPFullHaste.GcdDurationTriggeredByAbilityInSteps(Ability.LH));
        }
        [Test]
        public void CooldownShouldBeHastedFor_CS_HotR_HoW_J()
        {
            Assert.AreEqual(4.5 / 1.5 * GPFullHaste.StepsPerHastedGcd, GPFullHaste.AbilityCooldownInSteps(Ability.HotR));
            Assert.AreEqual(4.5 / 1.5 * GPFullHaste.StepsPerHastedGcd, GPFullHaste.AbilityCooldownInSteps(Ability.CS));
            Assert.AreEqual(6.0 / 1.5 * GPFullHaste.StepsPerHastedGcd, GPFullHaste.AbilityCooldownInSteps(Ability.J));
            Assert.AreEqual(6.0 / 1.5 * GPFullHaste.StepsPerHastedGcd, GPFullHaste.AbilityCooldownInSteps(Ability.HoW));
        }
        [Test]
        public void AbilityCooldownsShouldMatchMoPTalentCalculator()
        {
            var target = new GraphParameters<object>(new RotationPriorityQueue<object>("AS>Cons>CS>HotR>HW>J>HoW>SotR>WoG>SS>EF>AW>FoL>ES>LH>HPr"), PaladinSpec.Prot, PaladinTalents.All);
            Assert.AreEqual(15, target.StepDuration * target.AbilityCooldownInSteps(Ability.AS));
            Assert.AreEqual(9, target.StepDuration * target.AbilityCooldownInSteps(Ability.Cons));
            Assert.AreEqual(4.5, target.StepDuration * target.AbilityCooldownInSteps(Ability.CS));
            Assert.AreEqual(4.5, target.StepDuration * target.AbilityCooldownInSteps(Ability.HotR));
            Assert.AreEqual(9, target.StepDuration * target.AbilityCooldownInSteps(Ability.HW));
            Assert.AreEqual(6, target.StepDuration * target.AbilityCooldownInSteps(Ability.J));
            Assert.AreEqual(6, target.StepDuration * target.AbilityCooldownInSteps(Ability.HoW));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.SotR));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.WoG));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.SS));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.EF));
            Assert.AreEqual(180, target.StepDuration * target.AbilityCooldownInSteps(Ability.AW));
            Assert.AreEqual(0, target.StepDuration * target.AbilityCooldownInSteps(Ability.FoL));
            Assert.AreEqual(60, target.StepDuration * target.AbilityCooldownInSteps(Ability.ES));
            Assert.AreEqual(60, target.StepDuration * target.AbilityCooldownInSteps(Ability.LH));
            Assert.AreEqual(20, target.StepDuration * target.AbilityCooldownInSteps(Ability.HPr));
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
            Assert.AreEqual(GP.StepsPerHastedGcd, GP.BuffDurationInSteps(Buff.GCD));
            Assert.AreEqual(30, GP.StepDuration * GP.BuffDurationInSteps(Buff.SS));
            Assert.AreEqual(30, GP.StepDuration * GP.BuffDurationInSteps(Buff.EF));
            Assert.AreEqual(20, GP.StepDuration * GP.BuffDurationInSteps(Buff.AW));
            Assert.AreEqual(3, GP.StepDuration * GP.BuffDurationInSteps(Buff.SotRSB));
            Assert.AreEqual(30, GP.StepDuration * GP.BuffDurationInSteps(Buff.WB));
            Assert.AreEqual(6 + 0.5, GP.StepDuration * GP.BuffDurationInSteps(Buff.GC)); // extra step to model buff gain delay
            Assert.AreEqual(15, GP.StepDuration * GP.BuffDurationInSteps(Buff.SH));
        }
        [Test]
        public void AW_BuffDurationShouldBeExtendedBySancifiedWrath()
        {
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.SanctifiedWrath, 5, 0.5, 0.8, 0.9);
            Assert.AreEqual(30, gp.StepDuration * gp.BuffDurationInSteps(Buff.AW));
        }
        [Test]
        public void GcdDurationShouldBeReducedByHaste()
        {
            Assert.AreEqual(GPFullHaste.StepsPerHastedGcd, GPFullHaste.BuffDurationInSteps(Buff.GCD));
            //Assert.AreNotEqual(GPFullHaste.StepsPerUnhastedGcd, GPFullHaste.BuffDurationInSteps(Buff.GCD));
        }
        [Test]
        public void HasteClippingShouldIncreaseCooldown()
        {
            // 1 step = 1.5s => 180s = 120 steps
            Assert.AreEqual(120, NoMiss(AllAbilityRotation.PriorityQueue, 1, 0).AbilityCooldownInSteps(Ability.AW));
            // 1 step = 1.363636363636364 => 132 steps
            Assert.AreEqual(132, NoMiss(AllAbilityRotation.PriorityQueue, 1, 0.1).AbilityCooldownInSteps(Ability.AW));
            // 132.12 => 133
            Assert.AreEqual(133, NoMiss(AllAbilityRotation.PriorityQueue, 1, 0.101).AbilityCooldownInSteps(Ability.AW));
            // 132.84 => 133
            Assert.AreEqual(133, NoMiss(AllAbilityRotation.PriorityQueue, 1, 0.107).AbilityCooldownInSteps(Ability.AW));
        }
        [Test]
        public void HasteClippingShouldDecreaseBuffDuration()
        {
            // 1 step = 1.5s => 30s = 20 steps
            Assert.AreEqual(20, NoMiss(AllAbilityRotation.PriorityQueue, 1, 0).BuffDurationInSteps(Buff.WB));
            // 6.6s steps = 6
            Assert.AreEqual(22, NoMiss(AllAbilityRotation.PriorityQueue, 1, 0.1).BuffDurationInSteps(Buff.WB));
            // 22.1 => 22
            Assert.AreEqual(22, NoMiss(AllAbilityRotation.PriorityQueue, 1, 0.105).BuffDurationInSteps(Buff.WB));
            // 20.98 => 21
            Assert.AreEqual(20, NoMiss(AllAbilityRotation.PriorityQueue, 1, 0.049).BuffDurationInSteps(Buff.WB));
        }
        [Test]
        public void HasteShouldIncreaseStepsOfNonhastedAbilities()
        {
            Assert.IsTrue(GPFullHaste.AbilityCooldownInSteps(Ability.AW) > GP.AbilityCooldownInSteps(Ability.AW));
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
                Ability.HoW,
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
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, 3, 0, 1.0, 1.0);
            Assert.IsTrue(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, 3, 0, 1.0, 1.0)));
        }
        [Test]
        public void ShouldNotHaveSameShapeIfBuffsDiffer()
        {
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, 3, 0, 1.0, 1.0, new Buff[] { Buff.AW } );
            Assert.IsFalse(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, 3, 0, 1.0, 1.0, new Buff[] { Buff.HA })));
        }
        [Test]
        public void ShouldHaveSameShapeIfBuffsEquivalent()
        {
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, 3, 0, 1.0, 1.0, new Buff[] { Buff.HA, Buff.AW, });
            Assert.IsTrue(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, 3, 0, 1.0, 1.0, new Buff[] { Buff.AW, Buff.HA, })));
        }
        [Test]
        public void ShouldHaveSameShapeIfOnlyDifferByNonZeroTransitionMagnitides()
        {
            Action<double, double, double, double, bool> DoTest = (mehit1, rhit1, mehit2, rhit2, result) =>
            {
                Assert.AreEqual(result, new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, 3, 0, mehit1, rhit1)
                    .HasSameShape(new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, 3, 0, mehit2, rhit2)));
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
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.All, 3, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("Cons"), PaladinSpec.Prot, PaladinTalents.All, 3, 0, 1.0, 1.0)
                ));
        }
        [Test]
        public void ShouldNotHaveSameShapeIfTalentsDiffer()
        {
            Assert.IsTrue(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.SelflessHealer, 3, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.SelflessHealer, 3, 0, 1.0, 1.0)
                ));
            Assert.IsFalse(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.SelflessHealer, 3, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.SelflessHealer | PaladinTalents.EternalFlame, 3, 0, 1.0, 1.0)
                ));
        }
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void ShouldNotHaveSameShapeIfSpecsDiffer()
        {
            Assert.IsFalse(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Ret, PaladinTalents.None, 3, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.None, 3, 0, 1.0, 1.0)
                ));
        }
        [Test]
        public void ShouldNotHaveSameShapeIfStepsPerGCDDiffer()
        {
            Assert.IsFalse(
                new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, 3, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, 1, 0, 1.0, 1.0)
                ));
        }
        [Test]
        public void ShouldNotHaveSameShapeIfHastedSteps()
        {
            Assert.IsFalse(
                new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, 3, 0.5, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, 1, 0.25, 1.0, 1.0)
                ));
        }
        [Test]
        public void HotRCDShouldMatchCS()
        {
            // state space compression:
            Assert.AreEqual(GP.AbilityCooldownInSteps(Ability.CS), GP.AbilityCooldownInSteps(Ability.HotR));
        }
        [Test]
        public void MaxBuffStacks_ShouldBe1ExceptForSH3_BoG5()
        {
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                Buff b = (Buff)i;
                int expectedStacks = 1;
                if (b == Buff.SH) expectedStacks = 3;
                if (b == Buff.BoG) expectedStacks = 5;
                Assert.AreEqual(expectedStacks, GP.MaxBuffStacks(b), String.Format("Expected {1} stacks for {0}", b, expectedStacks));
            }
        }
        [Test]
        public void CanStack_ShouldBeSHBoGOnly()
        {
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                Buff b = (Buff)i;
                Assert.AreEqual(b == Buff.SH || b == Buff.BoG, GP.CanStack(b));
            }
        }
    }
}
