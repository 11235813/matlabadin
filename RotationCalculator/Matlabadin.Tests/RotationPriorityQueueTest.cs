using Matlabadin;
using NUnit.Framework;
using System;

namespace Matlabadin.Tests
{
    [TestFixture]
    public class RotationPriorityQueueTest : MatlabadinTest
    {
        private void DoTest(string queue, int hp, Ability expected)
        {
            Int64GraphParameters gp = NoHitExpertise(queue);
            Assert.AreEqual(expected, gp.Rotation.ActionToTake(gp, gp, new BitVectorState() { hpcd = (ulong)hp, } ));
        }
        private void DoTest(Int64GraphParameters gp, BitVectorState state, Ability expected)
        {
            Assert.AreEqual(expected, gp.Rotation.ActionToTake(gp, gp, state));
        }
        [Test]
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
            doTest("HW");
            doTest("AW");
        }
        [Test]
        public void ActionToTake_ShouldNotCastAbilitiesOnGcdBeforeGcdComplete()
        {
            Action<string, Ability> doTest = (rotation, expected) =>
            {
                Int64GraphParameters gp = NoHitExpertise(rotation);
                DoTest(gp, gp.SetTimeRemaining(gp.SetHP(0, 3), Buff.GCD, 1), expected);
            };
            // On GCD
            doTest("CS", Ability.Nothing);
            doTest("Cons", Ability.Nothing);
            doTest("AS", Ability.Nothing);
            doTest("J", Ability.Nothing);
            
        }
        [Test]
        public void ActionToTake_ShouldCastAbilitiesOffGcdBeforeGcdComplete()
        {
            Action<string, Ability> doTest = (rotation, expected) =>
            {
                Int64GraphParameters gp = NoHitExpertise(rotation);
                DoTest(gp, gp.SetTimeRemaining(gp.SetHP(0, 3), Buff.GCD, 1), expected);
            };
            // Off GCD
            doTest("SotR", Ability.SotR);
            doTest("SS", Ability.SS);
            doTest("EF", Ability.EF);
            doTest("WoG", Ability.WoG);
            doTest("AW", Ability.AW);
        }
        [Test]
        public void DelayedCastShouldWaitForGcdCompletion()
        {
            Action<string, Ability> doTest = (rotation, expected) =>
            {
                Int64GraphParameters gp = NoHitExpertise(rotation);
                DoTest(gp, gp.SetTimeRemaining(gp.SetHP(0, 3), Buff.GCD, 2), expected);
            };
            doTest("CS", Ability.Nothing);
            doTest("CS[cdCS<=0.5]", Ability.Nothing);
            doTest("CS[cdCS<=1]", Ability.CS);
            doTest("CS[cdCS<=1.5]", Ability.CS);
        }
        [Test]
        public void SotRShouldRequire3HP()
        {
            DoTest("SotR", 0, Ability.Nothing);
            DoTest("SotR", 1, Ability.Nothing);
            DoTest("SotR", 2, Ability.Nothing);
            DoTest("SotR", 3, Ability.SotR);
        }
        [Test]
        public void SSShouldRequire3HP()
        {
            DoTest("SS", 0, Ability.Nothing);
            DoTest("SS", 1, Ability.Nothing);
            DoTest("SS", 2, Ability.Nothing);
            DoTest("SS", 3, Ability.SS);
            DoTest("SS", 4, Ability.SS);
            DoTest("SS", 5, Ability.SS);
        }
        [Test]
        public void EFShouldRequire1HP()
        {
            DoTest("EF0", 0, Ability.Nothing);
            DoTest("EF0", 1, Ability.EF);
        }
        [Test]
        public void WoGShouldRequire1HP()
        {
            DoTest("WoG0", 0, Ability.Nothing);
            DoTest("WoG0", 1, Ability.WoG);
        }
        [Test]
        public void EFShouldDefaultToEF3()
        {
            DoTest("EF", 0, Ability.Nothing);
            DoTest("EF", 1, Ability.Nothing);
            DoTest("EF", 2, Ability.Nothing);
            DoTest("EF", 3, Ability.EF);
            DoTest("EF", 4, Ability.EF);
            DoTest("EF", 5, Ability.EF);

            DoTest("EF1", 0, Ability.Nothing);
            DoTest("EF1", 1, Ability.EF);
            DoTest("EF1", 2, Ability.EF);
            DoTest("EF1", 3, Ability.EF);
            DoTest("EF1", 4, Ability.EF);
            DoTest("EF1", 5, Ability.EF);

            DoTest("EF[HP>=1]", 0, Ability.Nothing);
            DoTest("EF[HP>=1]", 1, Ability.EF);
            DoTest("EF[HP>=1]", 2, Ability.EF);
            DoTest("EF[HP>=1]", 3, Ability.EF);
            DoTest("EF[HP>=1]", 4, Ability.EF);
            DoTest("EF[HP>=1]", 5, Ability.EF);
        }
        [Test]
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
        [Test]
        public void ShouldPrioritiseHigherAbilities()
        {
            DoTest("CS>Cons", 0, Ability.CS);
            DoTest("Cons>CS", 0, Ability.Cons);
        }
        [Test]
        public void ASPlusShouldUseASIfWillGenerateHP()
        {
            Int64GraphParameters gp = NoHitExpertise("AS+>CS");
            DoTest(gp, GetState(gp, Buff.GC, 1), Ability.AS);
            DoTest(gp, 0, Ability.CS);
        }
        [Test]
        public void HPConditionalShouldNotRequireConditional()
        {
            Int64GraphParameters gp = NoHitExpertise("Cons[HP=2]");
            DoTest(gp, 0, Ability.Nothing);
            DoTest(gp, 1, Ability.Nothing);
            DoTest(gp, 2, Ability.Cons);
            DoTest(gp, 3, Ability.Nothing);
        }
        [Test]
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
        [Test]
        public void BuffStacks_ConditionalsTests()
        {
            Int64GraphParameters gp = NoHitExpertise("FoL[#SH>=2]");
            DoTest(gp, GetState(gp, 0, Buff.SH, 0), Ability.Nothing);
            DoTest(gp, GetState(gp, 1, Buff.SH, 1), Ability.Nothing);
            DoTest(gp, GetState(gp, 2, Buff.SH, 2), Ability.FoL);
        }
        [Test]
        public void KeepUpWBShouldCastHotRWhenBuffLessThan4_5Seconds()
        {
            var gp = NoHitExpertise("^WB");
            DoTest(gp, GetState(gp, Buff.WB, 10), Ability.Nothing);
            DoTest(gp, GetState(gp, Buff.WB, 9), Ability.Nothing); // 4.5s = 3 GCD * 3 steps / GCD = 9 steps
            DoTest(gp, GetState(gp, Buff.WB, 8), Ability.HotR);
            DoTest(gp, GetState(gp, Buff.WB, 1), Ability.HotR);
            DoTest(gp, GetState(gp, Buff.WB, 0), Ability.HotR);
        }
        [Test]
        public void KeepUpSSShouldCastSSWhenBuffExpired()
        {
            var gp = NoHitExpertise("^SS");
            DoTest(gp, GetState(gp, Buff.SS, 2, 3), Ability.Nothing);
            DoTest(gp, GetState(gp, Buff.SS, 1, 3), Ability.Nothing);
            DoTest(gp, GetState(gp, Buff.SS, 0, 3), Ability.SS);
        }
        [Test]
        public void KeepUpEFShouldCastEFWhenBuffExpired()
        {
            var gp = NoHitExpertise("^EF");
            DoTest(gp, GetState(gp, Buff.EF, 2, 3), Ability.Nothing);
            DoTest(gp, GetState(gp, Buff.EF, 1, 3), Ability.Nothing);
            DoTest(gp, GetState(gp, Buff.EF, 0, 3), Ability.EF);
        }
        [Test]
        public void KeepUpEFShouldUseCastEFAt3HP()
        {
            var gp = NoHitExpertise("^EF");
            DoTest(gp, GetState(gp, Buff.EF, 0, 3), Ability.EF);
            DoTest(gp, GetState(gp, Buff.EF, 0, 2), Ability.Nothing);
            DoTest(gp, GetState(gp, Buff.EF, 0, 1), Ability.Nothing);
            DoTest(gp, GetState(gp, Buff.EF, 0, 0), Ability.Nothing);
        }
        [Test]
        public void KeepUpShouldRetainConditionals()
        {
            var gp = NoHitExpertise("^EF[cdCS>0]>CS");
            DoTest(gp, GetState(gp, Buff.EF, 0, 3), Ability.CS);
            DoTest(gp, GetState(gp, Ability.CS, 1, 3), Ability.EF);
        }
        [Test]
        // ^ with numeric holy power suffix not supported at this time
        // to properly support then, we should change the regex and add capture groups
        public void KeepUpShouldRetainSuffix()
        {
            var gp = NoHitExpertise("^EF2");
            DoTest(gp, GetState(gp, Buff.EF, 0, 3), Ability.EF);
            DoTest(gp, GetState(gp, Buff.EF, 0, 2), Ability.EF);
            DoTest(gp, GetState(gp, Buff.EF, 0, 1), Ability.Nothing);
            DoTest(gp, GetState(gp, Buff.EF, 0, 0), Ability.Nothing);
        }
    }
}
