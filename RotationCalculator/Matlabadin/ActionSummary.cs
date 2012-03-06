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
        public double[] BuffUptime;
    }
}
