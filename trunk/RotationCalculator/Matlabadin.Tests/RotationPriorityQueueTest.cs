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
        public void ASPlusShouldFishForSDProcs()
        {
            DoTest("AS+>CS", 0, Ability.AS);
            DoTest("AS+>CS", GetState(Buff.SD, 4), Ability.CS);
        }
        [TestMethod]
        public void CreateRotationPriorityQueueNextStateFunctionShouldCreateNextStateFunction()
        {
            var f = RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction("CS>HW");
            Assert.AreEqual(Ability.CS, f(0, DefaultParameters));
        }
    }
}
