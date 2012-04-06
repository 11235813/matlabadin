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
            PaladinSpec spec = PaladinSpec.Prot,
            PaladinTalents talents = PaladinTalents.None,
            double haste = 0.0,
            double mehit = 1.0,
            double sphit = 1.0
            )
        {
            if (spec == PaladinSpec.Holy) throw new NotImplementedException("No plans to implement Holy");
            if (spec == PaladinSpec.Ret) throw new NotImplementedException("Ret NYI. See http://code.google.com/p/matlabadin/issues/list for status and priority");
            if ((talents & PaladinTalents.SpeedOfLight) != PaladinTalents.None) throw new NotImplementedException("SpeedOfLight NYI");
            if ((talents & PaladinTalents.LongArmOfTheLaw) != PaladinTalents.None) throw new NotImplementedException("LongArmOfTheLaw NYI");
            if ((talents & PaladinTalents.PursuitOfJustice) != PaladinTalents.None) throw new NotImplementedException("PursuitOfJustice NYI");
            if ((talents & PaladinTalents.FistOfJustice) != PaladinTalents.None) throw new NotImplementedException("FistOfJustice NYI");
            if ((talents & PaladinTalents.Repentance) != PaladinTalents.None) throw new NotImplementedException("Repentance NYI");
            if ((talents & PaladinTalents.BurdenOfGuilt) != PaladinTalents.None) throw new NotImplementedException("BurdenOfGuilt NYI");
            if ((talents & PaladinTalents.HandOfPurity) != PaladinTalents.None) throw new NotImplementedException("HandOfPurity NYI");
            if ((talents & PaladinTalents.UnbreakableSpirit) != PaladinTalents.None) throw new NotImplementedException("UnbreakableSpirit NYI");
            if ((talents & PaladinTalents.Clemency) != PaladinTalents.None) throw new NotImplementedException("Clemency NYI");
            if ((talents & PaladinTalents.HolyAvenger) != PaladinTalents.None) throw new NotImplementedException("HolyAvenger NYI");
            if ((talents & PaladinTalents.SanctifiedWrath) != PaladinTalents.None) throw new NotImplementedException("SanctifiedWrath NYI");
            if ((talents & PaladinTalents.DivinePurpose) != PaladinTalents.None) throw new NotImplementedException("DivinePurpose NYI");
            if ((talents & PaladinTalents.HolyPrism) != PaladinTalents.None) throw new NotImplementedException("HolyPrism NYI");
            if ((talents & PaladinTalents.LightsHammer) != PaladinTalents.None) throw new NotImplementedException("LightsHammer NYI");
            if ((talents & PaladinTalents.ExecutionSentence) != PaladinTalents.None) throw new NotImplementedException("ExecutionSentence NYI");

            if (rotation.AbilitiesUsed.Contains(Ability.EF) && (talents & PaladinTalents.EternalFlame) == PaladinTalents.None) throw new ArgumentException("Rotation contains ability not talented");
            if (rotation.AbilitiesUsed.Contains(Ability.SS) && (talents & PaladinTalents.SacredShield) == PaladinTalents.None) throw new ArgumentException("Rotation contains ability not talented");

            this.Rotation = rotation;
            this.StepsPerGcd = stepsPerGcd;
            this.Spec = spec;
            this.Talents = talents;
            this.Haste = haste;
            this.MeleeHit = mehit;
            this.SpellHit = sphit;

            this.StepDuration = 1.5 / stepsPerGcd;            
            this.abilitySteps = new double[] {
                4.5, 6, 15, // CS, J, AS,
                9, 9, 180, // Cons, HW, AW,
            }.Select(cd => (int)Math.Ceiling(cd * stepsPerGcd / 1.5)).ToArray();
            this.onGcd = new bool[] {
                false, false, false, // Nothing, SotR, WoG,
                false, false, true, // EF, SS, FoL,
                true, true, // HotR, CooldownIndicator, 
                true, true, true, // CS, J, AS, 
                true, true, false, // Cons, HW, AW,
                true, // Count
            };
            // GC buff duration extended by 0.5s since the server takes time to apply the buff and it is active 4 GCDs after triggering
            this.buffSteps = new double[] {
                1.5, 30, 30, // GCD, EF, SS,
                20, 6, 30, // AW, SotRSB, WB,
                6.5, 15, // GC, SH, 
            }.Select(cd => (int)Math.Ceiling(cd * stepsPerGcd / 1.5)).ToArray();
            this.buffStacks = new int[] {
                1, 1, 1,
                1, 1, 1,
                1, 2,
            };
        }
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
                && this.Spec == gp.Spec
                && this.Talents == gp.Talents
                && this.Haste == gp.Haste
                && hitGeneratesSameShape(this.MeleeHit, gp.MeleeHit)
                && hitGeneratesSameShape(this.SpellHit, gp.SpellHit);
        }
        private bool hitGeneratesSameShape(double hit1, double hit2)
        {
            // match if they are both 1.0 (or 0.0) or if they are both between 0.0 and 1.0 exclusive
            return !(hit1 == 1.0 ^ hit2 == 1.0) && !(hit1 == 0.0 ^ hit2 == 0.0);
        }
        public double GrandCrusaderProcRate { get { return this.Spec == PaladinSpec.Prot ? 0.2 : 0.0; } }
        public int HastedGcdSteps { get { throw new NotImplementedException(); } }
        public double StepDuration { get; private set; }
        #region parameters
        public RotationPriorityQueue<TState> Rotation { get; private set; }
        public PaladinTalents Talents { get; private set; }
        public PaladinSpec Spec { get; private set; }
        public double Haste { get; private set; }
        public int StepsPerGcd { get; private set; }
        public double MeleeHit { get; private set; }
        public double SpellHit { get; private set; }
        #endregion
        private readonly int[] abilitySteps;
        private readonly int[] buffSteps;
        private readonly int[] buffStacks;
        private readonly bool[] onGcd;
    }
}
