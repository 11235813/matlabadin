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
            bool useConsGlyph,
            double mehit,
            double rhit,
            double sdProcRate,
            double gcProcRate,
            double egProcRate,
            bool hpOnJudgement)
        {
            double[] abilityCooldowns = {20, 3, 8, 15, useConsGlyph ? 30 * 1.2 : 30, 15, 6}; // WoG,CS,J,AS,Cons,HW,HoW,
            // GC buff duration extended by 0.5s since the server takes time to apply the buff and it is active 4 GCDs after triggering
            double[] buffDurations = { 6.5, 10, 12, 15, 10 }; // GC, SD, INQ, EGICD , JotW
            this.StepDuration = 1.5 / stepsPerGcd;
            this.StepsPerGcd = stepsPerGcd;
            this.abilitySteps = abilityCooldowns.Select(cd => (int)Math.Ceiling(cd * stepsPerGcd / 1.5)).ToArray();
            this.buffSteps = buffDurations.Select(cd => (int)Math.Ceiling(cd * stepsPerGcd / 1.5)).ToArray();
            this.UseConsGlyph = useConsGlyph;
            this.SDProcRate = sdProcRate;
            this.GCProcRate = gcProcRate;
            this.EGProcRate = egProcRate;
            this.MeleeHit = mehit;
            this.RangeHit = rhit;
            this.Rotation = rotation;
            this.HpOnJudgement = hpOnJudgement;
        }
        public double StepDuration { get; private set; }
        public int StepsPerGcd { get; private set; }
        public int AbilityCooldownInSteps(Ability ability)
        {
            if (ability == Ability.HotR) return AbilityCooldownInSteps(Ability.CS);
            if (ability <= Ability.CooldownIndicator) return 0;
            return abilitySteps[(int)ability - (int)Ability.CooldownIndicator - 1];
        }
        /// <summary>
        /// Returns the time it takes for an ability to be used.
        /// </summary>
        /// <param name="ability"></param>
        /// <returns></returns>
        public int AbilityCastTimeInSteps(Ability ability)
        {
            if (ability == Ability.Nothing) return 1; // single step
            return this.StepsPerGcd; // everything in prot is instant cast = 1 GCD
        }
        public int BuffDurationInSteps(Buff buff)
        {
            return buffSteps[(int)buff];
        }
        public bool HasSameShape(GraphParameters<TState> gp)
        {
            return this.Rotation.PriorityQueue == gp.Rotation.PriorityQueue
                && this.StepsPerGcd == gp.StepsPerGcd
                && this.UseConsGlyph == gp.UseConsGlyph
                && this.SDProcRate == gp.SDProcRate
                && this.GCProcRate == gp.GCProcRate
                && this.EGProcRate == gp.EGProcRate
                && this.HpOnJudgement == gp.HpOnJudgement
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
        public bool UseConsGlyph { get; private set; }
        public bool HpOnJudgement { get; private set; }
        public RotationPriorityQueue<TState> Rotation { get; private set; }
        private readonly int[] abilitySteps;
        private readonly int[] buffSteps;
    }
}
