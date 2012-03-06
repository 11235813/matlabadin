using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Matlabadin.Tests
{
    [TestClass]
    public class StateTransitionTest : MatlabadinTest
    {        
        [TestMethod]
        public void UseAbilityShouldSetAbilityCDAndNotAdvanceGCD()
        {
            foreach (Ability a in new Ability[] {
                Ability.Nothing,
                Ability.SotR,
                Ability.WoG,
                Ability.EF,
                Ability.SS,
                Ability.HotR,
                Ability.CS,
                Ability.J,
                Ability.AS,
                Ability.Cons,
            })
            {
                Assert.AreEqual(Math.Max(0, GP.AbilityCooldownInSteps(a)), SM.CooldownRemaining(StateTransition<ulong>.UseAbility(GP, SM, 3, a), a));
            }
        }
        [TestMethod]
        public void UseAbility_CSShouldGiveHPOnHitOnly()
        {
            Assert.AreEqual(1, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 0, Ability.CS, hit: true)));
            Assert.AreEqual(0, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 0, Ability.CS, hit: false)));
        }
        [TestMethod]
        public void UseAbility_HotR_ShouldGiveHPOnHitOnly()
        {
            Assert.AreEqual(1, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 0, Ability.HotR, hit: true)));
            Assert.AreEqual(0, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 0, Ability.HotR, hit: false)));
        }
        [TestMethod]
        public void UseAbility_HPShouldCapAt5()
        {
            Assert.AreEqual(4, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 3, Ability.CS, hit: true)));
            Assert.AreEqual(5, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 4, Ability.CS, hit: true)));
            Assert.AreEqual(5, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 5, Ability.CS, hit: true)));
        }
        [TestMethod]
        public void UseAbility_HotRShouldGiveHPOnHitOnly()
        {
            Assert.AreEqual(1, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 0, Ability.HotR, hit: true)));
            Assert.AreEqual(0, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 0, Ability.HotR, hit: false)));
        }
        [TestMethod]
        public void UseAbility_SotRShouldConsumeHPOnHitOnly()
        {
            Assert.AreEqual(0, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 3, Ability.SotR, hit: true)));
            Assert.AreEqual(3, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 3, Ability.SotR, hit: false)));
        }
        [TestMethod]
        public void UseAbility_SotRShouldConsume3HP()
        {
            Assert.AreEqual(0, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 3, Ability.SotR, hit: true)));
            Assert.AreEqual(2, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 5, Ability.SotR, hit: true)));
        }
        [TestMethod]
        public void UseAbility_SotRShouldProcSBOnHit()
        {
            Assert.AreNotEqual(0, SM.TimeRemaining(StateTransition<ulong>.UseAbility(GP, SM, 3, Ability.SotR, hit: true), Buff.SotRSB));
            Assert.AreEqual(0, SM.TimeRemaining(StateTransition<ulong>.UseAbility(GP, SM, 3, Ability.SotR, hit: false), Buff.SotRSB));
        }
        [TestMethod]
        public void UseAbility_JShouldGiveHPOnHitOnly()
        {
            Assert.AreEqual(1, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 0, Ability.J, hit: true)));
            Assert.AreEqual(0, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 0, Ability.J, hit: false)));
        }
        [TestMethod]
        public void UseAbility_WoGShouldConsumeUpTo3HP()
        {
            Assert.AreEqual(0, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 1, Ability.WoG)));
            Assert.AreEqual(0, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 2, Ability.WoG)));
            Assert.AreEqual(0, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 3, Ability.WoG)));
            Assert.AreEqual(1, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 4, Ability.WoG)));
            Assert.AreEqual(2, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 5, Ability.WoG)));
        }
        [TestMethod]
        public void UseAbility_MaximumOf3HPShouldBeConsumed()
        {
            Assert.AreEqual(2, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 5, Ability.WoG)));
            Assert.AreEqual(2, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 5, Ability.SotR)));
            Assert.AreEqual(2, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 5, Ability.EF)));
            Assert.AreEqual(2, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 5, Ability.SS)));
        }
        [TestMethod]
        public void UseAbility_GCSProcShouldSetGCBuff()
        {
            Assert.AreNotEqual(0, SM.TimeRemaining(StateTransition<ulong>.UseAbility(GP, SM, 0, Ability.CS, hit: true, gcProc: true), Buff.GC));
        }
        [TestMethod]
        public void UseAbility_GCUseShouldConsumeGC()
        {
            Assert.AreEqual(0, SM.TimeRemaining(StateTransition<ulong>.UseAbility(GP, SM, GetState(SM, Buff.GC, 4), Ability.AS, hit: true), Buff.GC));
        }
        [TestMethod]
        public void UseAbility_ASGCShouldGiveHPOnCast() // UseAbility_ASShouldGiveHPIffGCActiveAndHit() // 4.1 patch change: AS cast on-hit
        {
            Assert.AreEqual(0, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 0, Ability.AS, hit: true)));
            Assert.AreEqual(0, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 0, Ability.AS, hit: false)));
            Assert.AreEqual(1, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, GetState(SM, Buff.GC, 1), Ability.AS, hit: true)));
            Assert.AreEqual(1, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, GetState(SM, Buff.GC, 1), Ability.AS, hit: false)));
        }
        [TestMethod]
        public void UseAbility_SSShouldSetSSBuff()
        {
            Assert.AreNotEqual(0, SM.TimeRemaining(StateTransition<ulong>.UseAbility(GP, SM, 3, Ability.SS), Buff.SS));
        }
        [TestMethod]
        public void UseAbility_SS_ShouldConsume3HP()
        {
            Assert.AreEqual(0, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 3, Ability.SS)));
            Assert.AreEqual(2, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 5, Ability.SS)));
        }
        [TestMethod]
        public void UseAbility_EFShouldSetEFBuff()
        {
            Assert.AreNotEqual(0, SM.TimeRemaining(StateTransition<ulong>.UseAbility(GP, SM, 3, Ability.EF), Buff.EF));
        }
        [TestMethod]
        public void UseAbility_EF_ShouldConsumeUpTo3HP()
        {
            Assert.AreEqual(0, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 1, Ability.EF)));
            Assert.AreEqual(0, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 2, Ability.EF)));
            Assert.AreEqual(0, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 3, Ability.EF)));
            Assert.AreEqual(1, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 4, Ability.EF)));
            Assert.AreEqual(2, SM.HP(StateTransition<ulong>.UseAbility(GP, SM, 5, Ability.EF)));
        }
        [TestMethod]
        public void UseAbility_ASMissShouldConsumeGC()
        {
            var state = StateTransition<ulong>.UseAbility(GP, SM, GetState(SM, Buff.GC, 4), Ability.AS, hit: false);
            Assert.AreEqual(0, SM.TimeRemaining(state, Buff.GC));
        }
        [TestMethod]
        public void UseAbility_ASHitShouldConsumeGC()
        {
            Assert.AreEqual(0, SM.TimeRemaining(StateTransition<ulong>.UseAbility(GP, SM, GetState(SM, Buff.GC, 4), Ability.AS, hit: true), Buff.GC));
        }
        [TestMethod]
        public void UseAbility_ShouldNotAdvanceTime()
        {
            ulong state = StateTransition<ulong>.UseAbility(GP, SM, GetState(SM, Ability.CS, 3), Ability.Nothing);
            Assert.AreEqual(3, SM.CooldownRemaining(state, Ability.CS));
        }
        [TestMethod]
        public void UseAbility_HotR_ShouldProcWB_OnHit()
        {
            Assert.AreNotEqual(0, SM.TimeRemaining(StateTransition<ulong>.UseAbility(GP, SM, 0, Ability.HotR, hit: true), Buff.WB));
            Assert.AreNotEqual(0, SM.TimeRemaining(StateTransition<ulong>.UseAbility(GP, SM, 0, Ability.HotR, hit: true, gcProc: true), Buff.WB));
            Assert.AreEqual(0, SM.TimeRemaining(StateTransition<ulong>.UseAbility(GP, SM, 0, Ability.HotR, hit: false), Buff.WB));
        }
        private void TestNextState(Int64GraphParameters gp, ulong state, Ability a,
            ulong[] expectedState,
            double[] expectedPr,
            int expectedStepsDuration = 3)
        {
            StateTransition<ulong> st = new StateTransition<ulong>(gp, gp, state, a);
            ulong[] s = st.NextStates;
            Choice c = st.Choice;
            Assert.AreEqual(s.Length, c.pr.Length);
            Assert.AreEqual(expectedStepsDuration, c.stepsDuration);
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
        public void CalculatesNextState_ShouldOnlyGenerateNonZeroTransitions()
        {
            Int64GraphParameters gp = NoMiss(R.PriorityQueue);
            TestNextState(gp, 0, Ability.J,
               1, SM.AdvanceTime(StateTransition<ulong>.UseAbility(gp, gp, 0, Ability.J, hit: true), 3)
           );
        }
        [TestMethod]
        public void CalculatesNextState_CS()
        {
            Int64GraphParameters gp = new Int64GraphParameters(R, 3, 0.8, 1);
            TestNextState(gp, 0, Ability.CS,
                0.2, SM.AdvanceTime(StateTransition<ulong>.UseAbility(gp, gp, 0, Ability.CS, hit: false), 3), // miss
                0.8 * 0.6, SM.AdvanceTime(StateTransition<ulong>.UseAbility(gp, gp, 0, Ability.CS, hit: true), 3), // hit
                0.8 * 0.4, SM.AdvanceTime(StateTransition<ulong>.UseAbility(gp, gp, 0, Ability.CS, hit: true, gcProc: true), 3) // GrCr proc
            );
            gp = NoMiss(R.PriorityQueue);
            TestNextState(gp, 0, Ability.CS,
               0.6, SM.AdvanceTime(StateTransition<ulong>.UseAbility(gp, gp, 0, Ability.CS, hit: true), 3),
               0.4, SM.AdvanceTime(StateTransition<ulong>.UseAbility(gp, gp, 0, Ability.CS, hit: true, gcProc: true), 3)
           );
        }
        [TestMethod]
        public void CalculatesNextState_AS()
        {
            Int64GraphParameters gp = new Int64GraphParameters(R, 3, 0.1, 0.8);
            ulong state = GetState(SM, Buff.GC, 1); // with GC
            TestNextState(gp, state, Ability.AS,
                0.2, SM.AdvanceTime(StateTransition<ulong>.UseAbility(gp, gp, state, Ability.AS, hit: false), 3),
                0.8, SM.AdvanceTime(StateTransition<ulong>.UseAbility(gp, gp, state, Ability.AS, hit: true), 3) // hit
            );
            state = 0; // without GC buff
            TestNextState(gp, state, Ability.AS,
                0.2, SM.AdvanceTime(StateTransition<ulong>.UseAbility(gp, gp, state, Ability.AS, hit: false), 3),
                0.8, SM.AdvanceTime(StateTransition<ulong>.UseAbility(gp, gp, state, Ability.AS, hit: true), 3) // hit
            );
            gp = NoMiss(R.PriorityQueue);
            TestNextState(gp, state, Ability.AS,
                1, SM.AdvanceTime(StateTransition<ulong>.UseAbility(gp, gp, state, Ability.AS, hit: true), 3) // hit
            );
        }
        [TestMethod]
        public void CalculatesNextState_AS_J_ShouldUseRangedHit()
        {
            Int64GraphParameters gp = new Int64GraphParameters(R, 3, 0, 0.6);
            TestNextState(gp, 0, Ability.AS,
                0.4, SM.AdvanceTime(StateTransition<ulong>.UseAbility(gp, gp, 0, Ability.AS, hit: false), 3),
                0.6, SM.AdvanceTime(StateTransition<ulong>.UseAbility(gp, gp, 0, Ability.AS, hit: true), 3) // hit
            );
            TestNextState(gp, 0, Ability.J,
                0.4, SM.AdvanceTime(StateTransition<ulong>.UseAbility(gp, gp, 0, Ability.J, hit: false), 3),
                0.6, SM.AdvanceTime(StateTransition<ulong>.UseAbility(gp, gp, 0, Ability.J, hit: true), 3) // hit
            );
        }
        [TestMethod]
        public void CalculatesNextState_SotRCanMiss()
        {
            Int64GraphParameters gp = new Int64GraphParameters(R, 3, 0.8, 0);
            ulong state = 3UL;
            TestNextState(gp, state, Ability.SotR,
                0.2, StateTransition<ulong>.UseAbility(gp, gp, state, Ability.SotR, hit: false),
                0.8, StateTransition<ulong>.UseAbility(gp, gp, state, Ability.SotR, hit: true),
                0
            );
            gp = NoMiss(R.PriorityQueue);
            TestNextState(gp, state, Ability.SotR,
               1, StateTransition<ulong>.UseAbility(gp, gp, state, Ability.SotR, hit: true),
               0
           );
        }
        [TestMethod]
        public void CalculatesNextState_HotR_ShouldProcWBGC()
        {
            Int64GraphParameters gp = new Int64GraphParameters(R, 3, 0.8, 0);
            ulong state = GetState(SM, Ability.HotR, 1, 3);
            TestNextState(gp, state, Ability.HotR,
                0.2, GetState(SM, Ability.HotR, 9 - 3, 3),
                0.8 * 0.6, GetState(SM, Ability.HotR, 9 - 3, GetState(SM, Buff.WB, 60 - 3, 4)),
                0.8 * 0.4, GetState(SM, Ability.HotR, 9 - 3, GetState(SM, Buff.WB, 60 - 3, Buff.GC, 13 - 3, 4)),
                4 // 4 steps
            );
        }
        [TestMethod]
        public void CalculatesNextState_SingleTransitionAbilities()
        {
            foreach (Ability a in new Ability[] { Ability.Cons, Ability.Nothing, Ability.WoG, Ability.SS, Ability.EF })
            {
                var st = new StateTransition<ulong>(GP, SM, 3, a);
                Assert.AreEqual(1, st.NextStates.Length);
                Assert.AreEqual(1, st.Choice.pr.Length);
                Assert.AreEqual(1d, st.Choice.pr[0]);
            }
        }
        [TestMethod]
        public void CalculateStateTransition_SotR_WoG_ShouldAdvanceTimeBy0Steps()
        {
            var st = new StateTransition<ulong>(GP, SM, GetState(SM, Ability.CS, 3, 3), Ability.SotR);
            Assert.AreEqual(0, st.Choice.stepsDuration);
            Assert.IsTrue(st.StatePostAbility.SequenceEqual(st.NextStates));
            
            st = new StateTransition<ulong>(GP, SM, GetState(SM, Ability.CS, 3, 3), Ability.WoG);
            Assert.AreEqual(0, st.Choice.stepsDuration);
            Assert.IsTrue(st.StatePostAbility.SequenceEqual(st.NextStates));
        }
        [TestMethod]
        public void CalculateStateTransition_Nothing_ShouldAdvanceTimeBy1Step()
        {
            TestNextState(GP, GetState(SM, Ability.CS, 3), Ability.Nothing,
                1, GetState(SM, Ability.CS, 2), 
                1 // 1 step duration
            );
        }
        [TestMethod]
        public void CalculatesStatePostAbility_ShouledAdvanceTimeByGCD()
        {
            var st = new StateTransition<ulong>(GP, SM, 0, Ability.CS);
            Assert.AreEqual(GP.StepsPerGcd, st.Choice.stepsDuration);
            Assert.IsFalse(st.StatePostAbility.SequenceEqual(st.NextStates));
        }
        [TestMethod]
        public void CalculateStateTransition_ShouldWaitForAbilityCDBeforeCasting()
        {
            var st = new StateTransition<ulong>(GP, SM, GetState(SM, Ability.CS, 1, 3), Ability.CS);
            Assert.AreEqual(3UL, st.StatePreAbility);
        }
        [TestMethod]
        public void CalculateStateTransition_ShouldSetAllStateProperties()
        {
            var st = new StateTransition<ulong>(GP, SM, GetState(SM, Ability.Cons, 1), Ability.Cons);
            Assert.AreEqual(GetState(SM, Ability.Cons, 1), st.StateInitial);
            Assert.AreEqual(0UL, st.StatePreAbility);
            Assert.IsTrue(st.StatePostAbility.SequenceEqual(new ulong[] { GetState(SM, Ability.Cons, 18) } ));
            Assert.IsTrue(st.NextStates.SequenceEqual(new ulong[] { GetState(SM, Ability.Cons, 15) } ));
        }
        [TestMethod]
        public void CalculateTransition_ShouldUseRotationAbility()
        {
            var r = new RotationPriorityQueue<ulong>("Cons");
            var gp = new Int64GraphParameters(r, 3, 1, 1);
            Assert.AreEqual(r.ActionToTake(gp, gp, 0), StateTransition<ulong>.CalculateTransition(gp, gp, 0).Choice.Ability);
        }
        [TestMethod]
        public void CalculateTransition_ShouldConcatenateConsecutiveNothingStates()
        {
            var r = new RotationPriorityQueue<ulong>("J");
            var gp = new Int64GraphParameters(r, 3, 1, 1);
            Choice c = StateTransition<ulong>.CalculateTransition(gp, gp, GetState(gp, Ability.J, 4)).Choice;
            Assert.AreEqual(Ability.Nothing, c.Ability);
            Assert.AreEqual(4, c.stepsDuration);
        }
        [TestMethod]
        public void CalculateTransition_ShouldNotConcatenateLoop()
        {
            var r = new RotationPriorityQueue<ulong>("");
            var gp = new Int64GraphParameters(r, 3, 1, 1);
            var st = StateTransition<ulong>.CalculateTransition(gp, gp, GetState(gp, Buff.GC, 4));
            Assert.AreEqual(Ability.Nothing, st.Choice.Ability);
            // Should stop when we get to the zero state the first time
            Assert.AreEqual(4, st.Choice.stepsDuration);
            Assert.AreEqual(0UL, st.NextStates[0]);
        }
        [TestMethod]
        public void Choice_ShouldSetBuffUptimeBasedOnInitialStateAndPostAbilityDurations()
        {
            // 1 step left on WB
            // 2 step wait time
            // 3 step GCD
            // = 1 step uptime for miss, 4 step uptime for hit
            var st = new StateTransition<ulong>(GP, SM, GetState(SM, Ability.HotR, 2, GetState(SM, Buff.WB, 1, 3)), Ability.HotR);
            Assert.AreEqual(GetState(SM, Ability.HotR, 2, GetState(SM, Buff.WB, 1, 3)), st.StateInitial);
            Assert.AreEqual(3UL, st.StatePreAbility);
            Assert.AreEqual(5, st.Choice.stepsDuration); // 2 wait steps, 3s cast
            Assert.AreEqual(1, st.Choice.buffDuration[(int)Buff.WB][0]); // miss
            Assert.AreEqual(4, st.Choice.buffDuration[(int)Buff.WB][1]); // hit
            Assert.AreEqual(4, st.Choice.buffDuration[(int)Buff.WB][2]); // hit & gc
        }
        [TestMethod]
        public void Choice_StepsDurationShouldIncludeWaitTime()
        {
            var st = new StateTransition<ulong>(GP, SM, GetState(SM, Ability.CS, 1, 3), Ability.CS);
            Assert.AreEqual(4, st.Choice.stepsDuration);
        }
        [TestMethod]
        public void Choice_wogss_ShouldBeSetOnlyForWog()
        {
            Assert.IsTrue(new StateTransition<ulong>(GP, SM, GetState(SM, Buff.SS, 1, 1), Ability.WoG).Choice.Action.Contains("(SS)"));
            Assert.IsFalse(new StateTransition<ulong>(GP, SM, GetState(SM, Buff.SS, 0, 1), Ability.WoG).Choice.Action.Contains("(SS)"));
            Assert.IsFalse(new StateTransition<ulong>(GP, SM, GetState(SM, Buff.SS, 1, 1), Ability.CS).Choice.Action.Contains("(SS)"));
        }
        [TestMethod]
        public void Choice_BuffDurationShouldNotExceedStepDuration()
        {
            Assert.AreEqual(3, new StateTransition<ulong>(GP, SM, GetState(SM, Buff.SS, 5), Ability.Cons).Choice.buffDuration[(int)Buff.SS][0]);
            Assert.AreEqual(1, new StateTransition<ulong>(GP, SM, GetState(SM, Buff.SS, 1), Ability.Cons).Choice.buffDuration[(int)Buff.SS][0]);
        }
        [TestMethod]
        public void Choice_BuffDurationShouldBeSetIffTracked()
        {
            Assert.AreEqual(1, new StateTransition<ulong>(GP, SM, GetState(SM, Buff.SS, 1), Ability.Nothing).Choice.buffDuration[(int)Buff.SS][0]);
            Assert.AreEqual(1, new StateTransition<ulong>(GP, SM, GetState(SM, Buff.EF, 1), Ability.Nothing).Choice.buffDuration[(int)Buff.EF][0]);
            Assert.AreEqual(1, new StateTransition<ulong>(GP, SM, GetState(SM, Buff.WB, 1), Ability.Nothing).Choice.buffDuration[(int)Buff.WB][0]);
            Assert.AreEqual(1, new StateTransition<ulong>(GP, SM, GetState(SM, Buff.SotRSB, 1), Ability.Nothing).Choice.buffDuration[(int)Buff.SotRSB][0]);
        }
        [TestMethod]
        public void Choice_HotR_ShouldSetWBOnlyForHitTransitions()
        {
            Assert.AreEqual(0, new StateTransition<ulong>(GP, SM, 0, Ability.HotR).Choice.buffDuration[(int)Buff.WB][0]); // miss
            Assert.AreEqual(3, new StateTransition<ulong>(GP, SM, 0, Ability.HotR).Choice.buffDuration[(int)Buff.WB][1]); // hit
            Assert.AreEqual(3, new StateTransition<ulong>(GP, SM, 0, Ability.HotR).Choice.buffDuration[(int)Buff.WB][2]); // hit & gc proc
        }
    }
}
