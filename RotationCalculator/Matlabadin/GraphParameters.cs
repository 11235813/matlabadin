﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public class GraphParameters
    {
        public GraphParameters(
            int stepsPerGcd,
            bool useConsGlyph,
            double mehit,
            double rhit,
            double sdProcRate,
            double gcProcRate,
            double egProcRate)
        {
            double[] abilityCooldowns = {20, 3, 8, 15, useConsGlyph ? 30 * 1.2 : 30, 15, 6}; // WoG,CS,J,AS,Cons,HW,HoW,
            double[] buffDurations = {6.5, 10, 12, 15}; //GC, SD, INQ, EGICD
            this.StepSize = 1.5 / stepsPerGcd;
            this.StepsPerGcd = stepsPerGcd;
            this.abilitySteps = abilityCooldowns.Select(cd => (int)Math.Ceiling(cd * stepsPerGcd / 1.5)).ToArray();
            this.buffSteps = buffDurations.Select(cd => (int)Math.Ceiling(cd * stepsPerGcd / 1.5)).ToArray();
            this.consGlyph = useConsGlyph;
            this.SDProcRate = sdProcRate;
            this.GCProcRate = gcProcRate;
            this.EGProcRate = egProcRate;
            this.MeleeHit = mehit;
            this.RangeHit = rhit;
            CalculateBitOffsets();
        }
        public double StepSize { get; private set; }
        public int StepsPerGcd { get; private set; }
        public int AbilityCooldownInSteps(Ability ability)
        {
            if (ability == Ability.HotR) return AbilityCooldownInSteps(Ability.CS);
            if (ability <= Ability.CooldownIndicator) return 0;
            return abilitySteps[(int)ability - (int)Ability.CooldownIndicator - 1];
        }
        public int BuffDurationInSteps(Buff buff)
        {
            return buffSteps[(int)buff];
        }
        public bool HasSameShape(GraphParameters gp)
        {
            return this.StepsPerGcd == gp.StepsPerGcd
                && this.consGlyph == gp.consGlyph
                && this.SDProcRate == gp.SDProcRate
                && this.GCProcRate == gp.GCProcRate
                && this.EGProcRate == gp.EGProcRate
                && hitGeneratesSameShape(this.MeleeHit, gp.MeleeHit)
                && hitGeneratesSameShape(this.RangeHit, gp.RangeHit);
        }
        private bool hitGeneratesSameShape(double hit1, double hit2)
        {
            // match if they are both 1.0 (or 0.0) or if they are both between 0.0 and 1.0 exclusive
            return !(hit1 == 1.0 ^ hit2 == 1.0) && !(hit1 == 0.0 ^ hit2 == 0.0);
        }
        public double MeleeHit { get; private set; }
        public double RangeHit { get; private set; }
        public double SDProcRate { get; private set; }
        public double GCProcRate { get; private set; }
        public double EGProcRate { get; private set; }
        private int[] abilitySteps;
        private int[] buffSteps;
        private bool consGlyph;
        #region Bit-Encoded State Graph Parameters
        /// <summary>
        /// Calculates the big packing required to encode the state in an unsigned 64 bit integer
        /// </summary>
        private void CalculateBitOffsets()
        {
            int bit = 2; // HP takes the first two bits
            AbilityCooldownStartBit = new int[(int)Ability.Count];
            AbilityCooldownBits = new int[(int)Ability.Count];
            for (int i = (int)Ability.CooldownIndicator + 1; i < (int)Ability.Count; i++)
            {
                //int i = offset - (int)Ability.CooldownIndicator - 1;
                AbilityCooldownStartBit[i] = bit;
                int cd = AbilityCooldownInSteps((Ability)i);
                while (1 << AbilityCooldownBits[i] <= cd) AbilityCooldownBits[i]++;
                bit += AbilityCooldownBits[i];
            }
            // CS & HotR shared CD
            AbilityCooldownStartBit[(int)Ability.HotR] = AbilityCooldownStartBit[(int)Ability.CS];
            AbilityCooldownBits[(int)Ability.HotR] = AbilityCooldownBits[(int)Ability.CS];

            BuffDurationStartBit = new int[buffSteps.Length];
            BuffDurationBits = new int[buffSteps.Length];
            for (int i = 0; i < buffSteps.Length; i++)
            {
                BuffDurationStartBit[i] = bit;
                int cd = BuffDurationInSteps((Buff)i);
                while (1 << BuffDurationBits[i] <= cd) BuffDurationBits[i]++;
                bit += BuffDurationBits[i];
            }
            if (bit > 64) throw new ArgumentOutOfRangeException("bit-encoded state space larger than 64 bit");
        }
        // should be read-only but direct access is given to improve StateHelper performance
        public int[] AbilityCooldownStartBit;
        public int[] AbilityCooldownBits;
        public int[] BuffDurationStartBit;
        public int[] BuffDurationBits;
        #endregion
    }
}
