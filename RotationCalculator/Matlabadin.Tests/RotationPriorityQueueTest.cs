using Matlabadin;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace Matlabadin.Tests
{
    [TestClass]
    public class RotationPriorityQueueTest : MatlabadinTest
    {
        private void DoTest(string queue, ulong state, Ability expected)
        {
            RotationPriorityQueue rpq = new RotationPriorityQueue(queue);
            Assert.AreEqual(expected, rpq.ActionToTake(state, DefaultParameters));
        }
        [TestMethod]
        public void ShouldUseSingleAbilityOffCooldown()
        {
            Action<string> doTest = (queue) =>
            {
                DoTest(queue, StateHelper.SetHP(0, 3, DefaultParameters), (Ability)Enum.Parse(typeof(Ability), queue, false));
            };
            doTest("CS");
            doTest("SotR");
            doTest("HoW");
            doTest("HW");
            doTest("SotR");
            doTest("WoG");
            doTest("HotR");
            doTest("Cons");
            doTest("AS");
            doTest("Inq");
            doTest("J");
        }
        [TestMethod]
        public void SotRShouldBeSotR3()
        {
            DoTest("SotR", 0, Ability.Nothing);
            DoTest("SotR", 1, Ability.Nothing);
            DoTest("SotR", 2, Ability.Nothing);
            DoTest("SotR", 3, Ability.SotR);
        }
        [TestMethod]
        public void SotR2ShouldFireOn2Or3()
        {
            DoTest("SotR2", 0, Ability.Nothing);
            DoTest("SotR2", 1, Ability.Nothing);
            DoTest("SotR2", 2, Ability.SotR);
            DoTest("SotR2", 3, Ability.SotR);
        }
        [TestMethod]
        public void ShouldPrioritiseHigherAbilities()
        {
            DoTest("CS>HW", 0, Ability.CS);
            DoTest("HW>CS", 0, Ability.HW);
        }
        [TestMethod]
        public void ASPlusShouldUseASIfWillGenerateHP()
        {
            DoTest("AS+>CS", GetState(Buff.GC, 1), Ability.AS);
            DoTest("AS+>CS", 0, Ability.CS);
        }
        [TestMethod]
        public void CreateRotationPriorityQueueNextStateFunctionShouldCreateNextStateFunction()
        {
            var f = RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction("CS>HW");
            Assert.AreEqual(Ability.CS, f(0, DefaultParameters));
        }
        [TestMethod]
        public void SDPrefixShouldRequireSDBuff()
        {
            DoTest("SDCS", 0, Ability.Nothing);
            DoTest("SDCS", GetState(Buff.SD, 1), Ability.CS);
            DoTest("SDSotR", 3, Ability.Nothing);
            DoTest("SDSotR", GetState(Buff.SD, 1, 3), Ability.SotR);
        }
        [TestMethod]
        public void sdPrefixShouldRequireNoSDBuff()
        {
            DoTest("sdCS", 0, Ability.CS);
            DoTest("sdCS", GetState(Buff.SD, 1), Ability.Nothing);
            DoTest("sdSotR", 3, Ability.SotR);
            DoTest("sdSotR", GetState(Buff.SD, 1, 3), Ability.Nothing);
        }
        [TestMethod]
        public void IPrefixShouldRequireIBuff()
        {
            DoTest("ICS", 0, Ability.Nothing);
            DoTest("ICS", GetState(Buff.INQ, 1), Ability.CS);
            DoTest("ISotR", 3, Ability.Nothing);
            DoTest("ISotR", GetState(Buff.INQ, 1, 3), Ability.SotR);
        }
        [TestMethod]
        public void iPrefixShouldRequireNoInqBuff()
        {
            DoTest("iCS", 0, Ability.CS);
            DoTest("iCS", GetState(Buff.INQ, 1), Ability.Nothing);
            DoTest("iSotR", 3, Ability.SotR);
            DoTest("iSotR", GetState(Buff.INQ, 1, 3), Ability.Nothing);
        }
        [TestMethod]
        public void Inq2ShouldRequire2HP()
        {
            DoTest("Inq2", 0, Ability.Nothing);
            DoTest("Inq2", 1, Ability.Nothing);
            DoTest("Inq2", 2, Ability.Inq);
            DoTest("Inq2", 3, Ability.Inq);
        }
    }
}
