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
        [TestMethod]
        public void ChoiceShouldExposeOptions()
        {
            Choice c = Choice.CreateChoice(0, DefaultParameters, Ability.CS, 3, 0.7, 0.2, 0.1);
            Assert.AreEqual(0.7, c.option1);
            Assert.AreEqual(0.2, c.option2);
            Assert.AreEqual(0.1, c.option3);
        }
        [TestMethod]
        public void ChoiceShouldExposeDuration()
        {
            Choice c = Choice.CreateChoice(0, DefaultParameters, Ability.CS, 3, 0.7, 0.2, 0.1);
            Assert.AreEqual(0.7, c.option1);
            Assert.AreEqual(0.2, c.option2);
            Assert.AreEqual(0.1, c.option3);
        }
        [TestMethod]
        public void InqCastShouldSetInqUptime()
        {
            Assert.IsTrue(Choice.CreateChoice(3, DefaultParameters, Ability.Inq, 3, 1, 0, 0).inqDuration > 0);
        }
        [TestMethod]
        public void ActionShouldBeAbility()
        {
            Assert.AreEqual("CS", Choice.CreateChoice(0, DefaultParameters, Ability.CS, 3, 1, 0, 0).Action);
            Assert.AreEqual("HW", Choice.CreateChoice(0, DefaultParameters, Ability.HW, 3, 1, 0, 0).Action);
            Assert.AreEqual("Nothing", Choice.CreateChoice(0, DefaultParameters, Ability.Nothing, 3, 1, 0, 0).Action);
        }
        [TestMethod]
        public void ActionShouldSuffixInq()
        {
            Choice c = Choice.CreateChoice(GetState(Buff.Inq, 1), DefaultParameters, Ability.CS, 3, 0.7, 0.2, 0.1);
            Assert.AreEqual("CS(Inq)", c.Action);
        }
        [TestMethod]
        public void ActionShouldSuffixSDBeforeInqForSotROnly()
        {
            Assert.AreEqual("CS", Choice.CreateChoice(GetState(Buff.SD, 1, 3), DefaultParameters, Ability.CS, 3, 1, 0, 0).Action);
            Assert.AreEqual("SotR(SD)", Choice.CreateChoice(GetState(Buff.SD, 1, 3), DefaultParameters, Ability.SotR, 3, 1, 0, 0).Action);
            Assert.AreEqual("SotR2(SD)", Choice.CreateChoice(GetState(Buff.SD, 1, 2), DefaultParameters, Ability.SotR, 3, 1, 0, 0).Action);
            Assert.AreEqual("SotR(SD)(Inq)", Choice.CreateChoice(GetState(Buff.SD, 1, Buff.Inq, 1, 3), DefaultParameters, Ability.SotR, 3, 1, 0, 0).Action);
            Assert.AreEqual("SotR2(SD)(Inq)", Choice.CreateChoice(GetState(Buff.SD, 1, Buff.Inq, 1, 2), DefaultParameters, Ability.SotR, 3, 1, 0, 0).Action);
        }
        [TestMethod]
        public void ActionShouldSuffixHPForSotRAndWoGWhenNotMaxHP()
        {
            Assert.AreEqual("SotR0", Choice.CreateChoice(0, DefaultParameters, Ability.SotR, 3, 1, 0, 0).Action);
            Assert.AreEqual("SotR1", Choice.CreateChoice(1, DefaultParameters, Ability.SotR, 3, 1, 0, 0).Action);
            Assert.AreEqual("SotR2", Choice.CreateChoice(2, DefaultParameters, Ability.SotR, 3, 1, 0, 0).Action);
            Assert.AreEqual("SotR", Choice.CreateChoice(3, DefaultParameters, Ability.SotR, 3, 1, 0, 0).Action);
            Assert.AreEqual("WoG0", Choice.CreateChoice(0, DefaultParameters, Ability.WoG, 3, 1, 0, 0).Action);
            Assert.AreEqual("WoG1", Choice.CreateChoice(1, DefaultParameters, Ability.WoG, 3, 1, 0, 0).Action);
            Assert.AreEqual("WoG2", Choice.CreateChoice(2, DefaultParameters, Ability.WoG, 3, 1, 0, 0).Action);
            Assert.AreEqual("WoG", Choice.CreateChoice(3, DefaultParameters, Ability.WoG, 3, 1, 0, 0).Action);
        }
        [TestMethod]
        public void ChoiceDefineEqualityAndHashCode()
        {
            Choice c11 = Choice.CreateChoice(0, DefaultParameters, Ability.CS, 3, 0.7, 0.2, 0.1);
            Choice c12 = Choice.CreateChoice(0, DefaultParameters, Ability.CS, 3, 0.7, 0.2, 0.1);
            Choice c21 = Choice.CreateChoice(0, DefaultParameters, Ability.Inq, 3, 0.7, 0.2, 0.1);
            Choice c22 = Choice.CreateChoice(0, DefaultParameters, Ability.Inq, 3, 0.7, 0.2, 0.1);
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
        }
    }
}

