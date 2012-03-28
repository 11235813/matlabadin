using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;

namespace Matlabadin.Tests
{
    [TestFixture]
    public class MatlabadinGraphTest : MatlabadinTest
    {
        private int iterationsTaken;
        private double finalAbsError, finalRelError;
        public const double Tolerance = 1e-14;
        public void SanityCheckGraph(MatlabadinGraph<ulong> mg)
        {
            Assert.AreEqual(mg.Size, mg.index.Count());
            Assert.AreEqual(mg.Size, mg.lookup.Count());
            Assert.AreEqual(mg.Size, mg.nextState.Count());
            Assert.AreEqual(mg.Size, mg.choice.Count());
            for (int i = 0; i < mg.index.Count(); i++)
            {
                Assert.AreNotEqual(0, mg.nextState[i].Length); // exists transition out of state
                Assert.AreEqual(mg.nextState[i].Length, mg.choice[i].pr.Length); // transitions count matches transitions probability count
                Assert.AreEqual(1.0, mg.choice[i].pr.Sum(), 1e-10); // transitions out of state sum to 1
                Assert.IsFalse(mg.choice[i].pr.Any(p => p == 0)); // should not be any 0 probability transitions
                for (int j = 0; j < mg.nextState[i].Length; j++)
                {
                    // transitions are to valid states
                    Assert.IsTrue(mg.nextState[i][j] >= 0);
                    Assert.IsTrue(mg.nextState[i][j] < mg.Size);
                }
            }
        }
        [Test]
        public void GenerateGraph_ShouldOnlyGenerateNonZeroTransitions()
        {
            Int64GraphParameters gp = NoMiss("J");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            SanityCheckGraph(mg);
            Assert.IsFalse(mg.nextState.Any(ns => ns.Any(s => s == 0))); // starting state (0) should be unreachable for a J rotation with no miss
        }
        [Test]
        public void GenerateGraph_NextStateTransitionsShouldAlwaysBeSet()
        {
            Int64GraphParameters gp = NoMiss("J");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            SanityCheckGraph(mg);
            // 0 HP -> J @ 5 HP cycle
            // J @ 5 HP -> J @ 5 HP 
            Assert.AreEqual(2, mg.index.Length);

            gp = NoMiss("Cons");
            mg = new MatlabadinGraph<ulong>(gp, gp);
            SanityCheckGraph(mg);
            Assert.AreEqual(1, mg.index.Length); // Cons cycle
        }
        [Test]
        public void CalculateNextStateProbability_ShouldAdvanceStateProbabilitiesByOneState()
        {
            Int64GraphParameters gp = NoMiss("J");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            double[] pr = new double[mg.index.Length];
            pr[0] = 1;
            pr = mg.CalculateNextStateProbability(pr);
            Assert.AreEqual(1, pr.Sum());
            Assert.AreEqual(1, pr[1]); // 5HP J cycle
            pr = mg.CalculateNextStateProbability(pr);
            Assert.AreEqual(1, pr.Sum());
            Assert.AreEqual(1, pr[1]); // 5HP J cycle
        }
        [Test]
        public void CalculateNextStateProbability_ShouldDecay()
        {
            Int64GraphParameters gp = NoMiss("J");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            double[] pr = new double[mg.index.Length];
            pr[0] = 1;
            pr = mg.CalculateNextStateProbability(pr, 0.5);
            Assert.AreEqual(1, pr.Sum());
            Assert.AreEqual(0.5, pr[1]);
            Assert.AreEqual(0.5, pr[0]);
        }
        //[Test]
        //[Ignore]
        // Test no longer tests what it was intended to test
        // This test is a decay convergence test to ensure cycles such as A->B->A
        // with an initial state or pr(A) = 1, pr(B) = 0
        // actually converge to something and don't bounce between pr(A) = 1, pr(B) = 0 & pr(A) = 0, pr(B) = 1.
        // Since the graph cycle compression feature has been added, the two final states look like:
        // HP=5, cdJ=0 => HP=5, cdJ=0; action=J
        // HP=5, cdJ=12 => HP=5, cdJ=12; action=J
        // instead of 
        // HP=5, cdJ=0 => HP=5, cdJ=12; action=J
        // HP=5, cdJ=12 => HP=5, cdJ=0; action=Nothing
        // which means we need new test data & I currently can't think of a simple rotation that will
        // generate a graph of the appropriate shape
        public void ConvergeStateProbability_JShouldConvergeTo50_50With5HP()
        {
            Int64GraphParameters gp = new Int64GraphParameters(new RotationPriorityQueue<ulong>("J"), 3, 1, 1);
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            double[] pr = mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance);
            Assert.AreEqual(0.5, pr[mg.lookup[GetState(gp, Ability.J, 12, GetState(gp, Buff.GCD, 3, 5))]], Tolerance);
            Assert.AreEqual(0.5, pr[mg.lookup[GetState(gp, Ability.J, 0, 5)]], Tolerance);
        }
        [Test]
        public void CalculateResults_ShouldDisplayNotNothing()
        {
            Int64GraphParameters gp = NoMiss("CS");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            double[] pr = mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance);
            var result = mg.CalculateResults(pr);
            Assert.IsFalse(result.Action.ContainsKey("Nothing"));
        }
        [Test]
        public void ConvergeStateProbability_ShouldStopAfterRelativeToleranceAchieved()
        {
            Int64GraphParameters gp = NoMiss("CS");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            double relTol = 1e-3;
            double absTol = 1e-14;
            int maxIterations = 4096;
            int stride = 2;
            mg.ConvergeStateProbability(
                out iterationsTaken, out finalRelError, out finalAbsError,
                relTolerance: relTol,
                absTolerance: absTol,
                maxIterations: maxIterations,
                iterationStride: stride);
            if (iterationsTaken >= maxIterations) Assert.Inconclusive("Tolerance not reached before max iterations");
            mg.ConvergeStateProbability(
                out iterationsTaken, out finalRelError, out finalAbsError,
                relTolerance: relTol,
                absTolerance: absTol,
                maxIterations: iterationsTaken - stride,
                iterationStride: stride);
            // go back a stride and check that our tolerance was not achieved
            Assert.IsTrue(finalRelError > relTol);
        }
        [Test]
        public void ConvergeStateProbability_ShouldStopAfterAbsoluteToleranceAchieved()
        {
            Int64GraphParameters gp = NoMiss("CS");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            double relTol = 1e-14;
            double absTol = 1e-3;
            int maxIterations = 4096;
            int stride = 2;
            mg.ConvergeStateProbability(
                out iterationsTaken, out finalRelError, out finalAbsError,
                relTolerance: relTol,
                absTolerance: absTol,
                maxIterations: maxIterations,
                iterationStride: stride);
            if (iterationsTaken >= maxIterations) Assert.Inconclusive("Tolerance not reached before max iterations");
            mg.ConvergeStateProbability(
                out iterationsTaken, out finalRelError, out finalAbsError,
                relTolerance: relTol,
                absTolerance: absTol,
                maxIterations: iterationsTaken - stride,
                iterationStride: stride);
            // go back a stride and check that our tolerance was not achieved
            Assert.IsTrue(finalAbsError > absTol);
        }
        [Test]
        public void ConvergeStateProbability_ShouldConverge()
        {
            Int64GraphParameters gp = new Int64GraphParameters(
                new RotationPriorityQueue<ulong>("SotR5>CS>J>AS>Cons"),
                3, 0.98, 0.95);
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            int maxIterations = 8192; // 99% hit does not converge after 4096
            mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, maxIterations: maxIterations);
            Assert.AreNotEqual(maxIterations, iterationsTaken);
        }
        [Test]
        public void CalculateAggregates_Cons()
        {
            Int64GraphParameters gp = NoHitExpertise("Cons");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            var result = mg.CalculateResults(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance));
            Assert.AreEqual(1, result.Action.Count);
            Assert.AreEqual(1.0 / 9.0, result.Action["Cons"], Tolerance); // Cons every 9s
        }
        [Test]
        public void CalculateAggregates_SotRCS()
        {
            Int64GraphParameters gp = NoMiss("SotR>CS");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            var result = mg.CalculateResults(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance));
            Assert.AreEqual(1d / 4.5, result.Action["CS"], Tolerance); // once every 4.5s
            Assert.AreEqual(1d / 4.5 / 3, result.Action["SotR"], Tolerance); // once every third CS
        }
        [Test]
        public void CalculateAggregates_SotRCSJ()
        {
            Int64GraphParameters gp = NoMiss("SotR>CS>J");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            var result = mg.CalculateResults(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance));
            Assert.AreEqual(1d / 4.5, result.Action["CS"], Tolerance * 10); // 1 per 4.5s
            Assert.AreEqual(2d / (3 * 4.5), result.Action["J"], Tolerance * 10); // CS & J clash - J gets delayed 1 GCD every 2nd cycle to 2 J per 3 CS
            Assert.AreEqual(5d / 13.5 / 3, result.Action["SotR"], Tolerance * 10); // 5 HP per 13.5s cycle; 3 HP per cast
        }
        [Test]
        public void CalculateAggregates_SotRCSASJ()
        {
            Int64GraphParameters gp = NoMiss("CS>AS");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            var result = mg.CalculateResults(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance));
            Assert.IsTrue(result.Action.ContainsKey("AS")); // TODO: upper / lower bounds
            Assert.IsTrue(result.Action.ContainsKey("AS(GC)"));
        }
        [Test]
        public void SSUptimeShouldBeCalculated()
        {
            Int64GraphParameters gp = NoMiss("SS>CS");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            var result = mg.CalculateResults(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance));
            Assert.AreEqual(1, result.BuffUptime[(int)Buff.SS], 1e-7); // 100% uptime
        }
        [Test]
        public void EFUptimeShouldBeCalculated()
        {
            Int64GraphParameters gp = NoMiss("EF>CS");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            var result = mg.CalculateResults(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance));
            Assert.AreEqual(1, result.BuffUptime[(int)Buff.EF], 1e-7); // 100% uptime
        }
        [Test]
        public void WBUptimeShouldBeCalculated()
        {
            Int64GraphParameters gp = NoMiss("HotR");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            var result = mg.CalculateResults(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance));
            Assert.AreEqual(1, result.BuffUptime[(int)Buff.WB], 1e-7); // 100% uptime

            gp = new Int64GraphParameters(new RotationPriorityQueue<ulong>("HotR"), 3, 0, 0);
            mg = new MatlabadinGraph<ulong>(gp, gp);
            result = mg.CalculateResults(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance));
            Assert.AreEqual(0, result.BuffUptime[(int)Buff.WB], 1e-7); // 0% uptime since HotR never connects
        }
        [Test]
        public void SotRSBUptimeShouldBeCalculated()
        {
            Int64GraphParameters gp = NoMiss("SotR>CS>J");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            var result = mg.CalculateResults(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance));
            Assert.AreEqual(5d / 13.5 / 3 * 6, result.BuffUptime[(int)Buff.SotRSB], Tolerance * 100); // 5hp per 13.5s - cast requires 3, buff lasts 6s
        }
        [Test]
        public void CloneShouldReduceConvergenceTimeForSameResult()
        {
            Int64GraphParameters gp = new Int64GraphParameters(new RotationPriorityQueue<ulong>("SotR>CS>AS>J"), 1, 0.8, 0.95);
            MatlabadinGraph<ulong> rawGraph = new MatlabadinGraph<ulong>(gp, gp);
            int rawIterations;
            double[] rawPr = rawGraph.ConvergeStateProbability(out rawIterations, out finalRelError, out finalAbsError);

            // generate a graph with slightly different parameters
            Int64GraphParameters seedGp = new Int64GraphParameters(new RotationPriorityQueue<ulong>("SotR>CS>AS>J"), 1, 0.81, 0.96);
            MatlabadinGraph<ulong> seedGraph = new MatlabadinGraph<ulong>(seedGp, seedGp);
            int seedIterations;
            double[] seedPr = seedGraph.ConvergeStateProbability(out seedIterations, out finalRelError, out finalAbsError);

            // now see how our clone performs
            MatlabadinGraph<ulong> graph = new MatlabadinGraph<ulong>(seedGraph, gp);
            int iterations;
            double[] pr = rawGraph.ConvergeStateProbability(out iterations, out finalRelError, out finalAbsError, initialState:seedPr);
            // check we actually ended up with the same results
            Assert.AreEqual(rawPr.Length, pr.Length);
            for (int i = 0; i < pr.Length; i++)
            {
                Assert.AreEqual(rawPr[i], pr[i], 1e-8 * 4); // give more leeway than the tolerance
            }
            // check we did it faster
            Assert.IsTrue(iterations < rawIterations);
        }
    }
}
