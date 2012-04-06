using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;

namespace Matlabadin.Tests
{
    [TestFixture]
    public class PaladinHelperTest
    {
        [Test]
        public void PaladinSpecHelper_TryParse_ShouldParseAllThreeSpecs()
        {
            PaladinSpec s;
            Assert.IsTrue(PaladinSpecHelper.TryParse("Holy", out s));
            Assert.AreEqual(PaladinSpec.Holy, s);
            Assert.IsTrue(PaladinSpecHelper.TryParse("Prot", out s));
            Assert.AreEqual(PaladinSpec.Prot, s);
            Assert.IsTrue(PaladinSpecHelper.TryParse("Ret", out s));
            Assert.AreEqual(PaladinSpec.Ret, s);
        }
        [Test]
        public void PaladinTalentsHelper_TryParse_ShouldReturnParseStatus()
        {
            PaladinTalents pt;
            Assert.IsTrue(PaladinTalentsHelper.TryParse("000000", out pt));
            Assert.IsTrue(PaladinTalentsHelper.TryParse("111111", out pt));
            Assert.IsTrue(PaladinTalentsHelper.TryParse("222222", out pt));
            Assert.IsTrue(PaladinTalentsHelper.TryParse("333333", out pt));
            Assert.IsFalse(PaladinTalentsHelper.TryParse("44444", out pt));
            Assert.IsFalse(PaladinTalentsHelper.TryParse("hadfjk", out pt));
            Assert.IsTrue(PaladinTalentsHelper.TryParse("", out pt));
            Assert.IsTrue(PaladinTalentsHelper.TryParse(null, out pt));
        }
        [Test]
        public void PaladinTalentsHelper_TryParse_ShouldParseSingleTalents()
        {
            PaladinTalents pt;
            Assert.IsTrue(PaladinTalentsHelper.TryParse("BurdenOfGuilt", out pt));
            Assert.IsTrue(PaladinTalentsHelper.TryParse("SpeedOfLight", out pt));
            Assert.IsTrue(PaladinTalentsHelper.TryParse("HolyPrism", out pt));
            Assert.IsFalse(PaladinTalentsHelper.TryParse("NotATalent", out pt));
            Assert.IsFalse(PaladinTalentsHelper.TryParse("444444", out pt));
        }
        [Test]
        public void PaladinTalentsHelper_TryParse_ShouldCombineTalents()
        {
            PaladinTalents pt;
            PaladinTalentsHelper.TryParse("000000", out pt); Assert.AreEqual(PaladinTalents.None, pt);
            PaladinTalentsHelper.TryParse("100000", out pt); Assert.AreEqual(PaladinTalents.SpeedOfLight, pt);
            PaladinTalentsHelper.TryParse("100001", out pt); Assert.AreEqual(PaladinTalents.SpeedOfLight | PaladinTalents.HolyPrism, pt);
            PaladinTalentsHelper.TryParse("300003", out pt); Assert.AreEqual(PaladinTalents.PursuitOfJustice | PaladinTalents.ExecutionSentence, pt);
        }
        [Test]
        public void PaladinTalentsHelper_TryParse_ShouldUseTalentCalculatorPosition()
        {
            PaladinTalents pt;
            PaladinTalentsHelper.TryParse("100000", out pt); Assert.AreEqual(PaladinTalents.SpeedOfLight, pt);
            PaladinTalentsHelper.TryParse("200000", out pt); Assert.AreEqual(PaladinTalents.LongArmOfTheLaw, pt);
            PaladinTalentsHelper.TryParse("300000", out pt); Assert.AreEqual(PaladinTalents.PursuitOfJustice, pt);
            PaladinTalentsHelper.TryParse("010000", out pt); Assert.AreEqual(PaladinTalents.FistOfJustice, pt);
            PaladinTalentsHelper.TryParse("020000", out pt); Assert.AreEqual(PaladinTalents.Repentance, pt);
            PaladinTalentsHelper.TryParse("030000", out pt); Assert.AreEqual(PaladinTalents.BurdenOfGuilt, pt);
            PaladinTalentsHelper.TryParse("001000", out pt); Assert.AreEqual(PaladinTalents.SelflessHealer, pt);
            PaladinTalentsHelper.TryParse("002000", out pt); Assert.AreEqual(PaladinTalents.EternalFlame, pt);
            PaladinTalentsHelper.TryParse("003000", out pt); Assert.AreEqual(PaladinTalents.SacredShield, pt);
            PaladinTalentsHelper.TryParse("000100", out pt); Assert.AreEqual(PaladinTalents.HandOfPurity, pt);
            PaladinTalentsHelper.TryParse("000200", out pt); Assert.AreEqual(PaladinTalents.UnbreakableSpirit, pt);
            PaladinTalentsHelper.TryParse("000300", out pt); Assert.AreEqual(PaladinTalents.Clemency, pt);
            PaladinTalentsHelper.TryParse("000010", out pt); Assert.AreEqual(PaladinTalents.HolyAvenger, pt);
            PaladinTalentsHelper.TryParse("000020", out pt); Assert.AreEqual(PaladinTalents.SanctifiedWrath, pt);
            PaladinTalentsHelper.TryParse("000030", out pt); Assert.AreEqual(PaladinTalents.DivinePurpose, pt);
            PaladinTalentsHelper.TryParse("000001", out pt); Assert.AreEqual(PaladinTalents.HolyPrism, pt);
            PaladinTalentsHelper.TryParse("000002", out pt); Assert.AreEqual(PaladinTalents.LightsHammer, pt);
            PaladinTalentsHelper.TryParse("000003", out pt); Assert.AreEqual(PaladinTalents.ExecutionSentence, pt);
        }
        [Test]
        public void PaladinTalentsHelper_TryParse_ShouldUseTalentName()
        {
            PaladinTalents pt;
            PaladinTalentsHelper.TryParse("BurdenOfGuilt", out pt); Assert.AreEqual(PaladinTalents.BurdenOfGuilt, pt);
            PaladinTalentsHelper.TryParse("SpeedOfLight", out pt); Assert.AreEqual(PaladinTalents.SpeedOfLight, pt);
        }
        [Test]
        public void PaladinTalents_All_ShouldContainAllImplementedTalents()
        {
            Assert.AreEqual(
                PaladinTalents.SelflessHealer |
                PaladinTalents.EternalFlame |
                PaladinTalents.SacredShield,
                PaladinTalents.All);
        }
        [Test]
        public void PaladinTalents_ToLongString_ShouldSemicolonSeperateTalentsInTalentCalculatorOrder()
        {
            Assert.AreEqual("SpeedOfLight;SelflessHealer;EternalFlame;HolyPrism",
                (PaladinTalents.SpeedOfLight | PaladinTalents.SelflessHealer | PaladinTalents.HolyPrism | PaladinTalents.EternalFlame)
                .ToLongString());
            Assert.AreEqual("None", PaladinTalents.None.ToLongString());
            Assert.AreEqual("ExecutionSentence", PaladinTalents.ExecutionSentence.ToLongString());
        }
        [Test]
        public void PaladinTalents_Includes()
        {
            Assert.IsTrue(PaladinTalents.ExecutionSentence.Includes(PaladinTalents.ExecutionSentence));
            Assert.IsTrue((PaladinTalents.ExecutionSentence | PaladinTalents.EternalFlame).Includes(PaladinTalents.ExecutionSentence));
            Assert.IsFalse(PaladinTalents.ExecutionSentence.Includes(PaladinTalents.EternalFlame));
            Assert.IsFalse(PaladinTalents.None.Includes(PaladinTalents.EternalFlame));
        }
    }
}