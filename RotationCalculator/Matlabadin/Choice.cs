using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public class Choice
    {
        public static Choice CreateChoice(ulong state, GraphParameters gp, Ability a, int stepsDuration, double option1, double option2, double option3)
        {
            string action = String.Format("{0}{1}{2}",
                    a,
                    (a == Ability.SotR && StateHelper.TimeRemaining(state, Buff.SD, gp) > 0) ? "(SD)" : "",
                    StateHelper.TimeRemaining(state, Buff.INQ, gp) > 0 ? "(Inq)": "");
            // TODO: choice cache: return an existing instance when all parameters match.
            // This will reduce the working set size when calculating probabilities by ~75%
            // TODO: do not make a String.Format call if the choice is already cached
            return new Choice(action, stepsDuration, option1, option2, option3);
        }
        private Choice(string action, int stepsDuration, double option1, double option2, double option3)
        {
            this.action = action;
            this.stepsDuration = stepsDuration;
            this.option1 = option1;
            this.option2 = option2;
            this.option3 = option3;
        }
        // Output related
        public readonly string action;

        // required for aggregration
        public readonly int stepsDuration;
        // transition likelyhoods
        public readonly double option1;
        public readonly double option2;
        public readonly double option3;
        public override bool Equals(object obj)
        {
            if (obj is Choice) return Equals((Choice)obj);
            return base.Equals(obj);
        }
        public bool Equals(Choice c)
        {
            return action == c.action
                && stepsDuration == c.stepsDuration
                && option1 == c.option1
                && option2 == c.option2
                && option3 == c.option3;
        }
        public override int GetHashCode()
        {
            return action.GetHashCode() ^ stepsDuration.GetHashCode() ^ option1.GetHashCode() ^ option2.GetHashCode() ^ option3.GetHashCode();
        }
    }
}
