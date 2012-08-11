using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public class Choice
    {
        public Choice(
            Ability ability,
            int stepsDuration,
            double[] pr,
            int hp,
            bool wogbog,
            bool asgc,
            int folsh,
            int bogStacks,
            bool aw,
            bool dp,
            bool ha,
            int gowogStacks,
            int[] buffDuration,
            bool freeGcd
            )
        {
#if !NOSANITYCHECKS
            if (pr == null) throw new ArgumentNullException("pr");
            if (buffDuration == null) throw new ArgumentNullException("buffDuration");
            if (buffDuration.Length != (int)Buff.UptimeTrackedBuffs) throw new ArgumentException("Sanity failure: buffDuration array length invalid");
            if (wogbog && !(ability == Ability.WoG || ability == Ability.EF) ) throw new ArgumentException("Sanity failure: wogbog cannot be set if ability is not WoG or EF");
            if (asgc && ability != Ability.AS) throw new ArgumentException("Sanity failure: asgc cannot be set if ability is not AS");
            if (folsh > 0 && ability != Ability.FoL) throw new ArgumentException("Sanity failure: folsh cannot be nonz-zero if ability is not FoL");
            if (buffDuration.Any(d => d > stepsDuration)) throw new ArgumentException("Sanity failure: buff duration cannot exceed step duration of transition");
            if (Math.Abs(pr.Sum() - 1.0) > 0.0001) throw new ArgumentException("Sanity failure: transition probabilities do not sum to 1");
#endif
            this.ability = ability;
            this.stepsDuration = stepsDuration;
            this.buffDuration = buffDuration;
            this.pr = pr;

            if (ability == Ability.Nothing)
            {
                action = freeGcd ? nothingWithoutGcdCD : nothingWithGcdCD;
            }
            else
            {
                action = new string[] { abilityStringLookup[(int)ability] };
                if (hp < 3 && (ability == Ability.WoG || ability == Ability.EF) && !dp )
                {
                    action[0] += hp.ToString();
                }
                if (wogbog) action[0] += String.Format("(BoG{0})", bogStacks);
                if (asgc) action[0] += "(GC)";
                if (ability == Ability.FoL) action[0] += String.Format("(SH{0})", folsh);
                if (aw) action[0] += "(AW)";
                if (ha) action[0] += "(HA)";
                if (gowogStacks > 0) action[0] += String.Format("(GoWoG{0})", gowogStacks);
            }
        }
        // Output related
        public string[] Action { get { return action; } }
        public Ability Ability { get { return ability; } }
        private readonly string[] action;
        private readonly Ability ability;
        public readonly int stepsDuration;
        /// <summary>
        /// Duration of buffs
        /// </summary>
        public readonly int[] buffDuration;
        /// <summary>
        /// transition likelyhoods
        /// </summary>
        public readonly double[] pr;
        public override bool Equals(object obj)
        {
            if (obj is Choice) return Equals((Choice)obj);
            return base.Equals(obj);
        }
        public bool Equals(Choice c)
        {
            return hashcode == c.hashcode
                && stepsDuration == c.stepsDuration
                && buffDuration.SequenceEqual(c.buffDuration)
                && pr.SequenceEqual(c.pr)
                && Action.SequenceEqual(c.Action);
        }
        public override int GetHashCode()
        {
            if (hashcode == 0)
            {
                hashcode = stepsDuration ^ pr.Aggregate(0, (h, p) => h ^ (int)(p * (1 << 30)));
                for (int i = 0; i < (int)Buff.UptimeTrackedBuffs; i++)
                {
                    hashcode ^= buffDuration[i] << (5 + 2 * i);
                }
                hashcode ^= Action.Aggregate(0, (h, a) => h ^ a.GetHashCode());
            }
            return hashcode;
        }
        public override string ToString()
        {
            string s = this.action.Aggregate("Action:", (str, a) => str + ">" + a);
            s += " duration:" + this.stepsDuration;
            s += " pr: " + this.pr.Aggregate("", (str, p) => str + p + ",");
            s += " buff: " + this.buffDuration.Aggregate("", (str, p) => str + p + ",");
            return s;
        }
        private int hashcode;
        private Choice(Choice first, Choice second)
        {
            if (first.pr.Length != 1)
            {
                throw new InvalidOperationException("Cannot concatenate to a choice that has multiple next states");
            }
            this.ability = first.ability == Ability.Nothing ? second.ability : first.ability;
            this.stepsDuration = first.stepsDuration + second.stepsDuration;
            this.pr = second.pr;
            // Add the buff durations
            this.buffDuration = new int[(int)Buff.UptimeTrackedBuffs];
            for (int i = 0; i < (int)Buff.UptimeTrackedBuffs; i++)
            {
                this.buffDuration[i] = first.buffDuration[i] + second.buffDuration[i];
            }
            // Concatenate actions
            if (first.Action.Length == 0)
            {
                this.action = second.Action;
            }
            else if (second.Action.Length == 0)
            {
                this.action = first.Action;
            }
            else
            {
                string[] a = new string[first.Action.Length + second.Action.Length];
                int i = 0;
                foreach (string ac in first.Action) a[i++] = ac;
                foreach (string ac in second.Action) a[i++] = ac;
                this.action = a;
            }
        }
        /// <summary>
        /// Peforms the current choice, then the given choice
        /// </summary>
        /// <param name="choice">Choice to perform after current choice</param>
        /// <returns></returns>
        public Choice Concatenate(Choice choice)
        {
            return new Choice(this, choice);
        }
        static Choice()
        {
            abilityStringLookup = new string[(int)Ability.Count];
            for (int i = 0; i < (int)Ability.Count; i++)
            {
                abilityStringLookup[i] = ((Ability)i).ToString();
            }
        }
        // precomputation optimisation removing ability.ToString() call from Choice constructor
        private static readonly string[] abilityStringLookup;
        private static readonly string[] nothingWithGcdCD = new string[0];
        private static readonly string[] nothingWithoutGcdCD = new string[] { "_" };
    }
}
