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
            doTest("Cons");
            doTest("AS");
            doTest("J");
            doTest("SotR");
            doTest("SS");
            doTest("EF");
            doTest("WoG");
        }
        [TestMethod]
        public void SotRShouldRequire3HP()
        {
            DoTest("SotR", 0, Ability.Nothing);
            DoTest("SotR", 1, Ability.Nothing);
            DoTest("SotR", 2, Ability.Nothing);
            DoTest("SotR", 3, Ability.SotR);
        }
        [TestMethod]
        public void NumericSuffixShouldIndicateMinHolyPowerToUseAbility()
        {
            DoTest("J0", 0, Ability.J);
            DoTest("J0", 1, Ability.J);
            DoTest("J5", 0, Ability.Nothing);
            DoTest("J5", 1, Ability.Nothing);
            DoTest("J5", 2, Ability.Nothing);
            DoTest("J5", 3, Ability.Nothing);
            DoTest("J5", 4, Ability.Nothing);
            DoTest("J5", 5, Ability.J);
        }
        [TestMethod]
        public void ShouldPrioritiseHigherAbilities()
        {
            DoTest("CS>Cons", 0, Ability.CS);
            DoTest("Cons>CS", 0, Ability.Cons);
        }
        [TestMethod]
        public void ASPlusShouldUseASIfWillGenerateHP()
        {
            Int64GraphParameters gp = NoHitExpertise("AS+>CS");
            DoTest(gp, GetState(gp, Buff.GC, 1), Ability.AS);
            DoTest(gp, 0, Ability.CS);
        }
        [TestMethod]
        public void HPConditionalShouldNotRequireConditional()
        {
            Int64GraphParameters gp = NoHitExpertise("Cons[HP=2]");
            DoTest(gp, 0, Ability.Nothing);
            DoTest(gp, 1, Ability.Nothing);
            DoTest(gp, 2, Ability.Cons);
            DoTest(gp, 3, Ability.Nothing);
        }
        [TestMethod]
        public void ConditionalsTests()
        {
            Int64GraphParameters gp;
            // basic tests
            gp = NoHitExpertise("Cons[cdCS>0]>CS");
            DoTest(gp, 0, Ability.CS);
            DoTest(gp, GetState(gp, Ability.CS, 3), Ability.Cons);
            gp = NoHitExpertise("AS[buffGC>0]>CS");
            DoTest(gp, 0, Ability.CS);
            DoTest(gp, GetState(gp, Buff.GC, 3), Ability.AS);
            DoTest(gp, GetState(gp, Buff.GC, 3, GetState(gp, Ability.AS, 1)), Ability.CS);

            // test multiple conditionals
            gp = NoHitExpertise("J[cdCS>0][cdCons>0]>CS>Cons");
            DoTest(gp, 0, Ability.CS);
            DoTest(gp, GetState(gp, Ability.CS, 3), Ability.Cons);
            DoTest(gp, GetState(gp, Ability.Cons, 3), Ability.CS);
            DoTest(gp, GetState(gp, Ability.Cons, 3, Ability.CS, 3), Ability.J);

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
