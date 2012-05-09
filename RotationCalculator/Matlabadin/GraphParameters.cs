using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public class GraphParameters<TState>
    {
        private static readonly bool[] DefaultIsOnGcd = new bool[] {
                false, false, false, // Nothing, SotR, WoG,
                false, false, true, // EF, SS, FoL,
                true, true, // HotR, CooldownIndicator, 
                true, true, true, true, // CS, J, HoW, AS, 
                true, true, false, // Cons, HW, AW,
                true, // Count
            };
        private static readonly double[] DefaultUnhastedAbilityDuration = new double[] {
                4.5, 6, 6, 15, // CS, J, HoW, AS,
                9, 9, 180, // Cons, HW, AW,
            };
        private static readonly bool[] AbilityCooldownReducedByHaste = new bool[] {
                true, true, true, false, // CS, J, HoW, AS,
                true, true, false, // Cons, HW, AW,
            };
        private static readonly double[] DefaultUnhastedBuffDuration = new double[] {
                1.5, 30, 30, // GCD, EF, SS,
                20, 3, 30, // AW, SotRSB, WB,
                6.3, 15, // GC, SH, 
            };
        private static readonly int[] DefaultMaximumBuffStacks = new int[] {
                1, 1, 1,
                1, 1, 1,
                1, 2,
            };
        public GraphParameters(
            RotationPriorityQueue<TState> rotation,
            PaladinSpec spec = PaladinSpec.Prot,
            PaladinTalents talents = PaladinTalents.None,
            int stepsPerHastedGcd = 3,
            double haste = 0.0,
            double mehit = 1.0,
            double sphit = 1.0
            )
        {
            if (spec == PaladinSpec.Holy) throw new NotImplementedException("No plans to implement Holy");
            if (spec == PaladinSpec.Ret) throw new NotImplementedException("Ret NYI. See http://code.google.com/p/matlabadin/issues/list for status and priority");
            if (haste > 0.5) throw new NotImplementedException("GCD clipping from >50% haste not yet implemented");
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
            this.Spec = spec;
            this.Talents = talents;
            this.StepsPerHastedGcd = stepsPerHastedGcd;
            this.Haste = haste;
            this.MeleeHit = mehit;
            this.SpellHit = sphit;

            this.ApproximationErrors = "";
            this.stepDuration = 1.5 / (this.StepsPerHastedGcd * (1.0 + haste));
            this.isOnGcd = DefaultIsOnGcd;
            this.abilitySteps = DefaultUnhastedAbilityDuration
                .Select((cd, i) => CalculateAbilityCooldowns(i + Ability.CooldownIndicator + 1, AbilityCooldownReducedByHaste[i], cd))
                .ToArray();
            this.buffSteps = DefaultUnhastedBuffDuration
                .Select((cd, i) => CalculateBuffDuration((Buff)i, cd))
                .ToArray();
            this.buffStacks = DefaultMaximumBuffStacks;
        }
        private int CalculateAbilityCooldowns(Ability ability, bool isAffectedByHaste, double baseCooldown)
        {
            if (!Rotation.AbilitiesUsed.Contains(ability) &&
                // don't remove CS if we have HotR
                !(ability == Ability.CS && Rotation.AbilitiesUsed.Contains(Ability.HotR)))
            {
                // Remove CDs of abilities that we do not use
                return 0;
            }
            return CalculateDurationInSteps(baseCooldown, isAffectedByHaste, x => (int)Math.Ceiling(x));
        }
        /// <remarks>
        /// The main purpose of this is to reduce state space size by filtering out buffs not used in this rotation
        /// </remarks>
        private int CalculateBuffDuration(Buff buff, double baseDuration)
        {
            switch (buff)
            {
                case Buff.GCD:
                    return this.StepsPerHastedGcd;
                case Buff.SS:
                    if (!this.Rotation.AbilitiesUsed.Contains(Ability.SS)) return 0;
                    break;
                case Buff.EF:
                    if (!this.Rotation.AbilitiesUsed.Contains(Ability.EF)) return 0;
                    break;
                case Buff.AW:
                    if (!this.Rotation.AbilitiesUsed.Contains(Ability.AW)) return 0;
                    break;
                case Buff.SotRSB:
                    if (!this.Rotation.AbilitiesUsed.Contains(Ability.SotR)) return 0;
                    break;
                case Buff.WB:
                    if (!this.Rotation.AbilitiesUsed.Contains(Ability.HotR)) return 0;
                    break;
                case Buff.GC:
                    if (this.Spec != PaladinSpec.Prot) return 0;
                    if (!(this.Rotation.AbilitiesUsed.Contains(Ability.HotR) || this.Rotation.AbilitiesUsed.Contains(Ability.CS))) return 0;
                    break;
                case Buff.SH:
                    if (!this.Rotation.AbilitiesUsed.Contains(Ability.J)) return 0;
                    if (!this.Talents.Includes(PaladinTalents.SelflessHealer)) return 0;
                    break;
                default:
                    // If we haven't modelling it, we keep it
                    throw new NotImplementedException("Parameter preconditions to triggering this buff must be specified in GraphParameters.CalculateBuffDuration()");
            }
            int stepsDuration = CalculateDurationInSteps(baseDuration, false, x => (int)Math.Floor(x));
            // GC buff duration extended by 1 step since the server takes time to apply the buff and is still active 6s after triggering
            if (buff == Buff.GC) stepsDuration++;
            return stepsDuration;
        }
        private int CalculateDurationInSteps(double unhastedDurationInSeconds, bool isAffectedByHaste, Func<double, int> roundingFunction)
        {
            double hastedDurationInSteps;
            if (isAffectedByHaste)
            {
                hastedDurationInSteps = this.StepsPerHastedGcd * unhastedDurationInSeconds / 1.5;
            }
            else
            {
                double unhastedDurationInSteps = this.StepsPerHastedGcd * unhastedDurationInSeconds / 1.5;
                hastedDurationInSteps = (1.0 + this.Haste) * unhastedDurationInSteps;
            }
            int rounded = roundingFunction(hastedDurationInSteps);
            if (hastedDurationInSteps != rounded)
            {
                this.ApproximationErrors += String.Format("{0}s duration approximated to {1}s ({2} steps);",
                    unhastedDurationInSeconds,
                    rounded * this.stepDuration,
                    rounded
                );
            }
            return (int)rounded;
        }
        public bool AbilityOnGcd(Ability ability)
        {
            return this.isOnGcd[(int)ability];
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
            if (this.buffSteps[(int)buff] == 0) return 0;
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
        public string ParametersToString()
        {
            return String.Format("{0} {1} {2} {3} {4} {5} {6}",
                this.Rotation.PriorityQueue,
                this.Spec,
                this.Talents.ToLongString(),
                this.StepsPerHastedGcd,
                this.Haste,
                this.MeleeHit,
                this.SpellHit);
        }
        public int BuffDurationInSteps(Buff buff)
        {
            return buffSteps[(int)buff];
        }
        public bool HasSameShape(GraphParameters<TState> gp)
        {
            return this.Rotation.PriorityQueue == gp.Rotation.PriorityQueue
                && this.Spec == gp.Spec
                && this.Talents == gp.Talents
                && this.StepsPerHastedGcd == gp.StepsPerHastedGcd
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
        public double StepDuration { get { return stepDuration; } }
        /// <summary>
        /// Human-readable output of any errors resulting in inexact graph parameters
        /// </summary>
        public string ApproximationErrors { get; private set; }
        #region parameters
        public RotationPriorityQueue<TState> Rotation { get; private set; }
        public PaladinTalents Talents { get; private set; }
        public PaladinSpec Spec { get; private set; }
        public int StepsPerHastedGcd { get; private set; }
        public double Haste { get; private set; }
        public double MeleeHit { get; private set; }
        public double SpellHit { get; private set; }
        #endregion
        private readonly int[] abilitySteps;
        private readonly int[] buffSteps;
        private readonly int[] buffStacks;
        private readonly bool[] isOnGcd;
        private readonly double stepDuration;
    }
}
