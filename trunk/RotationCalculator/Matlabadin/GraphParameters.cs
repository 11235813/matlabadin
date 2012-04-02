using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public class GraphParameters<TState>
    {
        public GraphParameters(
            RotationPriorityQueue<TState> rotation,
            int stepsPerGcd,
            double mehit,
            double sphit,
            bool selflessHealer = false
            )
        {
            double[] abilityCooldowns = {
                4.5, 6, 15, // CS, J, AS,
                9, 9, 180, // Cons, HW, AW,
            };
            this.onGcd = new bool[] {
                false, false, false, // Nothing, SotR, WoG,
                false, false, true, // EF, SS, FoL,
                true, true, // HotR, CooldownIndicator, 
                true, true, true, // CS, J, AS, 
                true, true, false, // Cons, HW, AW,
                true, // Count
            };
            // GC buff duration extended by 0.5s since the server takes time to apply the buff and it is active 4 GCDs after triggering
            double[] buffDurations = {
                1.5, 30, 30, // GCD, EF, SS,
                20, 6, 30, // AW, SotRSB, WB,
                6.5, 15, // GC, SH,
            };
            this.buffStacks = new int[] {
                1, 1, 1,
                1, 1, 1,
                1, 2,
            };
            this.StepDuration = 1.5 / stepsPerGcd;
            this.StepsPerGcd = stepsPerGcd;
            this.abilitySteps = abilityCooldowns.Select(cd => (int)Math.Ceiling(cd * stepsPerGcd / 1.5)).ToArray();
            this.buffSteps = buffDurations.Select(cd => (int)Math.Ceiling(cd * stepsPerGcd / 1.5)).ToArray();
            this.MeleeHit = mehit;
            this.SpellHit = sphit;
            this.SelflessHealer = selflessHealer;
            this.Rotation = rotation;
            
        }
        public double StepDuration { get; private set; }
        public int StepsPerGcd { get; private set; }
        public double GCProcRate { get { return 0.2; } }
        public bool AbilityOnGcd(Ability ability)
        {
            return this.onGcd[(int)ability];
        }
        public bool AbilityTriggersGcd(Ability ability)
        {
            return AbilityOnGcd(ability);
        }
        public int GcdDurationTriggeredByAbilityInSteps(Ability ability)
        {
            if (AbilityTriggersGcd(ability)) return this.BuffDurationInSteps(Buff.GCD);
            else return 0;
        }
        public int AbilityCooldownInSteps(Ability ability)
        {
            if (ability == Ability.HotR) return AbilityCooldownInSteps(Ability.CS);
            if (ability <= Ability.CooldownIndicator) return 0;
            return abilitySteps[(int)ability - (int)Ability.CooldownIndicator - 1];
        }
        public int MaxBuffStacks(Buff buff)
        {
            return this.buffStacks[(int)buff];
        }
        public bool CanStack(Buff buff)
        {
            return buff == Buff.SH;
        }
        /// <summary>
        /// Returns the time it takes for an ability to be used.
        /// </summary>
        /// <param name="ability"></param>
        /// <returns></returns>
        public int AbilityCastTimeInSteps(Ability ability)
        {
            switch (ability)
            {
                case Ability.Nothing:
                    // single step advance
                    return 1;
                default:
                    return 0;
            }
        }
        public int BuffDurationInSteps(Buff buff)
        {
            return buffSteps[(int)buff];
        }
        public bool HasSameShape(GraphParameters<TState> gp)
        {
            return this.Rotation.PriorityQueue == gp.Rotation.PriorityQueue
                && this.StepsPerGcd == gp.StepsPerGcd
                && hitGeneratesSameShape(this.MeleeHit, gp.MeleeHit)
                && hitGeneratesSameShape(this.SpellHit, gp.SpellHit)
                && this.SelflessHealer == gp.SelflessHealer;
        }
        private bool hitGeneratesSameShape(double hit1, double hit2)
        {
            // match if they are both 1.0 (or 0.0) or if they are both between 0.0 and 1.0 exclusive
            return !(hit1 == 1.0 ^ hit2 == 1.0) && !(hit1 == 0.0 ^ hit2 == 0.0);
        }
        public double MeleeHit { get; private set; }
        public double SpellHit { get; private set; }
        public bool SelflessHealer { get; private set; }
        public RotationPriorityQueue<TState> Rotation { get; private set; }
        private readonly int[] abilitySteps;
        private readonly int[] buffSteps;
        private readonly int[] buffStacks;
        private readonly bool[] onGcd;
    }
}
