using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Matlabadin.Tests
{
    [TestClass]
    public class NextStateTest : MatlabadinTest
    {
        private void TestNextState(GraphParameters gp, ulong state, Ability a,
            double expectedPr1 = 0,
            ulong expectedState1 = UInt64.MaxValue,
            double expectedPr2 = 0,
            ulong expectedState2 = UInt64.MaxValue,
            double expectedPr3 = 0,
            ulong expectedState3 = UInt64.MaxValue,
            int expectedStepsDuration = 3)
        {
            MatlabadinGraph mg = new MatlabadinGraph(gp, RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction("CS"));
            ulong s1, s2, s3;
            Choice c = MatlabadinGraph.NextStates(state, a, gp, out s1, out s2, out s3);
            Assert.IsTrue(expectedPr1 == 0 && expectedState1 == UInt64.MaxValue || expectedPr1 != 0 && expectedState1 != UInt64.MaxValue);
            Assert.IsTrue(expectedPr2 == 0 && expectedState2 == UInt64.MaxValue || expectedPr2 != 0 && expectedState2 != UInt64.MaxValue);
            Assert.IsTrue(expectedPr3 == 0 && expectedState3 == UInt64.MaxValue || expectedPr3 != 0 && expectedState3 != UInt64.MaxValue);
            Assert.IsTrue(expectedState1 == s1);
            Assert.IsTrue(expectedState2 == s2);
            Assert.IsTrue(expectedState3 == s3);
            Assert.AreEqual(expectedPr1, c.option1, 1e-15);
            Assert.AreEqual(expectedPr2, c.option2, 1e-15);
            Assert.AreEqual(expectedPr3, c.option3, 1e-15);
            Assert.AreEqual(expectedStepsDuration, c.stepsDuration);
            Assert.AreEqual(1, expectedPr1 + expectedPr2 + expectedPr3);

        }
        [TestMethod]
        public void NextState_InvalidTransitionsShouldBeSetToSentinalState()
        {
            TestNextState(DefaultParameters, 0, Ability.Cons,
                1, StateHelper.UseAbility(0, DefaultParameters, Ability.Cons),
                0, UInt64.MaxValue,
                0, UInt64.MaxValue);

        }
        [TestMethod]
        public void NextState_CS()
        {
            GraphParameters gp = new GraphParameters(3, false, 0.8, 1, 0, 0.20, 0);
            TestNextState(gp, 0, Ability.CS,
                0.2, StateHelper.UseAbility(0, gp, Ability.CS, hit: false), // miss
                0.8 * (1 - 0.2), StateHelper.UseAbility(0, gp, Ability.CS, hit: true), // hit
                0.8 * 0.2, StateHelper.UseAbility(0, gp, Ability.CS, hit: true, gcProc: true) // GrCr proc
            );
            gp = NoMissNoProcsParameters;
            TestNextState(gp, 0, Ability.CS,
               0, UInt64.MaxValue,
               1, StateHelper.UseAbility(0, gp, Ability.CS, hit: true),
               0, UInt64.MaxValue
           );
        }
        [TestMethod]
        public void NextState_AS()
        {
            GraphParameters gp = new GraphParameters(3, false, 1, 0.8, 0.5, 0, 0);
            ulong state = GetState(Buff.GC, 1); // with GC
            TestNextState(gp, state, Ability.AS,
                0.2, StateHelper.UseAbility(state, gp, Ability.AS, hit: false),
                0.8 * (1 - 0.5), StateHelper.UseAbility(state, gp, Ability.AS, hit: true), // hit
                0.8 * 0.5, StateHelper.UseAbility(state, gp, Ability.AS, hit: true, sdProc: true) // proc
            );
            state = 0; // without GC buff
            TestNextState(gp, state, Ability.AS,
                0.2, StateHelper.UseAbility(state, gp, Ability.AS, hit: false),
                0.8 * (1 - 0.5), StateHelper.UseAbility(state, gp, Ability.AS, hit: true), // hit
                0.8 * 0.5, StateHelper.UseAbility(state, gp, Ability.AS, hit: true, sdProc: true) // proc
            );
            gp = NoMissNoProcsParameters;
            TestNextState(gp, state, Ability.AS,
                0, UInt64.MaxValue,
                1, StateHelper.UseAbility(state, gp, Ability.AS, hit: true), // hit
                0, UInt64.MaxValue
            );
        }
        [TestMethod]
        public void NextState_SotRCanMiss()
        {
            GraphParameters gp = new GraphParameters(3, false, 0.8, 0, 1, 1, 1);
            ulong state = 3;
            TestNextState(gp, state, Ability.SotR,
                0.2, StateHelper.UseAbility(state, gp, Ability.SotR, hit: false),
                0.8, StateHelper.UseAbility(state, gp, Ability.SotR, hit: true)
            );
            gp = NoMissNoProcsParameters;
            TestNextState(gp, state, Ability.SotR,
               0, UInt64.MaxValue,
               1, StateHelper.UseAbility(state, gp, Ability.SotR, hit: true)
           );
        }
        [TestMethod]
        public void NextState_SingleTransitionAbilities()
        {
            GraphParameters gp = DefaultParameters;
            ulong state = 2;
            foreach (Ability a in new Ability[] { Ability.Cons, Ability.HoW, Ability.HW, Ability.Nothing, Ability.Inq })
            {
                TestNextState(gp, state, a,
                    1, StateHelper.UseAbility(state, gp, a)
                );
            }
        }
        [TestMethod]
        public void NextState_WoGCanProcEG()
        {
            GraphParameters gp = new GraphParameters(3, false, 0, 0, 1, 1, 0.3);
            ulong state = 3;
            Ability a = Ability.WoG;
            TestNextState(gp, state, a,
                0.7, StateHelper.UseAbility(state, gp, a),
                0.3, StateHelper.UseAbility(state, gp, a, egProc: true)
            );
            gp = NoMissNoProcsParameters;
            TestNextState(gp, state, a,
                1, StateHelper.UseAbility(state, gp, a),
                0, UInt64.MaxValue
            );
        }
    }
}
