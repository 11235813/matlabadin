using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;

namespace Matlabadin.Tests
{
    [TestFixture]
    public class MatlabadinSimTreeTest : MatlabadinTest
    {
        public const double Tolerance = 1e-14;
        [Test]
        public void ShouldStopAtStepsDuration()
        {
            Int64GraphParameters gp = NoMiss("J>CS");
            MatlabadinSimTree<BitVectorState> mst = new MatlabadinSimTree<BitVectorState>(gp, gp);
            ActionSummary result = mst.Calculate(1);
            Assert.IsFalse(result.Action.ContainsKey("CS"));
        }
        [Test]
        public void ShouldNormaliseOutputToCastsPerSecond()
        {
            Int64GraphParameters gp = NoMiss("J");
            MatlabadinSimTree<BitVectorState> mst = new MatlabadinSimTree<BitVectorState>(gp, gp);
            Assert.AreEqual(2.0, mst.Calculate(1).Action["J"]); // 1 cast in 0.5s = 2c/s
            Assert.AreEqual(1.0, mst.Calculate(2).Action["J"]);
            Assert.AreEqual(0.5, mst.Calculate(4).Action["J"]);
        }
        [Test]
        public void ShouldCalculateBuffUptimePercentage()
        {
            Int64GraphParameters gp = NoMiss("J");
            MatlabadinSimTree<BitVectorState> mst = new MatlabadinSimTree<BitVectorState>(gp, gp);
            ActionSummary result = mst.Calculate(6);
            Assert.AreEqual(0.5, result.UptimeForBuff(Buff.GCD)); // 3 GCD steps + 3 off-GCD steps
        }
        [Test]
        public void ShouldCalculateForkedBuffUptimePercentage()
        {
            Int64GraphParameters gp = new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("HotR"), PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 1, 0, 0.75, 0.75);
            MatlabadinSimTree<BitVectorState> mst = new MatlabadinSimTree<BitVectorState>(gp, gp);
            ActionSummary result = mst.Calculate(3);
            Assert.AreEqual(0.75, result.UptimeForBuff(Buff.WB)); // 75% chance that HotR hit & WB up for all 3 steps
        }
        [Test]
        public void ShouldNotTravereZeroProbabilityTransitions()
        {
            Int64GraphParameters gp = new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("SotR>CS"), PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 1, 0, 0, 0);
            MatlabadinSimTree<BitVectorState> mst = new MatlabadinSimTree<BitVectorState>(gp, gp);
            ActionSummary result = mst.Calculate(128);
            Assert.IsFalse(result.Action.ContainsKey("SotR"));
        }
        [Test]
        public void ShouldMergeAggregatePaths()
        {
            Int64GraphParameters gp = new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("CS"), PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 1, 0, 0.75, 0.75);
            MatlabadinSimTree<BitVectorState> mst = new MatlabadinSimTree<BitVectorState>(gp, gp);
            for (int i = 0; i < 8; i++)
            {
                Assert.AreEqual(1.0 / 4.5, mst.Calculate(3 * (1 << i)).Action["CS"], Tolerance); // 1 cast in 4.5s
            }
        }
        [Test]
        public void ExecutionShouldBeUnder5Seconds()
        {
            Int64GraphParameters gp = new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("^WB>^SS>AW5>SotR5>CS>J>AS>Cons"), PaladinSpec.Prot, PaladinTalents.All, PaladinGlyphs.None, 3, 0, 0.95, 0.95);
            MatlabadinSimTree<BitVectorState> mst = new MatlabadinSimTree<BitVectorState>(gp, gp);
            DateTime start = DateTime.Now;
            mst.Calculate(3 * 300); // 5min encounter
            Assert.AreEqual(5, DateTime.Now.Subtract(start).TotalSeconds);
        }
    }
}
