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
            // Special case Inquisition since we may not have inq up when we cast Inq but it's up as a buff for the duration of the casting GCD
            int inqLeft = StateHelper.TimeRemaining(state, Buff.Inq, gp);
            if (a == Ability.Inq && StateHelper.HP(state, gp) > 0) inqLeft += gp.StepsPerGcd; // add at least the GCD to the remaining duration

            Choice c = new Choice(a,
                a == Ability.SotR && StateHelper.TimeRemaining(state, Buff.SD, gp) > 0,
                inqLeft,
                StateHelper.HP(state, gp),
                stepsDuration,
                option1, option2, option3);
            Choice lookupChoice;
            if (!globalLookup.TryGetValue(c, out lookupChoice))
            {
                lock (globalLookup)
                {
                    if (!globalLookup.TryGetValue(c, out lookupChoice))
                    {
                        lookupChoice = c;
                        globalLookup.Add(lookupChoice, lookupChoice);
                    }
                }
            }
            return lookupChoice;
        }
        private static Dictionary<Choice, Choice> globalLookup = new Dictionary<Choice, Choice>();
        private Choice(Ability ability, bool sotrsd, int inq, int hp, int stepsDuration, double option1, double option2, double option3)
        {
            this.ability = ability;
            this.hp = hp;
            this.sotrsd = sotrsd;
            this.stepsDuration = stepsDuration;
            this.inqDuration = Math.Min(inq, stepsDuration);
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
                    if (hp != 3 && (ability == Ability.SotR || ability == Ability.WoG)) {
                        // Not required for Inq
                        action += hp.ToString();
                    }
                    if (sotrsd) action += "(SD)";
                    if (inqDuration > 0) action += "(Inq)";
                }
                return action;
            }
        }
        private string action;
        private readonly Ability ability;
        private readonly bool sotrsd;
        private readonly int hp;

        // aggregation stats
        public readonly int inqDuration;
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
                && inqDuration == c.inqDuration
                && hp == c.hp
                && stepsDuration == c.stepsDuration
                && option1 == c.option1
                && option2 == c.option2
                && option3 == c.option3;
        }
        public override int GetHashCode()
        {
            int hash = stepsDuration.GetHashCode() ^ option1.GetHashCode() ^ option2.GetHashCode() ^ option3.GetHashCode();
            hash ^= inqDuration << 7;
            hash ^= hp << 11;
            if (sotrsd) hash ^= 1 << 27;
            hash += (int)ability << 16;
            return hash;
        }
    }
}
