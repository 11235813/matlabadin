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
            Int64GraphParameters gp = NoHitExpertise(queue);
            Assert.AreEqual(expected, gp.Rotation.ActionToTake(gp, gp, state));
        }
        private void DoTest(Int64GraphParameters gp, ulong state, Ability expected)
        {
            Assert.AreEqual(expected, gp.Rotation.ActionToTake(gp, gp, state));
        }
        [TestMethod]
        public void ShouldUseSingleAbilityOffCooldown()
        {
            Action<string> doTest = (ability) =>
            {
                Int64GraphParameters gp = NoHitExpertise(ability);
                DoTest(gp, gp.SetHP(0, 3), (Ability)Enum.Parse(typeof(Ability), ability, false));
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
            Int64GraphParameters gp = NoHitExpertise("AS+>CS");
            DoTest(gp, GetState(gp, Buff.GC, 1), Ability.AS);
            DoTest(gp, 0, Ability.CS);
        }
        [TestMethod]
        public void SDPrefixShouldRequireSDBuff()
        {
            Int64GraphParameters gp = NoHitExpertise("SDCS");
            DoTest(gp, 0, Ability.Nothing);
            DoTest(gp, GetState(gp, Buff.SD, 1), Ability.CS);

            gp = NoHitExpertise("SDSotR");
            DoTest(gp, 3, Ability.Nothing);
            DoTest(gp, GetState(gp, Buff.SD, 1, 3), Ability.SotR);
        }
        [TestMethod]
        public void sdPrefixShouldRequireNoSDBuff()
        {
            Int64GraphParameters gp = NoHitExpertise("sdCS");
            DoTest(gp, 0, Ability.CS);
            DoTest(gp, GetState(gp, Buff.SD, 1), Ability.Nothing);

            gp = NoHitExpertise("sdSotR");
            DoTest(gp, 3, Ability.SotR);
            DoTest(gp, GetState(gp, Buff.SD, 1, 3), Ability.Nothing);
        }
        [TestMethod]
        public void IPrefixShouldRequireIBuff()
        {
            Int64GraphParameters gp = NoHitExpertise("ICS");
            DoTest(gp, 0, Ability.Nothing);
            DoTest(gp, GetState(gp, Buff.Inq, 1), Ability.CS);

            gp = NoHitExpertise("ISotR");
            DoTest(gp, 3, Ability.Nothing);
            DoTest(gp, GetState(gp, Buff.Inq, 1, 3), Ability.SotR);
        }
        [TestMethod]
        public void iPrefixShouldRequireNoInqBuff()
        {
            Int64GraphParameters gp = NoHitExpertise("iCS");
            DoTest(gp, 0, Ability.CS);
            DoTest(gp, GetState(gp, Buff.Inq, 1), Ability.Nothing);
            gp = NoHitExpertise("iSotR");
            DoTest(gp, 3, Ability.SotR);
            DoTest(gp, GetState(gp, Buff.Inq, 1, 3), Ability.Nothing);
        }
        [TestMethod]
        public void Inq2ShouldRequire2HP()
        {
            Int64GraphParameters gp = NoHitExpertise("Inq2");
            DoTest(gp, 0, Ability.Nothing);
            DoTest(gp, 1, Ability.Nothing);
            DoTest(gp, 2, Ability.Inq);
            DoTest(gp, 3, Ability.Inq);
        }
        [TestMethod]
        public void HPConditionalShouldNotRequireConditional()
        {
            Int64GraphParameters gp = NoHitExpertise("HW[HP=2]");
            DoTest(gp, 0, Ability.Nothing);
            DoTest(gp, 1, Ability.Nothing);
            DoTest(gp, 2, Ability.HW);
            DoTest(gp, 3, Ability.Nothing);
        }
        [TestMethod]
        public void ConditionalsTests()
        {
            Int64GraphParameters gp;
            // basic tests
            gp = NoHitExpertise("HW[cdCS>0]>CS");
            DoTest(gp, 0, Ability.CS);
            DoTest(gp, GetState(gp, Ability.CS, 3), Ability.HW);
            gp = NoHitExpertise("Cons[buffInq>0]>CS");
            DoTest(gp, 0, Ability.CS);
            DoTest(gp, GetState(gp, Buff.Inq, 3), Ability.Cons);
            DoTest(gp, GetState(gp, Buff.Inq, 3, GetState(gp, Ability.Cons, 1)), Ability.CS);

            // test multiple conditionals
            gp = NoHitExpertise("HW[cdCS>0][cdCons>0]>CS>Cons");
            DoTest(gp, 0, Ability.CS);
            DoTest(gp, GetState(gp, Ability.CS, 3), Ability.Cons);
            DoTest(gp, GetState(gp, Ability.Cons, 3), Ability.CS);
            DoTest(gp, GetState(gp, Ability.Cons, 3, Ability.CS, 3), Ability.HW);

            // test operators
            gp = NoHitExpertise("CS[cdCons=1.5]>Cons");
            DoTest(gp, GetState(gp, Ability.Cons, 0), Ability.Cons);
            DoTest(gp, GetState(gp, Ability.Cons, 3), Ability.CS);
            DoTest(gp, GetState(gp, Ability.Cons, 6), Ability.Nothing);
            gp = NoHitExpertise("CS[cdCons==1.5]>Cons");
            DoTest(gp, GetState(gp, Ability.Cons, 0), Ability.Cons);
            DoTest(gp, GetState(gp, Ability.Cons, 3), Ability.CS);
            DoTest(gp, GetState(gp, Ability.Cons, 6), Ability.Nothing);
            gp = NoHitExpertise("CS[cdCons<1.5]>Cons");
            DoTest(gp, GetState(gp, Ability.Cons, 0), Ability.CS);
            DoTest(gp, GetState(gp, Ability.Cons, 3), Ability.Nothing);
            DoTest(gp, GetState(gp, Ability.Cons, 6), Ability.Nothing);
            gp = NoHitExpertise("CS[cdCons<=1.5]>Cons");
            DoTest(gp, GetState(gp, Ability.Cons, 0), Ability.CS);
            DoTest(gp, GetState(gp, Ability.Cons, 3), Ability.CS);
            DoTest(gp, GetState(gp, Ability.Cons, 6), Ability.Nothing);
            gp = NoHitExpertise("CS[cdCons>1.5]>Cons");
            DoTest(gp, GetState(gp, Ability.Cons, 0), Ability.Cons);
            DoTest(gp, GetState(gp, Ability.Cons, 3), Ability.Nothing);
            DoTest(gp, GetState(gp, Ability.Cons, 6), Ability.CS);
            gp = NoHitExpertise("CS[cdCons>=1.5]>Cons");
            DoTest(gp, GetState(gp, Ability.Cons, 0), Ability.Cons);
            DoTest(gp, GetState(gp, Ability.Cons, 3), Ability.CS);
            DoTest(gp, GetState(gp, Ability.Cons, 6), Ability.CS);
        }
    }
}
