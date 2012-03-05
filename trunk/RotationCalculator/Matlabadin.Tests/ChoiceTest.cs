using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Matlabadin.Tests
{
    [TestClass]
    public class ChoiceTest : MatlabadinTest
    {
        double[] PR = new double[] { 1 };
        [TestMethod]
        public void ChoiceShouldExposeOptions()
        {
            Choice<ulong> c = Choice<ulong>.CreateChoice(GP, SM, 0, Ability.CS, 3, new double[] {0.7, 0.2, 0.1});
            Assert.AreEqual(0.7, c.pr[0]);
            Assert.AreEqual(0.2, c.pr[1]);
            Assert.AreEqual(0.1, c.pr[2]);
        }
        [TestMethod]
        public void ChoiceShouldExposeDuration()
        {
            Choice<ulong> c = Choice<ulong>.CreateChoice(GP, SM, 0, Ability.CS, 3, new double[] {0.7, 0.2, 0.1});
            Assert.AreEqual(3, c.stepsDuration);
        }
        [TestMethod]
        public void ChoiceShouldExposeStepsThatHaveSSBuffActiveInDuration()
        {
            Assert.AreEqual(3, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SS, 5), Ability.CS, 3, PR).ssDuration);
            Assert.AreEqual(1, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SS, 1), Ability.CS, 3, PR).ssDuration);
        }
        [TestMethod]
        public void ChoiceShouldExposeStepsThatHaveEFBuffActiveInDuration()
        {
            Assert.AreEqual(3, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.EF, 5), Ability.CS, 3, PR).efDuration);
            Assert.AreEqual(1, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.EF, 1), Ability.CS, 3, PR).efDuration);
        }
        [TestMethod]
        public void ChoiceShouldExposeStepsThatHaveWBBuffActiveInDuration()
        {
            Assert.AreEqual(3, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.WB, 5), Ability.CS, 3, PR).wbDuration);
            Assert.AreEqual(1, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.WB, 1), Ability.CS, 3, PR).wbDuration);
        }
        [TestMethod]
        public void ChoiceShouldExposeStepsThatHaveSBBuffActiveInDuration()
        {
            Assert.AreEqual(3, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SotRSB, 5), Ability.CS, 3, PR).sbDuration);
            Assert.AreEqual(1, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SotRSB, 1), Ability.CS, 3, PR).sbDuration);
        }
        [TestMethod]
        public void SSCastShouldSetSSUptime()
        {
            Assert.IsTrue(Choice<ulong>.CreateChoice(GP, SM, 3, Ability.SS, 3, new double[] { 1 }).ssDuration > 0);
        }
        [TestMethod]
        public void EFCastShouldSetEFUptime()
        {
            Assert.IsTrue(Choice<ulong>.CreateChoice(GP, SM, 3, Ability.EF, 3, new double[] { 1 }).efDuration > 0);
        }
        [TestMethod]
        public void HotRCastShouldSetWeakenedBlowsUptime()
        {
            Assert.IsTrue(Choice<ulong>.CreateChoice(GP, SM, 3, Ability.HotR, 3, new double[] { 1 }).wbDuration > 0);
        }
        [TestMethod]
        public void SotRCastShouldSetShieldBlockUptime()
        {
            Assert.IsTrue(Choice<ulong>.CreateChoice(GP, SM, 3, Ability.SotR, 3, new double[] {1}).sbDuration > 0);
        }
        [TestMethod]
        public void ActionShouldBeAbility()
        {
            Assert.AreEqual("CS", Choice<ulong>.CreateChoice(GP, SM, 0, Ability.CS, 3, PR).Action);
            Assert.AreEqual("J", Choice<ulong>.CreateChoice(GP, SM, 0, Ability.J, 3, PR).Action);
            Assert.AreEqual("Nothing", Choice<ulong>.CreateChoice(GP, SM, 0, Ability.Nothing, 3, PR).Action);
        }
        [TestMethod]
        public void ActionShouldSuffixSSForWoGOnly()
        {
            Assert.AreEqual("CS", Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SS, 1, 3), Ability.CS, 3, PR).Action);
            Assert.AreEqual("WoG(SS)", Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SS, 1, 4), Ability.WoG, 3, PR).Action);
            Assert.AreEqual("WoG(SS)", Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SS, 1, 3), Ability.WoG, 3, PR).Action);
            Assert.AreEqual("WoG2(SS)", Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SS, 1, 2), Ability.WoG, 3, PR).Action);
        }
        [TestMethod]
        public void ActionShouldSuffixHPForWoGAndEFWhenLessThan3()
        {
            Assert.AreEqual("EF0", Choice<ulong>.CreateChoice(GP, SM, 0, Ability.EF, 3, PR).Action);
            Assert.AreEqual("EF1", Choice<ulong>.CreateChoice(GP, SM, 1, Ability.EF, 3, PR).Action);
            Assert.AreEqual("EF2", Choice<ulong>.CreateChoice(GP, SM, 2, Ability.EF, 3, PR).Action);
            Assert.AreEqual("EF", Choice<ulong>.CreateChoice(GP, SM, 3, Ability.EF, 3, PR).Action);
            Assert.AreEqual("EF", Choice<ulong>.CreateChoice(GP, SM, 4, Ability.EF, 3, PR).Action);
            Assert.AreEqual("EF", Choice<ulong>.CreateChoice(GP, SM, 5, Ability.EF, 3, PR).Action);
            Assert.AreEqual("WoG0", Choice<ulong>.CreateChoice(GP, SM, 0, Ability.WoG, 3, PR).Action);
            Assert.AreEqual("WoG1", Choice<ulong>.CreateChoice(GP, SM, 1, Ability.WoG, 3, PR).Action);
            Assert.AreEqual("WoG2", Choice<ulong>.CreateChoice(GP, SM, 2, Ability.WoG, 3, PR).Action);
            Assert.AreEqual("WoG", Choice<ulong>.CreateChoice(GP, SM, 3, Ability.WoG, 3, PR).Action);
            Assert.AreEqual("WoG", Choice<ulong>.CreateChoice(GP, SM, 4, Ability.WoG, 3, PR).Action);
            Assert.AreEqual("WoG", Choice<ulong>.CreateChoice(GP, SM, 5, Ability.WoG, 3, PR).Action);
        }
        [TestMethod]
        public void ChoiceDefineEqualityAndHashCode()
        {
            Choice<ulong> c11 = Choice<ulong>.CreateChoice(GP, SM, 0, Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 });
            Choice<ulong> c12 = Choice<ulong>.CreateChoice(GP, SM, 0, Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 });
            Choice<ulong> c21 = Choice<ulong>.CreateChoice(GP, SM, 0, Ability.SS, 3, new double[] { 0.7, 0.2, 0.1 });
            Choice<ulong> c22 = Choice<ulong>.CreateChoice(GP, SM, 0, Ability.SS, 3, new double[] { 0.7, 0.2, 0.1 });
            Assert.AreEqual(c11, c12);
            Assert.AreEqual(c21, c22);
            Assert.AreEqual(c12, c11);
            Assert.AreEqual(c22, c21);
            Assert.AreNotEqual(c11, c21);
            Assert.AreNotEqual(c11, c22);
            Assert.AreNotEqual(c12, c21);
            Assert.AreNotEqual(c12, c22);
            Assert.AreEqual(c11.GetHashCode(), c12.GetHashCode());
            Assert.AreEqual(c21.GetHashCode(), c22.GetHashCode());
            Assert.AreEqual(c12.GetHashCode(), c11.GetHashCode());
            Assert.AreEqual(c22.GetHashCode(), c21.GetHashCode());
            Assert.AreNotEqual(c11.GetHashCode(), c21.GetHashCode());
            Assert.AreNotEqual(c11.GetHashCode(), c22.GetHashCode());
            Assert.AreNotEqual(c12.GetHashCode(), c21.GetHashCode());
            Assert.AreNotEqual(c12.GetHashCode(), c22.GetHashCode());

            // duration & probabilies also change equality
            Assert.AreNotEqual(Choice<ulong>.CreateChoice(GP, SM, 0, Ability.SS, 2, new double[] { 0.7, 0.2, 0.1 }),
                               Choice<ulong>.CreateChoice(GP, SM, 0, Ability.SS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreNotEqual(Choice<ulong>.CreateChoice(GP, SM, 0, Ability.SS, 3, new double[] { 0.7, 0.3 }),
                               Choice<ulong>.CreateChoice(GP, SM, 0, Ability.SS, 3, new double[] { 0.7, 0.2, 0.1 }));
        }
        [TestMethod]
        public void EqualityShouldIncludeSSDuration()
        {            
            Choice<ulong> c = Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SS, 3), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 });
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SS, 0), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SS, 1), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SS, 2), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SS, 3), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SS, 4), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
        }
        [TestMethod]
        public void EqualityShouldIncludeEFDuration()
        {
            Choice<ulong> c = Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.EF, 3), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 });
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.EF, 0), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.EF, 1), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.EF, 2), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.EF, 3), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.EF, 4), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
        }
        [TestMethod]
        public void EqualityShouldIncludeWBDuration()
        {
            Choice<ulong> c = Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.WB, 3), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 });
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.WB, 0), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.WB, 1), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.WB, 2), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.WB, 3), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.WB, 4), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
        }
        [TestMethod]
        public void EqualityShouldIncludeSBDuration()
        {
            Choice<ulong> c = Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SotRSB, 3), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 });
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SotRSB, 0), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SotRSB, 1), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SotRSB, 2), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SotRSB, 3), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SotRSB, 4), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
        }
        [TestMethod]
        [ExpectedException(typeof(InvalidOperationException))]
        public void ConcatenateShouldNotAllowConcatenationToActualAbilities()
        {
            Choice<ulong> cCS = Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SS, 3), Ability.CS, 3, new double[] { 1 });
            Choice<ulong> cNothing = Choice<ulong>.CreateChoice(GP, SM, 0, Ability.Nothing, 1, new double[] { 1 });
            cCS.Concatenate(cNothing);
        }
        [TestMethod]
        [ExpectedException(typeof(InvalidOperationException))]
        public void ConcatenateShouldNotAllowConcatenationWhenThereIsAChoiceOfNextStates()
        {
            Choice<ulong> cNothing = Choice<ulong>.CreateChoice(GP, SM, 0, Ability.Nothing, 1, new double[] { 0.5, 0.5 });
            cNothing.Concatenate(cNothing);
        }
        [TestMethod]
        public void ConcatenateShouldAddStepsDurations()
        {
            Choice<ulong> cNothing = Choice<ulong>.CreateChoice(GP, SM, 0, Ability.Nothing, 1, new double[] { 1 });
            Choice<ulong> c = cNothing.Concatenate(cNothing);
            Assert.AreEqual(2, c.stepsDuration, 2);
        }
        [TestMethod]
        public void ConcatenateShouldAddSSDurations()
        {
            Choice<ulong> cNothing = Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SS, 5), Ability.Nothing, 1, new double[] { 1 });
            Choice<ulong> c = cNothing.Concatenate(cNothing);
            Assert.AreEqual(2, c.ssDuration);
        }
        [TestMethod]
        public void ConcatenateShouldAddEFDurations()
        {
            Choice<ulong> cNothing = Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.EF, 5), Ability.Nothing, 1, new double[] { 1 });
            Choice<ulong> c = cNothing.Concatenate(cNothing);
            Assert.AreEqual(2, c.efDuration);
        }
        [TestMethod]
        public void ConcatenateShouldAddWBDurations()
        {
            Choice<ulong> cNothing = Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.WB, 5), Ability.Nothing, 1, new double[] { 1 });
            Choice<ulong> c = cNothing.Concatenate(cNothing);
            Assert.AreEqual(2, c.wbDuration);
        }
        [TestMethod]
        public void ConcatenateShouldAddSBDurations()
        {
            Choice<ulong> cNothing = Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SotRSB, 5), Ability.Nothing, 1, new double[] { 1 });
            Choice<ulong> c = cNothing.Concatenate(cNothing);
            Assert.AreEqual(2, c.sbDuration);
        }
        [TestMethod]
        public void ConcatenateShouldSetSSBasedOnAbilityUsage()
        {
            Choice<ulong> cNothing = Choice<ulong>.CreateChoice(GP, SM, 1, Ability.Nothing, 1, new double[] { 1 });
            Assert.IsFalse(cNothing.Action.Contains("(SS)")); // no SS
            Choice<ulong> c = cNothing.Concatenate(
                Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SS, 1, 3), Ability.WoG, 3, new double[] { 1 }));
            Assert.IsTrue(c.Action.Contains("(SS)"));
        }
        [TestMethod]
        public void ConcatenateShouldSetHPBasedOnAbilityUsage()
        {
            Choice<ulong> cNothing = Choice<ulong>.CreateChoice(GP, SM, 2, Ability.Nothing, 1, new double[] { 1 });
            Choice<ulong> c = cNothing.Concatenate(
                Choice<ulong>.CreateChoice(GP, SM, 2, Ability.WoG, 3, new double[] { 1 }));
            // Test data only possible if we introduce HP decay modelling which is unlikely
            Assert.IsTrue(c.Action.Contains("1"));
        }
        [TestMethod]
        public void ConcatenateShouldSetPrBasedOnContatenatedChoice()
        {
            double[] pr = new double[] { 0.5, 0.5 };
            Choice<ulong> cNothing = Choice<ulong>.CreateChoice(GP, SM, 3, Ability.Nothing, 1, new double[] { 1 });
            Choice<ulong> c = cNothing.Concatenate(
                Choice<ulong>.CreateChoice(GP, SM, 3, Ability.SotR, 3, pr));
            Assert.AreEqual(pr, c.pr);
        }
    }
}

