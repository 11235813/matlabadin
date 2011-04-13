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
            Choice c = new Choice(a,
                a == Ability.SotR && StateHelper.TimeRemaining(state, Buff.SD, gp) > 0,
                StateHelper.TimeRemaining(state, Buff.INQ, gp) > 0,
                stepsDuration, option1, option2, option3);
            Choice lookupChoice;
            if (!globalLookup.TryGetValue(c, out lookupChoice))
            {
                lookupChoice = c;
                globalLookup.Add(lookupChoice, lookupChoice);
            }
            return lookupChoice;
        }
        private static Dictionary<Choice, Choice> globalLookup = new Dictionary<Choice, Choice>();
        private Choice(Ability ability, bool sotrsd, bool inq, int stepsDuration, double option1, double option2, double option3)
        {
            this.ability = ability;
            this.sotrsd = sotrsd;
            this.inq = inq;
            this.stepsDuration = stepsDuration;
            this.option1 = option1;
            this.option2 = option2;
            this.option3 = option3;
        }
        // Output related
        public string Action
        {
            get
            {
                if (action == null)
                {
                    action = ability.ToString();
                    if (sotrsd) action += "(SD)";
                    if (inq) action += "(Inq)";
                }
                return action;
            }
        }
        private string action;
        private readonly Ability ability;
        private readonly bool sotrsd;
        private readonly bool inq;
        

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
            return ability == c.ability
                && sotrsd == c.sotrsd
                && inq == c.inq
                && stepsDuration == c.stepsDuration
                && option1 == c.option1
                && option2 == c.option2
                && option3 == c.option3;
        }
        public override int GetHashCode()
        {
            int hash = stepsDuration.GetHashCode() ^ option1.GetHashCode() ^ option2.GetHashCode() ^ option3.GetHashCode();
            if (inq) hash ^= 1 << 28;
            if (sotrsd) hash ^= 1 << 27;
            hash += (int)ability << 16;
            return hash;
        }
    }
}
