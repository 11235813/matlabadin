using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public static class StateHelper
    {
        public static Choice NextStates(
            ulong state,
            Ability a,
            GraphParameters gp,
            out ulong nextState1,
            out ulong nextState2,
            out ulong nextState3)
        {
            int waitSteps = StateHelper.CooldownRemaining(state, a, gp);
            double pr1 = 0;
            double pr2 = 0;
            double pr3 = 0;
            nextState1 = UInt64.MaxValue;
            nextState2 = UInt64.MaxValue;
            nextState3 = UInt64.MaxValue;
            switch (a)
            {
                case Ability.J:
                    nextState1 = StateHelper.UseAbility(state, gp, a, waitSteps);
                    nextState2 = StateHelper.UseAbility(state, gp, a, waitSteps, sdProc: true); // sd
                    pr2 = gp.RangeHit * gp.SDProcRate;
                    pr1 = 1 - pr2;
                    break;
                case Ability.AS:
                    nextState1 = StateHelper.UseAbility(state, gp, a, waitSteps, false); // miss
                    nextState2 = StateHelper.UseAbility(state, gp, a, waitSteps, true); // hit
                    nextState3 = StateHelper.UseAbility(state, gp, a, waitSteps, true, sdProc: true); // sd
                    pr3 = gp.RangeHit * gp.SDProcRate;
                    pr1 = 1 - gp.RangeHit;
                    pr2 = 1 - pr1 - pr3;
                    break;
                case Ability.HotR:
                case Ability.CS:
                    nextState1 = StateHelper.UseAbility(state, gp, a, waitSteps, false); // miss
                    nextState2 = StateHelper.UseAbility(state, gp, a, waitSteps, true); // hit
                    nextState3 = StateHelper.UseAbility(state, gp, a, waitSteps, true, gcProc: true); // gc
                    pr1 = 1 - gp.MeleeHit;
                    pr3 = gp.MeleeHit * gp.GCProcRate;
                    pr2 = 1 - pr1 - pr3;
                    break;
                case Ability.SotR:
                    nextState1 = StateHelper.UseAbility(state, gp, a, waitSteps, false); // miss
                    nextState2 = StateHelper.UseAbility(state, gp, a, waitSteps, true); // hit
                    pr1 = 1 - gp.MeleeHit;
                    pr2 = gp.MeleeHit;
                    break;
                case Ability.WoG:
                    nextState1 = StateHelper.UseAbility(state, gp, a, waitSteps);
                    nextState2 = StateHelper.UseAbility(state, gp, a, waitSteps, egProc: true);
                    pr2 = StateHelper.TimeRemaining(state, Buff.EGICD, gp) > 0 ? 0 : gp.EGProcRate; // only proc if EG off ICD
                    pr1 = 1 - pr2;
                    break;
                case Ability.Cons:
                case Ability.HW:
                case Ability.Inq:
                case Ability.HoW:
                case Ability.Nothing:
                    // Only one state transition for these
                    nextState1 = StateHelper.UseAbility(state, gp, a, waitSteps);
                    pr1 = 1;
                    break;
                default:
                    throw new ArgumentException(String.Format("Unknown ability {0}", a));
            }
            if (pr1 == 0) nextState1 = UInt64.MaxValue;
            if (pr2 == 0) nextState2 = UInt64.MaxValue;
            if (pr3 == 0) nextState3 = UInt64.MaxValue;
            return Choice.CreateChoice(state, gp, a, waitSteps + gp.StepsPerGcd, pr1, pr2, pr3);
        }
        /// <summary>
        /// Cooldown remaining on the given ability
        /// </summary>
        /// <param name="ability">Ability</param>
        /// <returns>Cooldown remaining in ms.</returns>
        public static int CooldownRemaining(ulong state, Ability ability, GraphParameters gp)
        {
            int numBits = gp.AbilityCooldownBits[(int)ability];
            if (numBits <= 0) return 0;
            return Unpack(state, gp.AbilityCooldownStartBit[(int)ability], gp.AbilityCooldownBits[(int)ability]);
        }
        /// <summary>
        /// Time remaining on the given buff.
        /// </summary>
        /// <param name="buff">Buff to check</param>
        /// <returns>Time remaining in ms.</returns>
        public static int TimeRemaining(ulong state, Buff buff, GraphParameters gp)
        {
            return Unpack(state, gp.BuffDurationStartBit[(int)buff], gp.BuffDurationBits[(int)buff]);
        }
        public static ulong SetTimeRemaining(ulong state, Buff buff, int value, GraphParameters gp)
        {
            return Pack(state, gp.BuffDurationStartBit[(int)buff], gp.BuffDurationBits[(int)buff], value);
        }
        public static int HP(ulong state, GraphParameters gp)
        {
            return Unpack(state, 0, 2);
        }
        public static ulong IncHP(ulong state, GraphParameters gp)
        {
            return SetHP(state, Math.Min(3, HP(state, gp)+1), gp);
        }
        public static ulong SetHP(ulong state, int hp, GraphParameters gp)
        {
            return Pack(state, 0, 2, hp);
        }
        public static ulong SetCooldownRemaining(ulong state, Ability ability, int cd, GraphParameters gp)
        {
            int numBits = gp.AbilityCooldownBits[(int)ability];
            if (numBits <= 0) return state;
            return Pack(state, gp.AbilityCooldownStartBit[(int)ability], gp.AbilityCooldownBits[(int)ability], cd);
        }
        public static ulong AdvanceTime(ulong state, int steps, GraphParameters gp)
        {
            for (int offset = (int)Ability.CooldownIndicator + 1; offset < (int)Ability.Count; offset++)
            {
                state = Pack(state, gp.AbilityCooldownStartBit[offset], gp.AbilityCooldownBits[offset],
                    Math.Max(0, Unpack(state, gp.AbilityCooldownStartBit[offset], gp.AbilityCooldownBits[offset]) - steps));
            }
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                state = Pack(state, gp.BuffDurationStartBit[i], gp.BuffDurationBits[i],
                    Math.Max(0, Unpack(state, gp.BuffDurationStartBit[i], gp.BuffDurationBits[i]) - steps));
            }
            return state;
        }
        public static ulong UseAbility(
            ulong state,
            GraphParameters gp,
            Ability ability,
            int waitSteps = 0,
            bool hit = true,
            bool sdProc = false,
            bool gcProc = false,
            bool egProc = false)
        {
            if (state == UInt64.MaxValue) throw new ArgumentException("Invalid state");
            if (ability == Ability.HotR) return UseAbility(state, gp, Ability.CS, waitSteps, hit, sdProc, gcProc, egProc);
            ulong nextState = state;
            if (waitSteps > 0)
            {
                nextState = StateHelper.AdvanceTime(nextState, waitSteps, gp);
            }
            if (StateHelper.CooldownRemaining(state, ability, gp) > 0) throw new InvalidOperationException("Attempting to use ability still on cooldown");
            int abilityCooldown = gp.AbilityCooldownInSteps(ability);
            if (abilityCooldown > 0)
            {
                nextState = StateHelper.SetCooldownRemaining(nextState, ability, abilityCooldown, gp);
            }
            switch (ability)
            {
                case Ability.WoG:
                    nextState = StateHelper.SetHP(nextState, 0, gp);
                    break;
                case Ability.SotR:
                    if (hit)
                    {
                        nextState = StateHelper.SetHP(nextState, 0, gp);
                        nextState = StateHelper.SetTimeRemaining(nextState, Buff.SD, 0, gp);
                    }
                    break;
                case Ability.CS:
                    if (hit) nextState = StateHelper.IncHP(nextState, gp);
                    break;
                case Ability.AS:
                    if (StateHelper.TimeRemaining(nextState, Buff.GC, gp) > 0) ///GC HP is on cast
                    {
                        nextState = StateHelper.IncHP(nextState, gp);
                    }
                    nextState = StateHelper.SetTimeRemaining(nextState, Buff.GC, 0, gp);
                    break;
                case Ability.Inq:
                    nextState = StateHelper.SetTimeRemaining(nextState, Buff.Inq, StateHelper.HP(nextState, gp) * gp.BuffDurationInSteps(Buff.Inq) / 3, gp);
                    nextState = StateHelper.SetHP(nextState, 0, gp);
                    break;
            }
            if (egProc)
            {
                nextState = StateHelper.SetHP(nextState, StateHelper.HP(state, gp), gp);
                nextState = StateHelper.SetTimeRemaining(nextState, Buff.EGICD, gp.BuffDurationInSteps(Buff.EGICD), gp);
            }
            if (gcProc)
            {
                nextState = StateHelper.SetCooldownRemaining(nextState, Ability.AS, 0, gp);
                nextState = StateHelper.SetTimeRemaining(nextState, Buff.GC, gp.BuffDurationInSteps(Buff.GC), gp);
            }
            if (sdProc)
            {
                nextState = StateHelper.SetTimeRemaining(nextState, Buff.SD, gp.BuffDurationInSteps(Buff.SD), gp);
            }
            // advance time a GCD
            nextState = StateHelper.AdvanceTime(nextState, gp.StepsPerGcd, gp);
            return nextState;
        }
        private static int Unpack(ulong state, int startBit, int numBits)
        {
            ulong shifted = (state >> startBit);
            ulong result = shifted & (ulong)~(-1 << numBits);
            return (int)result;
        }
        private static ulong Pack(ulong state, int startBit, int numBits, int value)
        {
            if (value >= 1 << numBits || value < 0) throw new ArgumentOutOfRangeException(String.Format("value {0} does not fit in {1} bits", value, numBits));
            ulong bitsToClear = ((ulong)~(-1 << numBits)) << startBit;
            state &= ~bitsToClear;
            state |= (ulong)value << startBit;
            return state;
        }
        public static string StateToString(ulong state, GraphParameters gp)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendFormat("HP{0}", StateHelper.HP(state, gp));
            string singleColumnNumberFormat = ",{1,1:#}";
            string doubleColumnNumberFormat = ",{1,2:##}";
            for (int offset = (int)Ability.CooldownIndicator + 1; offset < (int)Ability.Count; offset++)
            {
                sb.AppendFormat(gp.AbilityCooldownInSteps((Ability)offset) >= 10 ? doubleColumnNumberFormat : singleColumnNumberFormat,
                    (Ability)offset,
                    StateHelper.CooldownRemaining(state, (Ability)offset, gp));
            }
            sb.Append(",");
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                sb.AppendFormat(gp.BuffDurationInSteps((Buff)i) >= 10 ? doubleColumnNumberFormat : singleColumnNumberFormat,
                    (Buff)i,
                    StateHelper.TimeRemaining(state, (Buff)i, gp));
            }
            return sb.ToString();
        }
    }
}
