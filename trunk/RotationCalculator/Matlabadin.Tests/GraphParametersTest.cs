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
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("SS"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1);
            Assert.IsFalse(String.IsNullOrEmpty(gp.Warnings));
        }
        // SH is fine, the rotation just won't ever cast FoL in the case of FoL[#SH=3] rotations
        [Test]
        public void RotationShouldBeValidForTalents_EF()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("EF"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1);
            Assert.IsFalse(String.IsNullOrEmpty(gp.Warnings));
        }
        [Test]
        public void RotationShouldBeValidForTalents_SS()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("SS"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1);
            Assert.IsFalse(String.IsNullOrEmpty(gp.Warnings));
        }
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_Holy()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), PaladinSpec.Holy, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1);
        }
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_Ret()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), PaladinSpec.Ret, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1);
        }
        [Test]
        //[ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_HolyAvenger()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), PaladinSpec.Prot, PaladinTalents.HolyAvenger, PaladinGlyphs.None, 3, 0, 1, 1);
        }
        //[Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_SanctifiedWrath()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), PaladinSpec.Prot, PaladinTalents.SanctifiedWrath, PaladinGlyphs.None, 3, 0, 1, 1);
        }
        //[Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void UnhandledMechanicsShouldThrowException_BurdenOfGuilt()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("J"), PaladinSpec.Prot, PaladinTalents.BurdenOfGuilt, PaladinGlyphs.None, 3, 0, 1, 1);
        }
        [Test]
        public void InvalidRotation_SSWithoutSS()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("SS"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1);
            Assert.IsTrue(gp.Warnings.Contains("SS"));
        }
        [Test]
        public void InvalidRotation_EFWithoutEF()
        {
            GraphParameters<int> gp = new GraphParameters<int>(new RotationPriorityQueue<int>("EF"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1);
            Assert.IsTrue(gp.Warnings.Contains("EF"));
        }
        [Test]
        public void Compression_Ability_ShouldHaveNoCooldownForUnusedAbilities()
        {
            var gp = new GraphParameters<int>(new RotationPriorityQueue<int>("SotR>HotR"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1);
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
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("SS"), PaladinSpec.Prot, PaladinTalents.SacredShield, PaladinGlyphs.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.SS));
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("CS"), PaladinSpec.Prot, PaladinTalents.SacredShield, PaladinGlyphs.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.SS));
        }
        [Test]
        public void Compression_Buff_EF_ShouldRequireInRotation_EF()
        {
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("EF"), PaladinSpec.Prot, PaladinTalents.EternalFlame, PaladinGlyphs.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.EF));
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("CS"), PaladinSpec.Prot, PaladinTalents.EternalFlame, PaladinGlyphs.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.EF));
        }
        [Test]
        public void Compression_Buff_AW_ShouldRequireInRotation_AW()
        {
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("AW"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.AW));
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("CS"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.AW));
        }
        //[Test]
        //public void Compression_Buff_SotRSB_ShouldRequireInRotation_SotR()
        //{
        //    Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("SotR"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1)
        //        .BuffDurationInSteps(Buff.SotRSB));
        //    Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("CS"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1)
        //        .BuffDurationInSteps(Buff.SotRSB));
        //}
        [Test]
        public void Compression_Buff_WB_ShouldRequireInRotation_HotR()
        {
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("HotR"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.WB));
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("CS"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.WB));
        }
        [Test]
        public void Compression_Buff_GC_ShouldRequireInRotation_HotRorCS()
        {
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("HotR"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.GC));
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("CS"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.GC));
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("Cons"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.GC));
        }
        [Test]
        public void Compression_Buff_SH_ShouldRequireInRotation_J()
        {
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("J"), PaladinSpec.Prot, PaladinTalents.SelflessHealer, PaladinGlyphs.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.SH));
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("Cons"), PaladinSpec.Prot, PaladinTalents.SelflessHealer, PaladinGlyphs.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.SH));
        }
        [Test]
        public void Compression_Buff_SH_ShouldRequireTalent_SelflessHealer()
        {
            Assert.AreNotEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("J"), PaladinSpec.Prot, PaladinTalents.SelflessHealer, PaladinGlyphs.None, 3, 0, 1, 1)
                .BuffDurationInSteps(Buff.SH));
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("J"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1, 1)
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
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.GoWoG, 2, 0.5, 0.8, 0.9);
            Assert.AreEqual(0.8, gp.MeleeHit);
            Assert.AreEqual(0.9, gp.JudgeHit);
            Assert.AreEqual(PaladinTalents.All, gp.Talents);
            Assert.AreEqual(PaladinSpec.Prot, gp.Spec);
            Assert.AreEqual(PaladinGlyphs.GoWoG, gp.Glyphs);
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
            var gp = new GraphParameters<object>(new RotationPriorityQueue<object>("SotR>WoG>EF>SS>HotR>CS>J>HoW>AS>Cons>ES>HPr>LH"), PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.All, haste: 0.5);
            // Ability.All test case
            Assert.AreEqual(0, gp.GcdDurationTriggeredByAbilityInSteps(Ability.Nothing));
            Assert.AreEqual(0, gp.GcdDurationTriggeredByAbilityInSteps(Ability.SotR));
            Assert.AreEqual(0, gp.GcdDurationTriggeredByAbilityInSteps(Ability.WoG));
            Assert.AreEqual(0, gp.GcdDurationTriggeredByAbilityInSteps(Ability.EF));
            Assert.AreEqual(gp.StepsPerHastedGcd, gp.GcdDurationTriggeredByAbilityInSteps(Ability.SS));
            Assert.AreEqual(gp.StepsPerHastedGcd, gp.GcdDurationTriggeredByAbilityInSteps(Ability.HotR));
            Assert.AreEqual(gp.StepsPerHastedGcd, gp.GcdDurationTriggeredByAbilityInSteps(Ability.CS));
            Assert.AreEqual(gp.StepsPerHastedGcd, gp.GcdDurationTriggeredByAbilityInSteps(Ability.J));
            Assert.AreEqual(gp.StepsPerHastedGcd, gp.GcdDurationTriggeredByAbilityInSteps(Ability.HoW));
            Assert.AreEqual(gp.StepsPerHastedGcd, gp.GcdDurationTriggeredByAbilityInSteps(Ability.AS));
            Assert.AreEqual(gp.StepsPerHastedGcd, gp.GcdDurationTriggeredByAbilityInSteps(Ability.Cons));
            Assert.AreEqual(gp.StepsPerHastedGcd, gp.GcdDurationTriggeredByAbilityInSteps(Ability.ES));
            Assert.AreEqual(gp.StepsPerHastedGcd, gp.GcdDurationTriggeredByAbilityInSteps(Ability.HPr));
            Assert.AreEqual(gp.StepsPerHastedGcd, gp.GcdDurationTriggeredByAbilityInSteps(Ability.LH));
        }
        [Test]
        public void CooldownShouldBeHastedFor_CS_HotR_HoW_J()
        {
            var gp = new GraphParameters<object>(new RotationPriorityQueue<object>("HotR>CS>J>HoW"), haste: 0.5);
            Assert.AreEqual(4.5 / 1.5 * gp.StepsPerHastedGcd, gp.AbilityCooldownInSteps(Ability.HotR));
            Assert.AreEqual(4.5 / 1.5 * gp.StepsPerHastedGcd, gp.AbilityCooldownInSteps(Ability.CS));
            Assert.AreEqual(6.0 / 1.5 * gp.StepsPerHastedGcd, gp.AbilityCooldownInSteps(Ability.J));
            Assert.AreEqual(6.0 / 1.5 * gp.StepsPerHastedGcd, gp.AbilityCooldownInSteps(Ability.HoW));
        }
        [Test]
        public void AbilityCooldownsShouldMatchMoPTalentCalculator()
        {
            var target = new GraphParameters<object>(new RotationPriorityQueue<object>("AS>Cons>CS>HotR>HW>J>HoW>SotR>WoG>SS>EF>AW>FoL>ES>LH>HPr"), PaladinSpec.Prot, PaladinTalents.None);
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
            var gp = new GraphParameters<object>(new RotationPriorityQueue<object>("AS>Cons>CS>HotR>HW>J>HoW>SotR>WoG>SS>EF>AW>HA>FoL>ES>LH>HPr"), PaladinSpec.Prot, PaladinTalents.SelflessHealer | PaladinTalents.DivinePurpose | PaladinTalents.HolyAvenger, PaladinGlyphs.GoWoG, 3);
            Assert.AreEqual(gp.StepsPerHastedGcd, gp.BuffDurationInSteps(Buff.GCD));
            Assert.AreEqual(30, gp.StepDuration * gp.BuffDurationInSteps(Buff.SS));
            Assert.AreEqual(30, gp.StepDuration * gp.BuffDurationInSteps(Buff.EF));
            Assert.AreEqual(20, gp.StepDuration * gp.BuffDurationInSteps(Buff.AW));
            //Assert.AreEqual(3, gp.StepDuration * gp.BuffDurationInSteps(Buff.SotRSB));
            Assert.AreEqual(30, gp.StepDuration * gp.BuffDurationInSteps(Buff.WB));
            Assert.AreEqual(6, gp.StepDuration * gp.BuffDurationInSteps(Buff.GoWoG));
            Assert.AreEqual(6 + 0.5, gp.StepDuration * gp.BuffDurationInSteps(Buff.GC)); // extra step to model buff gain delay
            Assert.AreEqual(15, gp.StepDuration * gp.BuffDurationInSteps(Buff.SH));
            Assert.AreEqual(20, gp.StepDuration * gp.BuffDurationInSteps(Buff.BoG));
            Assert.AreEqual(8, gp.StepDuration * gp.BuffDurationInSteps(Buff.DP));
            Assert.AreEqual(18, gp.StepDuration * gp.BuffDurationInSteps(Buff.HA));
        }
        [Test]
        public void AW_BuffDurationShouldBeExtendedBySancifiedWrath()
        {
            var gp = new GraphParameters<object>(new RotationPriorityQueue<object>("AW>CS"), PaladinSpec.Prot, PaladinTalents.All);
            Assert.AreEqual(30, gp.StepDuration * gp.BuffDurationInSteps(Buff.AW));
        }
        [Test]
        public void WB_BuffDurationShouldBeExtendedByGoHotR()
        {
            var gpWith = new GraphParameters<object>(new RotationPriorityQueue<object>("HotR"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.GoHotR, 5, 0.5, 0.8, 0.9);
            var gpWithout = new GraphParameters<object>(new RotationPriorityQueue<object>("HotR"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 5, 0.5, 0.8, 0.9);
            Assert.AreEqual(gpWith.BuffDurationInSteps(Buff.WB), gpWithout.BuffDurationInSteps(Buff.WB) * 1.5);
        }
        [Test]
        public void GcdDurationShouldBeReducedByHaste()
        {
            var gp = new GraphParameters<object>(new RotationPriorityQueue<object>("CS"), haste: 0.5);
            Assert.AreEqual(gp.StepsPerHastedGcd, gp.BuffDurationInSteps(Buff.GCD));
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
            var gpHaste = new GraphParameters<object>(new RotationPriorityQueue<object>("SotR>WoG>EF>SS>HotR>CS>J>HoW>AS>Cons>ES>HPr>LH>AW"), PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.All, haste: 0.5);
            var gp = new GraphParameters<object>(new RotationPriorityQueue<object>("SotR>WoG>EF>SS>HotR>CS>J>HoW>AS>Cons>ES>HPr>LH>AW"), PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.All, haste: 0.0);
            Assert.IsTrue(gpHaste.AbilityCooldownInSteps(Ability.AW) > gp.AbilityCooldownInSteps(Ability.AW));
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
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 3, 0, 1.0, 1.0);
            Assert.IsTrue(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 3, 0, 1.0, 1.0)));
        }
        [Test]
        public void ShouldNotHaveSameShapeIfBuffsDiffer()
        {
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 3, 0, 1.0, 1.0, new Buff[] { Buff.AW });
            Assert.IsFalse(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 3, 0, 1.0, 1.0, new Buff[] { Buff.HA })));
        }
        [Test]
        public void ShouldHaveSameShapeIfBuffsEquivalent()
        {
            Int64GraphParameters gp = new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 3, 0, 1.0, 1.0, new Buff[] { Buff.HA, Buff.AW, });
            Assert.IsTrue(gp.HasSameShape(new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 3, 0, 1.0, 1.0, new Buff[] { Buff.AW, Buff.HA, })));
        }
        [Test]
        public void ShouldHaveSameShapeIfOnlyDifferByNonZeroTransitionMagnitides()
        {
            Action<double, double, double, double, bool> DoTest = (mehit1, rhit1, mehit2, rhit2, result) =>
            {
                Assert.AreEqual(result, new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 3, 0, mehit1, rhit1)
                    .HasSameShape(new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 3, 0, mehit2, rhit2)));
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
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 3, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("Cons"), PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 3, 0, 1.0, 1.0)
                ));
        }
        [Test]
        public void ShouldNotHaveSameShapeIfTalentsDiffer()
        {
            Assert.IsTrue(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.SelflessHealer, PaladinGlyphs.None, 3, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.SelflessHealer, PaladinGlyphs.None, 3, 0, 1.0, 1.0)
                ));
            Assert.IsFalse(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.SelflessHealer, PaladinGlyphs.None, 3, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.SelflessHealer | PaladinTalents.EternalFlame, PaladinGlyphs.None, 3, 0, 1.0, 1.0)
                ));
        }
        [Test]
        public void ShouldNotHaveSameShapeIfGlyphDiffer()
        {
            Assert.IsTrue(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.GoHotR, 3, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.GoHotR, 3, 0, 1.0, 1.0)
                ));
            Assert.IsFalse(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.GoHotR, 3, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1.0, 1.0)
                ));
        }
        [Test]
        [ExpectedException(typeof(NotImplementedException))]
        public void ShouldNotHaveSameShapeIfSpecsDiffer()
        {
            Assert.IsFalse(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Ret, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 3, 0, 1.0, 1.0)
                ));
        }
        [Test]
        public void ShouldNotHaveSameShapeIfStepsPerGCDDiffer()
        {
            Assert.IsFalse(
                new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 3, 0, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 1, 0, 1.0, 1.0)
                ));
        }
        [Test]
        public void ShouldNotHaveSameShapeIfHastedSteps()
        {
            Assert.IsFalse(
                new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 3, 0.5, 1.0, 1.0)
                .HasSameShape(
                new Int64GraphParameters(AllAbilityRotation, PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 1, 0.25, 1.0, 1.0)
                ));
        }
        [Test]
        public void HotRCDShouldMatchCS()
        {
            // state space compression:
            Assert.AreEqual(GP.AbilityCooldownInSteps(Ability.CS), GP.AbilityCooldownInSteps(Ability.HotR));
        }
        [Test]
        public void MaxBuffStacks_ShouldBe1ExceptForSH3_BoG5_GoWoG()
        {
            var gp = new GraphParameters<object>(new RotationPriorityQueue<object>("AS>Cons>CS>HotR>HW>J>HoW>SotR>WoG>SS>EF>AW>FoL>ES>LH>HPr>HA"), PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.All);
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                Buff b = (Buff)i;
                int expectedStacks = 1;
                if (b == Buff.SH) expectedStacks = 3;
                if (b == Buff.BoG) expectedStacks = 5;
                if (b == Buff.GoWoG) expectedStacks = 3;
                Assert.AreEqual(expectedStacks, gp.MaxBuffStacks(b), String.Format("Expected {1} stacks for {0}", b, expectedStacks));
            }
        }
        [Test]
        public void MaxBuffStacks_ShouldBe0ForUnreachableBuffs()
        {
            Assert.AreEqual(0, new GraphParameters<object>(new RotationPriorityQueue<object>("CS"), PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 1, 0, 1, 1).MaxBuffStacks(Buff.SS));
        }
        [Test]
        public void MaxBuffStacks_ShouldBeNonZeroForPermanentBuffs()
        {
            Assert.AreEqual(1, new GraphParameters<object>(new RotationPriorityQueue<object>("CS"), PaladinSpec.Prot, PaladinTalents.None, PaladinGlyphs.None, 1, 0, 1, 1, new Buff[] {Buff.SS} ).MaxBuffStacks(Buff.SS));
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
