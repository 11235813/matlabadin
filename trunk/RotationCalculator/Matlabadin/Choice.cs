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
            bool wogss,
            int[][] buffDuration
            )
        {
            if (pr == null) throw new ArgumentNullException("pr");
            if (buffDuration == null) throw new ArgumentNullException("buffDuration");
            if (wogss && ability != Ability.WoG) throw new ArgumentException("Sanity failure: wogss cannot be set if ability is not WoG");
            if (buffDuration.Any(bd => bd.Any(d => d > stepsDuration))) throw new ArgumentException("Sanity failure: buff duration cannot exceed step duration of transition");
            if (buffDuration.Length != (int)Buff.UptimeTrackedBuffs) throw new ArgumentException("Sanity failure: buffDuration array length invalid");
            if (Math.Abs(pr.Sum() - 1.0) > 0.0001) throw new ArgumentException("Sanity failure: transition probabilities do not sum to 1");
            if (buffDuration.Any(bd => bd.Length != pr.Length)) throw new ArgumentException("Sanity failure: buff duration array length does not match probability array length");
            this.ability = ability;
            this.hp = hp;
            this.wogss = wogss;
            this.stepsDuration = stepsDuration;
            this.buffDuration = buffDuration;
            this.pr = pr;
        }
        // Output related
        public virtual string[] Action
        {
            get
            {
                if (action == null)
                {
                    if (ability == Ability.Nothing)
                    {
                        action = new string[0];
                    }
                    else
                    {
                        action = new string[] { ability.ToString() };
                        if (hp < 3 && (ability == Ability.WoG || ability == Ability.EF))
                        {
                            action[0] += hp.ToString();
                        }
                        if (wogss) action[0] += "(SS)";
                    }
                }
                return action;
            }
        }
        public Ability Ability { get { return this.ability; } }
        private string[] action;
        private readonly Ability ability;
        private readonly bool wogss;
        private readonly int hp;
        public readonly int stepsDuration;
        public readonly int[][] buffDuration;
        // transition likelyhoods
        public readonly double[] pr;
        public override bool Equals(object obj)
        {
            if (obj is Choice) return Equals((Choice)obj);
            return base.Equals(obj);
        }
        public bool Equals(Choice c)
        {
            return ability == c.ability
                && wogss == c.wogss
                && hp == c.hp
                && stepsDuration == c.stepsDuration
                && buffDuration.Length == c.buffDuration.Length
                && buffDuration.Zip(c.buffDuration, (a, b) => a.SequenceEqual(b)).All(e => e) // jagged arrays match
                && pr.SequenceEqual(c.pr)
                && Action.SequenceEqual(c.Action);
        }
        public override int GetHashCode()
        {
            int hash = pr.Aggregate(0, (h, p) => h ^ p.GetHashCode());
            hash ^= stepsDuration.GetHashCode(); // assuming ~< 7 bits
            hash ^= ~(buffDuration.SelectMany(b => b).Aggregate(0, (h, p) => h ^ p.GetHashCode()) << 7);
            hash ^= hp << (7 + 9);
            if (wogss) hash ^= 1 << (7 + 9 + 3);
            hash += (int)ability << (7 + 9 + 3 + 1);
            return hash;
        }
        private Choice(Choice first, Choice second)
        {
            if (first.pr.Length != 1)
            {
                throw new InvalidOperationException("Cannot concatenate to a choice that has multiple next states");
            }
            this.ability = first.ability == Ability.Nothing ? second.ability : first.ability;
            this.stepsDuration = first.stepsDuration + second.stepsDuration;
            this.pr = second.pr;
            this.hp = first.hp;
            // Add the buff duration of the single transition to the choice buff durations
            this.buffDuration = first.buffDuration.Zip(second.buffDuration, (singleElement, duration) => duration.Select(d => d + singleElement[0]).ToArray()).ToArray();
            this.action = first.Action.Concat(second.Action).ToArray();
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
    }
}
