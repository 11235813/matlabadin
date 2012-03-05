using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public class Choice<TState>
    {
        public static Choice<TState> CreateChoice(
            GraphParameters<TState> gp,
            IStateManager<TState> sm,
            TState state,
            Ability a,
            int stepsDuration,
            double[] pr)
        {
            if (pr == null) throw new ArgumentNullException("pr");
            // TODO: fix design flaw: buff tracking is broken for WB as the uptime depends on
            // whether WB hit or not.
            Choice<TState> c = new Choice<TState>(
                a,
                stepsDuration,
                pr,
                sm.HP(state),
                a == Ability.WoG && sm.TimeRemaining(state, Buff.SS) > 0,
                sm.TimeRemaining(state, Buff.SS),
                sm.TimeRemaining(state, Buff.EF),
                sm.TimeRemaining(state, Buff.WB),
                sm.TimeRemaining(state, Buff.SotRSB)
                );
            return c;
        }
        private Choice(
            Ability ability,
            int stepsDuration,
            double[] pr,
            int hp,
            bool wogss,
            int ssRemaining,
            int efRemaining,
            int wbRemaining,
            int sbRemaining
            )
        {
            this.ability = ability;
            this.hp = hp;
            this.wogss = wogss;
            this.stepsDuration = stepsDuration;
            this.ssDuration = Math.Min(ssRemaining, stepsDuration);
            this.efDuration = Math.Min(efRemaining, stepsDuration);
            this.wbDuration = Math.Min(wbRemaining, stepsDuration);
            this.sbDuration = Math.Min(ssRemaining, stepsDuration);
            this.pr = pr;
        }
        // Output related
        public string Action
        {
            get
            {
                if (action == null)
                {
                    action = ability.ToString();
                    if (hp < 3 && (ability == Ability.WoG || ability == Ability.EF)) {
                        action += hp.ToString();
                    }
                    if (wogss) action += "(SS)";
                }
                return action;
            }
        }
        public Ability Ability { get { return this.ability; } }
        private string action;
        private readonly Ability ability;
        private readonly bool wogss;
        private readonly int hp;
        // aggregation stats
        public readonly int ssDuration;
        public readonly int efDuration;
        public readonly int wbDuration;
        public readonly int sbDuration;
        public readonly int stepsDuration;
        // transition likelyhoods
        public readonly double[] pr;
        public override bool Equals(object obj)
        {
            if (obj is Choice<TState>) return Equals((Choice<TState>)obj);
            return base.Equals(obj);
        }
        public bool Equals(Choice<TState> c)
        {
            return ability == c.ability
                && wogss == c.wogss
                && ssDuration == c.ssDuration
                && efDuration == c.efDuration
                && wbDuration == c.wbDuration
                && sbDuration == c.sbDuration
                && hp == c.hp
                && stepsDuration == c.stepsDuration
                && pr.SequenceEqual(c.pr);
        }
        public override int GetHashCode()
        {
            int hash = pr.Aggregate(0, (h, p) => h ^ p.GetHashCode());
            hash ^= stepsDuration.GetHashCode(); // assuming ~< 7 bits
            hash ^= (ssDuration + efDuration) + (30 * wbDuration + 30 * 30 * sbDuration) << 7; // 9 bits
            hash ^= hp << (7 + 9);
            if (wogss) hash ^= 1 << (7 + 9 + 3);
            hash += (int)ability << (7 + 9 + 3 + 1);
            return hash;
        }
        /// <summary>
        /// Peforms the current choice, then the given choice
        /// </summary>
        /// <param name="choice">Choice to perform after current choice</param>
        /// <returns></returns>
        public Choice<TState> Concatenate(Choice<TState> choice)
        {
            if (this.Ability != Ability.Nothing)
            {
                throw new InvalidOperationException("Can only concatenate to an Ability.Nothing state");
            }
            if (this.pr.Length != 1)
            {
                throw new InvalidOperationException("Cannot concatenate to a choice that has multiple next states");
            }
            return new Choice<TState>(
                choice.Ability,
                this.stepsDuration + choice.stepsDuration,
                choice.pr,
                choice.hp,
                choice.wogss,
                this.ssDuration + choice.ssDuration,
                this.efDuration + choice.efDuration,
                this.wbDuration + choice.wbDuration,
                this.sbDuration + choice.sbDuration
                );
        }
    }
}
