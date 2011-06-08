using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Matlabadin.Tests
{
    [TestClass]
    public class StateHelperTest : MatlabadinTest
    {        
        [TestMethod]
        public void UseAbilityShouldSetAbilityCDAndAdvanceOneGCD()
        {
            foreach (Ability a in new Ability[] {
                Ability.Nothing,
                Ability.Inq,
                Ability.SotR,
                Ability.HotR,
                Ability.WoG,
                Ability.CS,
                Ability.J,
                Ability.AS,
                Ability.Cons,
                Ability.HW,
                Ability.HoW,
            })
            {
                Assert.AreEqual(Math.Max(0, GP.AbilityCooldownInSteps(a) - 3), SM.CooldownRemaining(StateHelper<ulong>.UseAbility(GP, SM, 0, a), a));
            }
        }
        [TestMethod]
        public void UseAbility_CSShouldGiveHPOnHitOnly()
        {
            Assert.AreEqual(1, SM.HP(StateHelper<ulong>.UseAbility(GP, SM, 0, Ability.CS, hit: true)));
            Assert.AreEqual(0, SM.HP(StateHelper<ulong>.UseAbility(GP, SM, 0, Ability.CS, hit: false)));
        }
        [TestMethod]
        public void UseAbility_HPShouldCapAt3()
        {
            Assert.AreEqual(3, SM.HP(StateHelper<ulong>.UseAbility(GP, SM,3, Ability.CS, hit: true)));
            Assert.AreEqual(3, SM.HP(StateHelper<ulong>.UseAbility(GP, SM, GetState(SM, Buff.GC, 1, 3), Ability.AS, hit: true)));
        }
        [TestMethod]
        public void UseAbility_HotRShouldGiveHPOnHitOnly()
        {
            Assert.AreEqual(1, SM.HP(StateHelper<ulong>.UseAbility(GP, SM, 0, Ability.HotR, hit: true)));
            Assert.AreEqual(0, SM.HP(StateHelper<ulong>.UseAbility(GP, SM, 0, Ability.HotR, hit: false)));
        }
        [TestMethod]
        public void UseAbility_SotRShouldConsumeHPOnHitOnly()
        {
            Assert.AreEqual(0, SM.HP(StateHelper<ulong>.UseAbility(GP, SM, 2, Ability.SotR, hit: true)));
            Assert.AreEqual(2, SM.HP(StateHelper<ulong>.UseAbility(GP, SM, 2, Ability.SotR, hit: false)));
        }
        [TestMethod]
        public void UseAbility_WoGShouldConsumeHP()
        {
            Assert.AreEqual(0, SM.HP(StateHelper<ulong>.UseAbility(GP, SM, 2, Ability.WoG)));
        }
        [TestMethod]
        public void UseAbility_WoGEGShouldNotConsumeHP()
        {
            Assert.AreEqual(3, SM.HP(StateHelper<ulong>.UseAbility(GP, SM, 3, Ability.WoG, egProc: true)));
        }
        [TestMethod]
        public void UseAbility_WoGEGShouldSetICD()
        {
            Assert.AreNotEqual(0, SM.TimeRemaining(StateHelper<ulong>.UseAbility(GP, SM, 3, Ability.WoG, egProc: true), Buff.EGICD));
        }
        [TestMethod]
        public void UseAbility_JShouldSetJotw()
        {
            Assert.AreNotEqual(0, SM.TimeRemaining(StateHelper<ulong>.UseAbility(GP, SM, 0, Ability.J), Buff.JotW));
        }
        [TestMethod]
        public void UseAbility_InqShouldConsumeHP()
        {
            Assert.AreEqual(0, SM.HP(StateHelper<ulong>.UseAbility(GP, SM, 2, Ability.Inq)));
        }
        [TestMethod]
        public void UseAbility_InqDurationShouldBeDeterminedByHP()
        {
            Assert.AreEqual(12 * 2 - 3, SM.TimeRemaining(StateHelper<ulong>.UseAbility(GP, SM, 3, Ability.Inq), Buff.Inq));
            Assert.AreEqual(8 * 2 - 3, SM.TimeRemaining(StateHelper<ulong>.UseAbility(GP, SM, 2, Ability.Inq), Buff.Inq));
            Assert.AreEqual(4 * 2 - 3, SM.TimeRemaining(StateHelper<ulong>.UseAbility(GP, SM, 1, Ability.Inq), Buff.Inq));
        }
        [TestMethod]
        public void UseAbility_SDBuffShouldBeSetForSDProc()
        {
            Assert.AreNotEqual(0, SM.TimeRemaining(StateHelper<ulong>.UseAbility(GP, SM, 0, Ability.J, hit:true, sdProc: true), Buff.SD));
            Assert.AreNotEqual(0, SM.TimeRemaining(StateHelper<ulong>.UseAbility(GP, SM, 0, Ability.AS, hit: true, sdProc: true), Buff.SD));
        }
        [TestMethod]
        public void UseAbility_SDShouldResetSDDuration()
        {
            Assert.AreNotEqual(1, SM.TimeRemaining(StateHelper<ulong>.UseAbility(GP, SM, GetState(SM, Buff.SD, 4), Ability.J, hit: true, sdProc: true), Buff.SD));
            Assert.AreNotEqual(1, SM.TimeRemaining(StateHelper<ulong>.UseAbility(GP, SM, GetState(SM, Buff.SD, 4), Ability.AS, hit: true, sdProc: true), Buff.SD));
        }
        [TestMethod]
        public void UseAbility_GCSProcShouldSetGCBuff()
        {
            Assert.AreNotEqual(0, SM.TimeRemaining(StateHelper<ulong>.UseAbility(GP, SM, 0, Ability.CS, hit: true, gcProc: true), Buff.GC));
        }
        [TestMethod]
        public void UseAbility_GCUseShouldConsumeGC()
        {
            Assert.AreEqual(0, SM.TimeRemaining(StateHelper<ulong>.UseAbility(GP, SM, GetState(SM, Buff.GC, 4), Ability.AS, hit: true), Buff.GC));
        }
        [TestMethod]
        public void UseAbility_ASShouldGiveHP() // UseAbility_ASShouldGiveHPIffGCActiveAndHit() // 4.1 patch change: AS cast on-hit
        {
            Assert.AreEqual(0, SM.HP(StateHelper<ulong>.UseAbility(GP, SM, 0, Ability.AS, hit: true)));
            Assert.AreEqual(0, SM.HP(StateHelper<ulong>.UseAbility(GP, SM, 0, Ability.AS, hit: false)));
            Assert.AreEqual(1, SM.HP(StateHelper<ulong>.UseAbility(GP, SM, GetState(SM, Buff.GC, 1), Ability.AS, hit: true)));
            Assert.AreEqual(1, SM.HP(StateHelper<ulong>.UseAbility(GP, SM, GetState(SM, Buff.GC, 1), Ability.AS, hit: false)));
        }
        [TestMethod]
        public void UseAbility_ASMissShouldConsumeGC()
        {
            var state = StateHelper<ulong>.UseAbility(GP, SM, GetState(SM, Buff.GC, 4), Ability.AS, hit: false);
            Assert.AreEqual(0, SM.TimeRemaining(state, Buff.GC));
        }
        [TestMethod]
        public void UseAbility_ASHitShouldConsumeGC()
        {
            Assert.AreEqual(0, SM.TimeRemaining(StateHelper<ulong>.UseAbility(GP, SM, GetState(SM, Buff.GC, 4), Ability.AS, hit: true), Buff.GC));
        }
        private void TestNextState(Int64GraphParameters gp, ulong state, Ability a,
            ulong[] expectedState,
            double[] expectedPr,
            int expectedStepsDuration = 3)
        {
            ulong[] s;
            Choice<ulong> c = StateHelper<ulong>.NextStates(gp, gp, state, a, out s);
            Assert.AreEqual(s.Length, c.pr.Length);
            Assert.IsTrue(expectedState.SequenceEqual(s));
            for (int i = 0; i < expectedPr.Length; i++)
            {
                Assert.AreEqual(expectedPr[i], c.pr[i], 1e-15);
            }
            Assert.AreEqual(1, c.pr.Sum(), 1e-15);

        }
        private void TestNextState(Int64GraphParameters gp, ulong state, Ability a,
            double expectedPr1, ulong expectedState1,
            int expectedStepsDuration = 3)
        {
            TestNextState(gp, state, a, new ulong[] { expectedState1 }, new double[] { expectedPr1 }, expectedStepsDuration);
        }
        private void TestNextState(Int64GraphParameters gp, ulong state, Ability a,
            double expectedPr1, ulong expectedState1,
            double expectedPr2, ulong expectedState2,            
            int expectedStepsDuration = 3)
        {
            TestNextState(gp, state, a, new ulong[] { expectedState1, expectedState2 }, new double[] { expectedPr1, expectedPr2 }, expectedStepsDuration);
        }
        private void TestNextState(Int64GraphParameters gp, ulong state, Ability a,
            double expectedPr1, ulong expectedState1,
            double expectedPr2, ulong expectedState2,
            double expectedPr3, ulong expectedState3,
            int expectedStepsDuration = 3)
        {
            TestNextState(gp, state, a, new ulong[] { expectedState1, expectedState2, expectedState3 }, new double[] { expectedPr1, expectedPr2, expectedPr3 }, expectedStepsDuration);
        }
        [TestMethod]
        public void NextState_ShouldOnlyGenerateNonZeroTransitions()
        {
            Int64GraphParameters gp = NoMissNoProcs(R.PriorityQueue);
            TestNextState(gp, 0, Ability.CS,
               1, StateHelper<ulong>.UseAbility(gp, gp, 0, Ability.CS, hit: true)
           );
        }
        [TestMethod]
        public void NextState_CS()
        {
            Int64GraphParameters gp = new Int64GraphParameters(R, 3, false, 0.8, 1, 0, 0.20, 0);
            TestNextState(gp, 0, Ability.CS,
                0.2, StateHelper<ulong>.UseAbility(gp, gp, 0, Ability.CS, hit: false), // miss
                0.8 * (1 - 0.2), StateHelper<ulong>.UseAbility(gp, gp, 0, Ability.CS, hit: true), // hit
                0.8 * 0.2, StateHelper<ulong>.UseAbility(gp, gp, 0, Ability.CS, hit: true, gcProc: true) // GrCr proc
            );
            gp = NoMissNoProcs(R.PriorityQueue);
            TestNextState(gp, 0, Ability.CS,
               1, StateHelper<ulong>.UseAbility(gp, gp, 0, Ability.CS, hit: true)
           );
        }
        [TestMethod]
        public void NextState_AS()
        {
            Int64GraphParameters gp = new Int64GraphParameters(R, 3, false, 1, 0.8, 0.5, 0, 0);
            ulong state = GetState(SM, Buff.GC, 1); // with GC
            TestNextState(gp, state, Ability.AS,
                0.2, StateHelper<ulong>.UseAbility(gp, gp, state, Ability.AS, hit: false),
                0.8 * (1 - 0.5), StateHelper<ulong>.UseAbility(gp, gp, state, Ability.AS, hit: true), // hit
                0.8 * 0.5, StateHelper<ulong>.UseAbility(gp, gp, state, Ability.AS, hit: true, sdProc: true) // proc
            );
            state = 0; // without GC buff
            TestNextState(gp, state, Ability.AS,
                0.2, StateHelper<ulong>.UseAbility(gp, gp, state, Ability.AS, hit: false),
                0.8 * (1 - 0.5), StateHelper<ulong>.UseAbility(gp, gp, state, Ability.AS, hit: true), // hit
                0.8 * 0.5, StateHelper<ulong>.UseAbility(gp, gp, state, Ability.AS, hit: true, sdProc: true) // proc
            );
            gp = NoMissNoProcs(R.PriorityQueue);
            TestNextState(gp, state, Ability.AS,
                1, StateHelper<ulong>.UseAbility(gp, gp, state, Ability.AS, hit: true) // hit
            );
        }
        [TestMethod]
        public void NextState_SotRCanMiss()
        {
            Int64GraphParameters gp = new Int64GraphParameters(R, 3, false, 0.8, 0, 1, 1, 1);
            ulong state = 3;
            TestNextState(gp, state, Ability.SotR,
                0.2, StateHelper<ulong>.UseAbility(gp, gp, state, Ability.SotR, hit: false),
                0.8, StateHelper<ulong>.UseAbility(gp, gp, state, Ability.SotR, hit: true)
            );
            gp = NoMissNoProcs(R.PriorityQueue);
            TestNextState(gp, state, Ability.SotR,
               1, StateHelper<ulong>.UseAbility(gp, gp, state, Ability.SotR, hit: true)
           );
        }
        [TestMethod]
        public void NextState_SingleTransitionAbilities()
        {
            Int64GraphParameters gp = NoHitExpertise(R.PriorityQueue);
            ulong state = 2;
            foreach (Ability a in new Ability[] { Ability.Cons, Ability.HoW, Ability.HW, Ability.Nothing, Ability.Inq })
            {
                TestNextState(gp, state, a,
                    1, StateHelper<ulong>.UseAbility(gp, gp, state, a)
                );
            }
        }
        [TestMethod]
        public void NextState_WoGCanProcEG()
        {
            Int64GraphParameters gp = new Int64GraphParameters(R, 3, false, 0.5, 0.5, 1, 1, 0.3);
            ulong state = 3;
            Ability a = Ability.WoG;
            TestNextState(gp, state, a,
                0.7, StateHelper<ulong>.UseAbility(gp, gp, state, a),
                0.3, StateHelper<ulong>.UseAbility(gp, gp, state, a, egProc: true)
            );
            gp = NoMissNoProcs(R.PriorityQueue);
            TestNextState(gp, state, a,
                1, StateHelper<ulong>.UseAbility(gp, gp, state, a)
            );
        }
    }
}
