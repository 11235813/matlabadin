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
        public const double Tolerance = 1e-14;
        public void SanityCheckGraph(MatlabadinGraph mg)
        {
            Assert.AreEqual(mg.index.Count(), mg.lookup.Count());
            Assert.AreEqual(mg.index.Count(), mg.nextState.Count());
            Assert.AreEqual(mg.index.Count(), mg.choice.Count());
            for (int i = 0; i < mg.index.Count(); i++)
            {
                Assert.IsTrue(mg.nextState[i].nextStateIndex1 == -1 && mg.choice[i].option1 == 0 || mg.nextState[i].nextStateIndex1 >= 0 && mg.choice[i].option1 > 0);
                Assert.IsTrue(mg.nextState[i].nextStateIndex2 == -1 && mg.choice[i].option2 == 0 || mg.nextState[i].nextStateIndex2 >= 0 && mg.choice[i].option2 > 0);
                Assert.IsTrue(mg.nextState[i].nextStateIndex3 == -1 && mg.choice[i].option3 == 0 || mg.nextState[i].nextStateIndex3 >= 0 && mg.choice[i].option3 > 0);
            }
        }
        [TestMethod]
        public void GenerateGraph_ShouldOnlyGenerateNonZeroTransitions()
        {
            MatlabadinGraph mg = new MatlabadinGraph(NoMissNoProcsParameters, RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction("CS"));
            mg.GenerateGraph();
            SanityCheckGraph(mg);
            // starting state is unreachable
            Assert.IsTrue(mg.nextState.All(s => s.nextStateIndex1 != 0 && s.nextStateIndex2 != 0 && s.nextStateIndex3 != 0));
        }
        [TestMethod]
        public void GenerateGraph_NextStateTransitionsShouldAlwaysBeSet()
        {
            MatlabadinGraph mg = new MatlabadinGraph(NoMissNoProcsParameters, RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction("CS"));
            mg.GenerateGraph();
            SanityCheckGraph(mg);
            Assert.AreEqual(7, mg.index.Length); // 0-3 HP with CS no/off CD = 7 states + 0 HP CS off CD which is unreachable

            mg = new MatlabadinGraph(NoMissNoProcsParameters, RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction("HW"));
            mg.GenerateGraph();
            SanityCheckGraph(mg);
            Assert.AreEqual(10, mg.index.Length); // HW CD of 0, 3, 6, 9, 12, 15, 18, 21, 24, 27 steps
        }
        [TestMethod]
        public void CalculateNextStateProbability_ShouldAdvanceStateProbabilitiesByOneState()
        {
            MatlabadinGraph mg = new MatlabadinGraph(NoMissNoProcsParameters, RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction("CS"));
            mg.GenerateGraph();
            double[] pr = new double[mg.index.Length];
            pr[0] = 1;
            pr = mg.CalculateNextStateProbability(pr);
            Assert.AreEqual(1, pr.Sum());
            Assert.AreEqual(1, pr[mg.lookup[GetState(Ability.CS, 3, 1)]]);
            pr = mg.CalculateNextStateProbability(pr);
            Assert.AreEqual(1, pr[mg.lookup[GetState(Ability.CS, 0, 1)]]);
            pr = mg.CalculateNextStateProbability(pr);
            Assert.AreEqual(1, pr[mg.lookup[GetState(Ability.CS, 3, 2)]]);
        }
        [TestMethod]
        public void CalculateNextStateProbability_ShouldDecay()
        {
            MatlabadinGraph mg = new MatlabadinGraph(NoMissNoProcsParameters, RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction("CS"));
            mg.GenerateGraph();
            double[] pr = new double[mg.index.Length];
            pr[0] = 1;
            pr = mg.CalculateNextStateProbability(pr, 0.5);
            Assert.AreEqual(1, pr.Sum());
            Assert.AreEqual(0.5, pr[mg.lookup[GetState(Ability.CS, 3, 1)]]);
            Assert.AreEqual(0.5, pr[0]);
        }
        [TestMethod]
        public void ConvergeStateProbability_CSShouldConvergeTo50_50With3HP()
        {
            MatlabadinGraph mg = new MatlabadinGraph(NoMissNoProcsParameters, RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction("CS"));
            mg.GenerateGraph();
            double[] pr = mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance);
            Assert.AreEqual(0.5, pr[mg.lookup[GetState(Ability.CS, 3, 3)]], Tolerance);
            Assert.AreEqual(0.5, pr[mg.lookup[GetState(Ability.CS, 0, 3)]], Tolerance);

            double stepDuration;
            var result = mg.CalculateAggregates(pr, out stepDuration);

            Assert.AreEqual(0.5, result["CS"], Tolerance);
            Assert.AreEqual(0.5, result["Nothing"], Tolerance);
            Assert.AreEqual(1.5, stepDuration, Tolerance);
        }
        [TestMethod]
        public void ConvergeStateProbability_ShouldStopAfterToleranceAchieved()
        {
            MatlabadinGraph mg = new MatlabadinGraph(DefaultParameters, RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction("CS"));
            mg.GenerateGraph();
            double tol = 1e-6;
            int maxIterations = 4096;
            int stride = 2;
            mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: tol, maxIterations: maxIterations, iterationStride: stride);
            if (iterationsTaken >= maxIterations) Assert.Inconclusive("Tolerance not reached before max iterations");
            mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: tol, maxIterations: iterationsTaken - stride, iterationStride: stride);
            // go back a stride and check that our tolerance was not achieved
            Assert.IsTrue(finalRelError > tol);
        }
        [TestMethod]
        public void CalculateAggregates_HW()
        {
            MatlabadinGraph mg = new MatlabadinGraph(DefaultParameters, RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction("HW"));
            mg.GenerateGraph();
            double stepDuration;
            var result = mg.CalculateAggregates(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance),
                out stepDuration);
            Assert.AreEqual(0.1, result["HW"], Tolerance);
            Assert.AreEqual(0.9, result["Nothing"], Tolerance);
            Assert.AreEqual(1.5, stepDuration, Tolerance);
        }
        [TestMethod]
        public void CalculateAggregates_SotRCS()
        {
            MatlabadinGraph mg = new MatlabadinGraph(NoMissParameters, RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction("SotR>CS"));
            mg.GenerateGraph();
            double stepDuration;
            var result = mg.CalculateAggregates(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance),
                out stepDuration);
            Assert.AreEqual(0.5, result["CS"], Tolerance);
            Assert.AreEqual(1d / 6, result["SotR"], Tolerance);
            Assert.AreEqual(2d / 6, result["Nothing"], Tolerance);
            Assert.AreEqual(1.5, stepDuration, Tolerance);
        }
        [TestMethod]
        public void CalculateAggregates_SotRCSJ()
        {
            MatlabadinGraph mg = new MatlabadinGraph(NoMissParameters, RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction("SotR>CS>J"));
            mg.GenerateGraph();
            double stepDuration;
            var result = mg.CalculateAggregates(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance),
                out stepDuration);
            Assert.AreEqual(0.5, result["CS"], Tolerance);
            Assert.AreEqual(1d / 6 / 2, result["SotR"], Tolerance); // 50% proc rate on SD
            Assert.AreEqual(1d / 6 / 2, result["SotR(SD)"], Tolerance);
            Assert.AreEqual(1d / 6, result["J"], Tolerance);
            Assert.AreEqual(1d / 6, result["Nothing"], Tolerance);
            Assert.AreEqual(1.5, stepDuration, Tolerance);

            mg = new MatlabadinGraph(NoMissNoProcsParameters, RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction("SotR>CS>J"));
            mg.GenerateGraph();
            result = mg.CalculateAggregates(
                mg.ConvergeStateProbability(out iterationsTaken, out finalRelError, out finalAbsError, relTolerance: Tolerance),
                out stepDuration);
            Assert.AreEqual(1d / 6, result["SotR"], Tolerance);
            if (result.ContainsKey("SotR(SD)")) Assert.AreEqual(0d, result["SotR(SD)"], Tolerance);
        }
    }
}
