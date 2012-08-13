﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public class GraphParameters<TState>
    {
        private static readonly bool[] DefaultIsOnGcd = new bool[] {
                false, false, false, // Nothing, SotR, WoG,
                false, true, true, // EF, SS, FoL,
                true, true, // HotR, CooldownIndicator, 
                true, true, true, true, // CS, J, HoW, AS, 
                true, true, false, // Cons, HW, AW,
                true, true, true, // HPr, LH, ES,
                false, // HA
                true, // Count
            };
        private static readonly double[] DefaultUnhastedAbilityDuration = new double[] {
                4.5, 6, 6, 15, // CS, J, HoW, AS,
                9, 9, 180, // Cons, HW, AW,
                20, 60, 60, // HPr, LH, ES,
                120, // HA
            };
        private static readonly bool[] AbilityCooldownReducedByHaste = new bool[] {
                true, true, true, true, // CS, J, HoW, AS,
                true, true, false, // Cons, HW, AW,
                false, false, false, // HPr, LH, ES
                false, // HA
            };
        private static readonly double[] DefaultUnhastedBuffDuration = new double[] {
                1.5, 30, 30, // GCD, EF, SS,
                20, 3, 30, // AW, SotRSB, WB,
                6.3, 15, 20, 8, // GC, SH, BoG, DP
                15, 9, // HA, GoWoG
            };
        private static readonly int[] DefaultMaximumBuffStacks = new int[] {
                1, 1, 1,
                1, 1, 1,
                1, 3, 5, 1,
                1, 3,
            };

        // constructor, does some simple sanity testing and calculates haste-effected GCD/CDs
        public GraphParameters(
            RotationPriorityQueue<TState> rotation,
            PaladinSpec spec = PaladinSpec.Prot,
            PaladinTalents talents = PaladinTalents.None,
            PaladinGlyphs glyphs = PaladinGlyphs.None,
            int stepsPerHastedGcd = 3,
            double haste = 0.0,
            double mehit = 1.0,
            double sphit = 1.0,
            Buff[] permanentBuffs = null
            )
        {
            // sanity checks inputs
            if (spec == PaladinSpec.Holy) throw new NotImplementedException("No plans to implement Holy");
            if (spec == PaladinSpec.Ret) throw new NotImplementedException("Ret NYI. See http://code.google.com/p/matlabadin/issues/list for status and priority");
            if (haste > 0.5) throw new NotImplementedException("GCD clipping from >50% haste not yet implemented");
            
            this.Warnings = "";

            // sanity check rotation with abilities
            if (rotation.AbilitiesUsed.Contains(Ability.HPr) && !talents.Includes(PaladinTalents.HolyPrism)) this.Warnings += String.Format("Rotation contains {0} without {1}; ", Ability.HPr, PaladinTalents.HolyPrism);
            if (rotation.AbilitiesUsed.Contains(Ability.LH) && !talents.Includes(PaladinTalents.LightsHammer)) this.Warnings += String.Format("Rotation contains {0} without {1}; ", Ability.LH, PaladinTalents.LightsHammer); ;
            if (rotation.AbilitiesUsed.Contains(Ability.ES) && !talents.Includes(PaladinTalents.ExecutionSentence)) this.Warnings += String.Format("Rotation contains {0} without {1}; ", Ability.ES, PaladinTalents.ExecutionSentence); ;
            if (rotation.AbilitiesUsed.Contains(Ability.HA) && !talents.Includes(PaladinTalents.HolyAvenger)) this.Warnings += String.Format("Rotation contains {0} without {1}; ", Ability.HA, PaladinTalents.HolyAvenger); ;
            if (rotation.AbilitiesUsed.Contains(Ability.SS) && !talents.Includes(PaladinTalents.SacredShield)) this.Warnings += String.Format("Rotation contains {0} without {1}; ", Ability.SS, PaladinTalents.SacredShield); ;
            if (rotation.AbilitiesUsed.Contains(Ability.EF) && !talents.Includes(PaladinTalents.EternalFlame)) this.Warnings += String.Format("Rotation contains {0} without {1}; ", Ability.EF, PaladinTalents.EternalFlame); ;

            // Sanity check talents:

            // sanity check on L45 and L90 talents - make sure no more than one of each is used in the rotation
            if (talents.CountAtLevel(15) > 1) this.Warnings += String.Format("Rotation contains more than one L{0} talent; ", 15);
            if (talents.CountAtLevel(30) > 1) this.Warnings += String.Format("Rotation contains more than one L{0} talent; ", 30);
            if (talents.CountAtLevel(45) > 1) this.Warnings += String.Format("Rotation contains more than one L{0} talent; ", 45);
            if (talents.CountAtLevel(60) > 1) this.Warnings += String.Format("Rotation contains more than one L{0} talent; ", 60);
            if (talents.CountAtLevel(75) > 1) this.Warnings += String.Format("Rotation contains more than one L{0} talent; ", 75);
            if (talents.CountAtLevel(90) > 1) this.Warnings += String.Format("Rotation contains more than one L{0} talent; ", 90);

            // commence construction
            this.Rotation = rotation;
            this.Spec = spec;
            this.Talents = talents;
            this.Glyphs = glyphs;
            this.StepsPerHastedGcd = stepsPerHastedGcd;
            this.Haste = haste;
            this.MeleeHit = mehit;
            this.RangedHit = sphit;
            this.PermanentBuffs = (permanentBuffs ?? new Buff[0]).OrderBy(x => (int)x).Distinct().ToArray();

            // set unhasted buff durations, account for talents and glyphs
            double[] talentedUnhastedBuffDuration = DefaultUnhastedBuffDuration.ToArray();
            if (this.Talents.Includes(PaladinTalents.SanctifiedWrath)) talentedUnhastedBuffDuration[(int)Buff.AW] = 30;
            if (this.Glyphs.Includes(PaladinGlyphs.GoHotR)) talentedUnhastedBuffDuration[(int)Buff.WB] *= 1.5; // 50% longer

            this.stepDuration = 1.5 / (this.StepsPerHastedGcd * (1.0 + haste));
            this.isOnGcd = DefaultIsOnGcd;
            this.abilitySteps = DefaultUnhastedAbilityDuration
                .Select((cd, i) => CalculateAbilityCooldowns(i + Ability.CooldownIndicator + 1, AbilityCooldownReducedByHaste[i], cd))
                .ToArray();
            this.buffSteps = talentedUnhastedBuffDuration
                .Select((cd, i) => CalculateBuffDuration((Buff)i, cd))
                .ToArray();
            this.buffStacks = DefaultMaximumBuffStacks;
            this.minBuffDuration = DefaultUnhastedBuffDuration.Select((s, i) => this.PermanentBuffs.Contains((Buff)i) ? StepsPerHastedGcd : 0).ToArray();
        }

        // This function calculates the ability cooldowns (in steps) after Sanctity of Battle
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
                case Buff.BoG:
                    if (!this.Rotation.AbilitiesUsed.Contains(Ability.SotR)) return 0;
                    break;
                case Buff.DP:
                    if (!this.Talents.Includes(PaladinTalents.DivinePurpose)) return 0;
                    if (!(this.Rotation.AbilitiesUsed.Contains(Ability.SotR) || this.Rotation.AbilitiesUsed.Contains(Ability.WoG) || this.Rotation.AbilitiesUsed.Contains(Ability.EF))) return 0;
                    break;
                case Buff.HA:
                    //if (!this.Talents.Includes(PaladinTalents.HolyAvenger)) return 0;  //interferes with queue-based talenting - i.e. leaving L75 talent blank and choosing based on queue.
                    if (!this.Rotation.AbilitiesUsed.Contains(Ability.HA)) return 0;
                    break;
                case Buff.GoWoG:
                    if (!this.Glyphs.Includes(PaladinGlyphs.GoWoG)) return 0;
                    if (!this.Rotation.AbilitiesUsed.Contains(Ability.WoG) && !this.Rotation.AbilitiesUsed.Contains(Ability.EF)) return 0;
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

        // generic function to convert duration in seconds into steps, logs approximations
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
                this.Warnings += String.Format("{0}s duration approximated to {1}s ({2} steps);",
                    unhastedDurationInSeconds,
                    System.Math.Round(rounded * this.stepDuration, 4),
                    rounded
                );
            }
            return (int)rounded;
        }

        // these are mostly self-explanatory
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
            if (this.buffSteps[(int)buff] == 0 && this.minBuffDuration[(int)buff] != 0) return 0;
            return this.buffStacks[(int)buff];
        }
        public bool CanStack(Buff buff)
        {
            return (buff == Buff.SH || buff == Buff.BoG);
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
                this.RangedHit);
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
                && this.Glyphs == gp.Glyphs
                && this.StepsPerHastedGcd == gp.StepsPerHastedGcd
                && this.Haste == gp.Haste
                && hitGeneratesSameShape(this.MeleeHit, gp.MeleeHit)
                && hitGeneratesSameShape(this.RangedHit, gp.RangedHit)
                && this.PermanentBuffs.SequenceEqual(gp.PermanentBuffs);
        }
        private bool hitGeneratesSameShape(double hit1, double hit2)
        {
            // match if they are both 1.0 (or 0.0) or if they are both between 0.0 and 1.0 exclusive
            return !(hit1 == 1.0 ^ hit2 == 1.0) && !(hit1 == 0.0 ^ hit2 == 0.0);
        }
        public double GrandCrusaderProcRate { get { return this.Spec == PaladinSpec.Prot ? 0.2 : 0.0; } }
        public double DivinePurposeProcRate { get { return this.Talents.Includes(PaladinTalents.DivinePurpose) ? 0.25 : 0.0; } }
        public double StepDuration { get { return stepDuration; } }
        /// <summary>
        /// Human-readable output of any errors resulting in inexact graph parameters
        /// </summary>
        public string Warnings { get; private set; }
        #region parameters
        public RotationPriorityQueue<TState> Rotation { get; private set; }
        public PaladinTalents Talents { get; private set; }
        public PaladinGlyphs Glyphs { get; private set; }
        public PaladinSpec Spec { get; private set; }
        public int StepsPerHastedGcd { get; private set; }
        public double Haste { get; private set; }
        public double MeleeHit { get; private set; }
        public double RangedHit { get; private set; }
        public Buff[] PermanentBuffs { get; private set; }
        #endregion
        private readonly int[] abilitySteps;
        private readonly int[] buffSteps;
        private readonly int[] buffStacks;
        private readonly bool[] isOnGcd;
        private readonly double stepDuration;
        /// <summary>
        /// Minimum duration of buff
        /// </summary>
        /// <remarks>Only non-zero if the buff is a <see cref="PermanentBuffs"/></remarks>
        protected readonly int[] minBuffDuration;
    }
}
