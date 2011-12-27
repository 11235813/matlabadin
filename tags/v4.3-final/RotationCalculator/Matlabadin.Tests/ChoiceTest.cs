﻿using System;
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
        public void ChoiceShouldExposeInqStepsThatHaveInqActiveInDuration()
        {
            Assert.AreEqual(3, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.Inq, 5), Ability.CS, 3, PR).inqDuration);
            Assert.AreEqual(1, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.Inq, 1), Ability.CS, 3, PR).inqDuration);
        }
        [TestMethod]
        public void InqCastShouldSetInqUptime()
        {
            Assert.IsTrue(Choice<ulong>.CreateChoice(GP, SM, 3, Ability.Inq, 3, new double[] {1}).inqDuration > 0);
        }
        [TestMethod]
        public void JCastShouldSetJotwUptime()
        {
            Assert.IsTrue(Choice<ulong>.CreateChoice(GP, SM, 3, Ability.J, 3, new double[] {1}).jotwDuration > 0);
        }
        [TestMethod]
        public void ActionShouldBeAbility()
        {
            Assert.AreEqual("CS", Choice<ulong>.CreateChoice(GP, SM, 0, Ability.CS, 3, PR).Action);
            Assert.AreEqual("HW", Choice<ulong>.CreateChoice(GP, SM, 0, Ability.HW, 3, PR).Action);
            Assert.AreEqual("Nothing", Choice<ulong>.CreateChoice(GP, SM, 0, Ability.Nothing, 3, PR).Action);
        }
        [TestMethod]
        public void ActionShouldSuffixInq()
        {
            Choice<ulong> c = Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.Inq, 1), Ability.CS, 3, PR);
            Assert.AreEqual("CS(Inq)", c.Action);
        }
        [TestMethod]
        public void ActionShouldSuffixSDBeforeInqForSotROnly()
        {
            Assert.AreEqual("CS", Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SD, 1, 3), Ability.CS, 3, PR).Action);
            Assert.AreEqual("SotR(SD)", Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SD, 1, 3), Ability.SotR, 3, PR).Action);
            Assert.AreEqual("SotR2(SD)", Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SD, 1, 2), Ability.SotR, 3, PR).Action);
            Assert.AreEqual("SotR(SD)(Inq)", Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SD, 1, Buff.Inq, 1, 3), Ability.SotR, 3, PR).Action);
            Assert.AreEqual("SotR2(SD)(Inq)", Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SD, 1, Buff.Inq, 1, 2), Ability.SotR, 3, PR).Action);
        }
        [TestMethod]
        public void ActionShouldSuffixHPForSotRAndWoGWhenNotMaxHP()
        {
            Assert.AreEqual("SotR0", Choice<ulong>.CreateChoice(GP, SM, 0, Ability.SotR, 3, PR).Action);
            Assert.AreEqual("SotR1", Choice<ulong>.CreateChoice(GP, SM, 1, Ability.SotR, 3, PR).Action);
            Assert.AreEqual("SotR2", Choice<ulong>.CreateChoice(GP, SM, 2, Ability.SotR, 3, PR).Action);
            Assert.AreEqual("SotR", Choice<ulong>.CreateChoice(GP, SM, 3, Ability.SotR, 3, PR).Action);
            Assert.AreEqual("WoG0", Choice<ulong>.CreateChoice(GP, SM, 0, Ability.WoG, 3, PR).Action);
            Assert.AreEqual("WoG1", Choice<ulong>.CreateChoice(GP, SM, 1, Ability.WoG, 3, PR).Action);
            Assert.AreEqual("WoG2", Choice<ulong>.CreateChoice(GP, SM, 2, Ability.WoG, 3, PR).Action);
            Assert.AreEqual("WoG", Choice<ulong>.CreateChoice(GP, SM, 3, Ability.WoG, 3, PR).Action);
        }
        [TestMethod]
        public void ChoiceDefineEqualityAndHashCode()
        {
            Choice<ulong> c11 = Choice<ulong>.CreateChoice(GP, SM, 0, Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 });
            Choice<ulong> c12 = Choice<ulong>.CreateChoice(GP, SM, 0, Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 });
            Choice<ulong> c21 = Choice<ulong>.CreateChoice(GP, SM, 0, Ability.Inq, 3, new double[] { 0.7, 0.2, 0.1 });
            Choice<ulong> c22 = Choice<ulong>.CreateChoice(GP, SM, 0, Ability.Inq, 3, new double[] { 0.7, 0.2, 0.1 });
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
            Assert.AreNotEqual(Choice<ulong>.CreateChoice(GP, SM, 0, Ability.Inq, 2, new double[] { 0.7, 0.2, 0.1 }),
                               Choice<ulong>.CreateChoice(GP, SM, 0, Ability.Inq, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreNotEqual(Choice<ulong>.CreateChoice(GP, SM, 0, Ability.Inq, 3, new double[] { 0.7, 0.3 }),
                               Choice<ulong>.CreateChoice(GP, SM, 0, Ability.Inq, 3, new double[] { 0.7, 0.2, 0.1 }));
        }
        [TestMethod]
        public void EqualityShouldIncludeInqDuration()
        {            
            Choice<ulong> c = Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.Inq, 3), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 });
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.Inq, 0), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.Inq, 1), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.Inq, 2), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.Inq, 3), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.Inq, 4), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
        }
        [TestMethod]
        public void EqualityShouldIncludeJotwDuration()
        {
            Choice<ulong> c = Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.JotW, 3), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 });
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.JotW, 0), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.JotW, 1), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreNotEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.JotW, 2), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.JotW, 3), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
            Assert.AreEqual(c, Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.JotW, 4), Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }));
        }
        [TestMethod]
        [ExpectedException(typeof(InvalidOperationException))]
        public void ConcatenateShouldNotAllowConcatenationToActualAbilities()
        {
            Choice<ulong> cCS = Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.JotW, 3), Ability.CS, 3, new double[] { 1 });
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
            Assert.AreEqual(c.stepsDuration, 2);
            Assert.AreEqual(c.stepsDuration, 2);
            Assert.AreEqual(c.stepsDuration, 2);
        }
        [TestMethod]
        public void ConcatenateShouldAddInqDurations()
        {
            Choice<ulong> cNothing = Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.JotW, 5), Ability.Nothing, 1, new double[] { 1 });
            Choice<ulong> c = cNothing.Concatenate(cNothing);
            Assert.AreEqual(c.jotwDuration, 2);
        }
        [TestMethod]
        public void ConcatenateShouldAddJotwDurations()
        {
            Choice<ulong> cNothing = Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.Inq, 5), Ability.Nothing, 1, new double[] { 1 });
            Choice<ulong> c = cNothing.Concatenate(cNothing);
            Assert.AreEqual(c.inqDuration, 2);
        }
        [TestMethod]
        public void ConcatenateShouldSetSDBasedOnAbilityUsage()
        {
            Choice<ulong> cNothing = Choice<ulong>.CreateChoice(GP, SM, 1, Ability.Nothing, 1, new double[] { 1 });
            Assert.IsFalse(cNothing.Action.Contains("(SD)")); // no SD buff initially
            Choice<ulong> c = cNothing.Concatenate(
                Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SD, 3, 3), Ability.SotR, 3, new double[] { 1 }));
            Assert.IsTrue(c.Action.Contains("(SD)"));
        }
        [TestMethod]
        public void ConcatenateShouldSetHPBasedOnAbilityUsage()
        {
            Choice<ulong> cNothing = Choice<ulong>.CreateChoice(GP, SM, 2, Ability.Nothing, 1, new double[] { 1 });
            Choice<ulong> c = cNothing.Concatenate(
                Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SD, 3, 1), Ability.SotR, 3, new double[] { 1 }));
            // Test data only possible if we introduce HP decay modelling which is unlikely
            Assert.IsTrue(c.Action.Contains("1"));
        }
        [TestMethod]
        public void ConcatenateShouldSetPrBasedOnContatenatedChoice()
        {
            double[] pr = new double[] { 0.5, 0.5 };
            Choice<ulong> cNothing = Choice<ulong>.CreateChoice(GP, SM, 3, Ability.Nothing, 1, new double[] { 1 });
            Choice<ulong> c = cNothing.Concatenate(
                Choice<ulong>.CreateChoice(GP, SM, GetState(SM, Buff.SD, 3, 1), Ability.SotR, 3, pr));
            Assert.AreEqual(pr, c.pr);
        }
    }
}

