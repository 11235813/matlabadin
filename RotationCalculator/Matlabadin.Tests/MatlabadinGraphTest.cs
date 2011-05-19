using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Matlabadin.Tests
{
    [TestClass]
    public class MatlabadinGraphTest : MatlabadinTest
    {
        private int iterationsTaken;
        private double finalAbsError, finalRelError;
        private double inqUptime;
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
        [TestMethod]
        public void GenerateGraph_ShouldOnlyGenerateNonZeroTransitions()
        {
            Int64GraphParameters gp = NoMissNoProcs("CS");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            SanityCheckGraph(mg); // starting state (0) should be unreachable for a CS rotation with no miss
        }
        [TestMethod]
        public void GenerateGraph_NextStateTransitionsShouldAlwaysBeSet()
        {
            Int64GraphParameters gp = NoMissNoProcs("CS");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            SanityCheckGraph(mg);
            Assert.AreEqual(7, mg.index.Length); // 0-3 HP with CS no/off CD = 7 states + 0 HP CS off CD which is unreachable

            gp = NoMissNoProcs("HW");
            mg = new MatlabadinGraph<ulong>(gp, gp);
            SanityCheckGraph(mg);
            Assert.AreEqual(10, mg.index.Length); // HW CD of 0, 3, 6, 9, 12, 15, 18, 21, 24, 27 steps
        }
        [TestMethod]
        public void CalculateNextStateProbability_ShouldAdvanceStateProbabilitiesByOneState()
        {
            Int64GraphParameters gp = NoMissNoProcs("CS");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            double[] pr = new double[mg.index.Length];
            pr[0] = 1;
            pr = mg.CalculateNextStateProbability(pr);
            Assert.AreEqual(1, pr.Sum());
            Assert.AreEqual(1, pr[mg.lookup[GetState(gp, Ability.CS, 3, 1)]]);
            pr = mg.CalculateNextStateProbability(pr);
            Assert.AreEqual(1, pr[mg.lookup[GetState(gp, Ability.CS, 0, 1)]]);
            pr = mg.CalculateNextStateProbability(pr);
            Assert.AreEqual(1, pr[mg.lookup[GetState(gp, Ability.CS, 3, 2)]]);
        }
        [TestMethod]
        public void CalculateNextStateProbability_ShouldDecay()
        {
            Int64GraphParameters gp = NoMissNoProcs("CS");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            double[] pr = new double[mg.index.Length];
            pr[0] = 1;
            pr = mg.CalculateNextStateProbability(pr, 0.5);
            Assert.AreEqual(1, pr.Sum());
            Assert.AreEqual(0.5, pr[mg.lookup[GetState(gp, Ability.CS, 3, 1)]]);
            Assert.AreEqual(0.5, pr[0]);
        }
        [TestMethod]
        public void ConvergeStateProbability_CSShouldConvergeTo50_50With3HP()
        {
            Int64GraphParameters gp = NoMissNoProcs("CS");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            double[] pr = mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance);
            Assert.AreEqual(0.5, pr[mg.lookup[GetState(gp, Ability.CS, 3, 3)]], Tolerance);
            Assert.AreEqual(0.5, pr[mg.lookup[GetState(gp, Ability.CS, 0, 3)]], Tolerance);
        }
        [TestMethod]
        public void CalculateResults_ShouldNotDisplayNothing()
        {
            Int64GraphParameters gp = NoMissNoProcs("Inq>CS");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            double[] pr = mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance);
            var result = mg.CalculateResults(pr, out inqUptime);
            Assert.IsFalse(result.ContainsKey("Nothing"));
            Assert.IsFalse(result.ContainsKey("Nothing(Inq)"));
        }
        [TestMethod]
        public void ConvergeStateProbability_ShouldStopAfterRelativeToleranceAchieved()
        {
            Int64GraphParameters gp = NoMissNoProcs("CS");
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
        [TestMethod]
        public void ConvergeStateProbability_ShouldStopAfterAbsoluteToleranceAchieved()
        {
            Int64GraphParameters gp = NoMissNoProcs("CS");
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
        [TestMethod]
        public void ConvergeStateProbability_ShouldConverge()
        {
            Int64GraphParameters gp = new Int64GraphParameters(
                new RotationPriorityQueue<ulong>("SotR>CS>J>AS>HW>Cons"),
                3, false, 0.98, 0.95, 0.5, 0.2, 0.3);
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            int maxIterations = 8192; // 99% hit does not converge after 4096
            mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, maxIterations: maxIterations);
            Assert.AreNotEqual(maxIterations, iterationsTaken);
        }
        [TestMethod]
        public void CalculateAggregates_HW()
        {
            Int64GraphParameters gp = NoHitExpertise("HW");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            var result = mg.CalculateResults(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance)
                , out inqUptime);
            Assert.AreEqual(1, result.Count);
            Assert.AreEqual(1.0 / 15, result["HW"], Tolerance);
        }
        [TestMethod]
        public void CalculateAggregates_SotRCS()
        {
            Int64GraphParameters gp = NoMiss("SotR>CS");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            var result = mg.CalculateResults(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance),
                out inqUptime);
            Assert.AreEqual(0.5 / 1.5, result["CS"], Tolerance);
            Assert.AreEqual(1d / 6 / 1.5, result["SotR"], Tolerance);
        }
        [TestMethod]
        public void CalculateAggregates_SotRCSJ()
        {
            Int64GraphParameters gp = NoMiss("SotR>CS>J");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            var result = mg.CalculateResults(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance),
                out inqUptime);
            Assert.AreEqual(0.5 / 1.5, result["CS"], Tolerance);
            Assert.AreEqual(1d / 6 / 2 / 1.5, result["SotR"], Tolerance); // 50% proc rate on SD
            Assert.AreEqual(1d / 6 / 2 / 1.5, result["SotR(SD)"], Tolerance);
            Assert.AreEqual(1d / 6 / 1.5, result["J"], Tolerance);

            gp = NoMissNoProcs("SotR>CS>J");
            mg = new MatlabadinGraph<ulong>(gp, gp);
            result = mg.CalculateResults(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance),
                out inqUptime);
            Assert.AreEqual(1d / 6 / 1.5, result["SotR"], Tolerance);
            if (result.ContainsKey("SotR(SD)")) Assert.AreEqual(0d, result["SotR(SD)"], Tolerance);
        }
        [TestMethod]
        public void InqUptimeShouldIncludeInqCasts()
        {
            Int64GraphParameters gp = NoMiss("ISotR>Inq>CS");
            MatlabadinGraph<ulong> mg = new MatlabadinGraph<ulong>(gp, gp);
            // 12s duration
            // 9s between 3 HP
            // -> 18s between Inq (HP usages alternates between SotR & Inq)
            double inqUptime;
            var result = mg.CalculateResults(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance, absTolerance: Tolerance),
                out inqUptime);
            Assert.AreEqual(12.0 / 18.0, inqUptime, Tolerance * 100); // aggregation is outside tolerance due to FP rounding
        }
        [TestMethod]
        public void CloneReduceConvergenceTimeForSameResult()
        {
            Int64GraphParameters gp = new Int64GraphParameters(new RotationPriorityQueue<ulong>("SotR>CS>AS>J"), 1, false, 0.8, 0.95, 0, 0, 0);
            MatlabadinGraph<ulong> rawGraph = new MatlabadinGraph<ulong>(gp, gp);
            int rawIterations;
            double[] rawPr = rawGraph.ConvergeStateProbability(out rawIterations, out finalRelError, out finalAbsError);

            // generate a graph with slightly different parameters
            Int64GraphParameters seedGp = new Int64GraphParameters(new RotationPriorityQueue<ulong>("SotR>CS>AS>J"), 1, false, 0.81, 0.96, 0, 0, 0);
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
