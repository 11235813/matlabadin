using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    /// <summary>
    /// Rotation results
    /// </summary>
    public class ActionSummary
    {
        /// <summary>
        /// Frequency of actions in casts/s
        /// </summary>
        public Dictionary<string, double> Action;
        /// <summary>
        /// Uptime of tracked buffs
        /// </summary>
        public double[][] BuffStacksUptime;
        public double UptimeForBuff(Buff b, int stacks = -1)
        {
            if ((int)b >= BuffStacksUptime.Length) throw new InvalidOperationException("Sanity check failure: attempt to get uptime of untracked buff");
            double[] a = BuffStacksUptime[(int)b];
            if (a == null) return 0;
            if (stacks == -1) return a.Sum(); // total uptime for buff regardless of number of stacks
            if (stacks - 1 >= a.Length) return 0;
            return a[stacks - 1];
        }
    }
}
