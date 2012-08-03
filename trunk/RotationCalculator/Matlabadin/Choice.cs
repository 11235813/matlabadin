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
            int[] unforkedBuffDuration,
            int[][] forkedBuffDuration
            )
        {
#if !NOSANITYCHECKS
            if (pr == null) throw new ArgumentNullException("pr");
            if (unforkedBuffDuration == null) throw new ArgumentNullException("buffDuration");
            if (forkedBuffDuration == null) throw new ArgumentNullException("buffDuration");
            if (unforkedBuffDuration.Length + forkedBuffDuration.Length != (int)Buff.UptimeTrackedBuffs) throw new ArgumentException("Sanity failure: buffDuration array length invalid");
            if (unforkedBuffDuration.Length != (int)Buff.UptimeTrackedUnforkedBuffs) throw new ArgumentException("Sanity failure: unforkedBuffDuration array length invalid");
            if (forkedBuffDuration.Length != (int)Buff.UptimeTrackedForkedBuffs - (int)Buff.UptimeTrackedUnforkedBuffs) throw new ArgumentException("Sanity failure: forkedBuffDuration array length invalid");
            if (wogbog && !(ability == Ability.WoG || ability == Ability.EF) ) throw new ArgumentException("Sanity failure: wogbog cannot be set if ability is not WoG or EF");
            if (asgc && ability != Ability.AS) throw new ArgumentException("Sanity failure: asgc cannot be set if ability is not AS");
            if (folsh > 0 && ability != Ability.FoL) throw new ArgumentException("Sanity failure: folsh cannot be nonz-zero if ability is not FoL");
            if (unforkedBuffDuration.Any(d => d > stepsDuration)) throw new ArgumentException("Sanity failure: buff duration cannot exceed step duration of transition");
            if (forkedBuffDuration.Any(bd => bd.Any(d => d > stepsDuration))) throw new ArgumentException("Sanity failure: buff duration cannot exceed step duration of transition");
            if (Math.Abs(pr.Sum() - 1.0) > 0.0001) throw new ArgumentException("Sanity failure: transition probabilities do not sum to 1");
            if (forkedBuffDuration.Any(bd => bd.Length != pr.Length)) throw new ArgumentException("Sanity failure: buff duration array length does not match probability array length");
#endif
            this.ability = ability;
            this.stepsDuration = stepsDuration;
            this.unforkedBuffDuration = unforkedBuffDuration;
            this.forkedBuffDuration = forkedBuffDuration;
            this.pr = pr;

            if (ability == Ability.Nothing)
            {
                action = new string[0];
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
            }
        }
        // Output related
        public string[] Action { get { return action; } }
        public Ability Ability { get { return ability; } }
        private readonly string[] action;
        private readonly Ability ability;
        public readonly int stepsDuration;
        /// <summary>
        /// Duration of buffs that do not change based on choice outcomes
        /// </summary>
        public readonly int[] unforkedBuffDuration;
        /// <summary>
        /// Duration of buffs that can change
        /// </summary>
        public readonly int[][] forkedBuffDuration;
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
                && unforkedBuffDuration.SequenceEqual(c.unforkedBuffDuration)
                && forkedBuffDuration.Zip(c.forkedBuffDuration, (a, b) => a.SequenceEqual(b)).All(e => e) // jagged arrays match
                && pr.SequenceEqual(c.pr)
                && Action.SequenceEqual(c.Action);
        }
        public override int GetHashCode()
        {
            if (hashcode == 0)
            {
                hashcode = stepsDuration ^ pr.Aggregate(0, (h, p) => h ^ (int)(p * (1 << 30)));
                for (int i = 0; i < (int)Buff.UptimeTrackedUnforkedBuffs; i++)
                {
                    hashcode ^= unforkedBuffDuration[i] << (5 + 2 * i);
                }
                for (int i = 0; i < (int)Buff.UptimeTrackedForkedBuffs - (int)Buff.UptimeTrackedUnforkedBuffs; i++)
                {
                    int[] forked = forkedBuffDuration[i];
                    for (int j = 0; j < forked.Length; j++)
                    {
                        hashcode ^= forked[j] << (5 + i + j);
                    }
                }
                for (int i = 0; i < action.Length; i++)
                {
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
            s += " unforked: " + this.unforkedBuffDuration.Aggregate("", (str, p) => str + p + ",");
            s += " forked: " + this.forkedBuffDuration.Aggregate("", (str, f) => str + "[" + f.Aggregate("", (sa, p) => sa + p + ",") + "]");
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
            this.unforkedBuffDuration = new int[(int)Buff.UptimeTrackedUnforkedBuffs];
            for (int i = 0; i < (int)Buff.UptimeTrackedUnforkedBuffs; i++)
            {
                this.unforkedBuffDuration[i] = first.unforkedBuffDuration[i] + second.unforkedBuffDuration[i];
            }
            this.forkedBuffDuration = new int[(int)Buff.UptimeTrackedForkedBuffs - (int)Buff.UptimeTrackedUnforkedBuffs][];
            for (int i = 0; i < (int)Buff.UptimeTrackedForkedBuffs - (int)Buff.UptimeTrackedUnforkedBuffs; i++)
            {
                this.forkedBuffDuration[i] = new int[second.pr.Length];
                int firstDuration = first.forkedBuffDuration[i][0];
#if !NOSANITYCHECKS
                if (first.forkedBuffDuration[i].Length != 1) throw new ArgumentException("Sanity check failure: Unable to concatenate non-linear forkedBuffDuration");
#endif
                for (int j = 0; j < second.pr.Length; j++)
                {
                    this.forkedBuffDuration[i][j] = firstDuration + second.forkedBuffDuration[i][j];
                }
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
    }
}
