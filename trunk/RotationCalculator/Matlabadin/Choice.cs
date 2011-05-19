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
            // Special case Inquisition since we may not have inq up when we cast Inq but it's up as a buff for the duration of the casting GCD
            int inqLeft = sm.TimeRemaining(state, Buff.Inq);
            if (a == Ability.Inq && sm.HP(state) > 0) inqLeft += gp.StepsPerGcd; // add at least the GCD to the remaining duration
            Choice<TState> c = new Choice<TState>(a,
                a == Ability.SotR && sm.TimeRemaining(state, Buff.SD) > 0,
                inqLeft,
                sm.HP(state),
                stepsDuration,
                pr);
            return c;
        }
        private Choice(
            Ability ability,
            bool sotrsd,
            int inq,
            int hp,
            int stepsDuration,
            double[] pr)
        {
            this.ability = ability;
            this.hp = hp;
            this.sotrsd = sotrsd;
            this.stepsDuration = stepsDuration;
            this.inqDuration = Math.Min(inq, stepsDuration);
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
        public Ability Ability { get { return this.ability; } }
        private string action;
        private readonly Ability ability;
        private readonly bool sotrsd;
        private readonly int hp;
        // aggregation stats
        public readonly int inqDuration;
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
                && sotrsd == c.sotrsd
                && inqDuration == c.inqDuration
                && hp == c.hp
                && stepsDuration == c.stepsDuration
                && pr.SequenceEqual(c.pr);
        }
        public override int GetHashCode()
        {
            int hash = pr.Aggregate(0, (h, p) => h ^ p.GetHashCode());
            hash ^= stepsDuration.GetHashCode();
            hash ^= inqDuration << 7;
            hash ^= hp << 11;
            if (sotrsd) hash ^= 1 << 27;
            hash += (int)ability << 16;
            return hash;
        }
    }
}
