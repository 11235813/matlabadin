using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public static class StateHelper<TState>
    {
        /// <summary>
        /// Calculates the set of next states after the next ability usage
        /// </summary>
        /// <remarks>Compresses Nothing->Nothing transitions to reduce state space since and thus convergence time.</remarks>
        public static Choice<TState> NextAbilityStates(
            GraphParameters<TState> gp,
            IStateManager<TState> sm,
            TState state,
            out TState[] nextState)
        {
            TState[] currentStates;
            Choice<TState> choice = NextStates(gp, sm, state, gp.Rotation.ActionToTake(gp, sm, state), out currentStates);

            // reduce the state space by merging consecutive Ability.Nothing states
            while (choice.Ability == Ability.Nothing
                && currentStates.Length == 1
                && gp.Rotation.ActionToTake(gp, sm, currentStates[0]) == Ability.Nothing
                // Edge case: Loop of Nothing. Will not occur in sane rotations so we'll hack in simple check
                // ignore degerate case where we do Nothing with everything off CD
                && !sm.ZeroCooldownRemainingForAllAbilities(currentStates[0]))
            {
                // only one next state and we're doing nothing: just merge the two states together
                choice = choice.Concatenate(NextStates(gp, sm, currentStates[0], Ability.Nothing, out currentStates));
            }
            nextState = currentStates;
            return choice;
        }
        public static Choice<TState> NextStates(
            GraphParameters<TState> gp,
            IStateManager<TState> sm,
            TState state,
            Ability a,
            out TState[] nextState)
        {
            int waitSteps = sm.CooldownRemaining(state, a);
            double[] pr = null;
            switch (a)
            {
                case Ability.J:
                    nextState = new TState[]
                    {
                        UseAbility(gp, sm, state, a, waitSteps),
                        UseAbility(gp, sm, state, a, waitSteps, sdProc: true), // sd
                    };
                    double jSDProcPr = gp.RangeHit * gp.SDProcRate;
                    pr = new double[]
                    {
                        1 - jSDProcPr,
                        jSDProcPr,
                    };
                    break;
                case Ability.AS:
                    nextState = new TState[]
                    {
                        UseAbility(gp, sm, state, a, waitSteps, false), // miss
                        UseAbility(gp, sm, state, a, waitSteps, true), // hit, no proc
                        UseAbility(gp, sm, state, a, waitSteps, true, sdProc: true), // sd
                    };
                    double asSDProcPr = gp.RangeHit * gp.SDProcRate;
                    pr = new double[]
                    {
                        1 - gp.RangeHit,
                        1 - (1 - gp.RangeHit + asSDProcPr),
                        asSDProcPr,
                    };
                    break;
                case Ability.HotR:
                case Ability.CS:
                    nextState = new TState[]
                    {
                        UseAbility(gp, sm, state, a, waitSteps, false), // miss
                        UseAbility(gp, sm, state, a, waitSteps, true), // hit
                        UseAbility(gp, sm, state, a, waitSteps, true, gcProc: true), // gc
                    };
                    double gcProcPr = gp.MeleeHit * gp.GCProcRate;
                    pr = new double[]
                    {
                        1 - gp.MeleeHit,
                        1 - (1 - gp.MeleeHit + gcProcPr),
                        gcProcPr,
                    };
                    break;
                case Ability.SotR:
                    nextState = new TState[]
                    {
                        UseAbility(gp, sm, state, a, waitSteps, false), // miss
                        UseAbility(gp, sm, state, a, waitSteps, true), // hit
                    };
                    pr = new double[]
                    {
                        1 - gp.MeleeHit,
                        gp.MeleeHit,
                    };
                    break;
                case Ability.WoG:
                    nextState = new TState[]
                    {
                        UseAbility(gp, sm, state, a, waitSteps),
                        UseAbility(gp, sm, state, a, waitSteps, egProc: true),
                    };
                    double egProcPr = sm.TimeRemaining(state, Buff.EGICD) > 0 ? 0 : gp.EGProcRate;
                    pr = new double[]
                    {
                        1 - egProcPr,
                        egProcPr,
                    };
                    break;
                case Ability.Cons:
                case Ability.HW:
                case Ability.Inq:
                case Ability.HoW:
                case Ability.Nothing:
                    // Only one state transition for these
                    nextState = new TState[]
                    {
                        UseAbility(gp, sm, state, a, waitSteps),
                    };
                    pr = new double[]
                    {
                        1,
                    };
                    break;
                default:
                    throw new ArgumentException(String.Format("Unknown ability {0}", a));
            }
            // cull zero probability transitions
            CullZeroProbabilityTransitions(ref nextState, ref pr);
            return Choice<TState>.CreateChoice(gp, sm, state, a, waitSteps + gp.AbilityCastTimeInSteps(a), pr);
        }
        private static void CullZeroProbabilityTransitions(ref TState[] nextState, ref double[] pr)
        {
            int zeroes = pr.Count(p => p == 0);
            if (zeroes != 0)
            {
                int nonZeroCount = nextState.Length - zeroes;
                TState[] rawNextState = nextState;
                double[] rawPr = pr;
                nextState = new TState[nonZeroCount];
                pr = new double[nonZeroCount];
                int offset = 0;
                for (int i = 0; i < rawNextState.Length; i++)
                {
                    if (rawPr[i] != 0)
                    {
                        nextState[offset] = rawNextState[i];
                        pr[offset] = rawPr[i];
                        offset++;
                    }
                }
            }
        }
        public static TState UseAbility(
            GraphParameters<TState> gp,
            IStateManager<TState> sm,
            TState state,
            Ability ability,
            int waitSteps = 0,
            bool hit = true,
            bool sdProc = false,
            bool gcProc = false,
            bool egProc = false)
        {
            //if (state == UInt64.MaxValue) throw new ArgumentException("Invalid state");
            if (ability == Ability.HotR) return UseAbility(gp, sm, state, Ability.CS, waitSteps, hit, sdProc, gcProc, egProc);
            TState nextState = state;
            if (waitSteps > 0)
            {
                nextState = sm.AdvanceTime(nextState, waitSteps);
            }
            if (sm.CooldownRemaining(state, ability) > 0) throw new InvalidOperationException("Attempting to use ability still on cooldown");
            int abilityCooldown = gp.AbilityCooldownInSteps(ability);
            if (abilityCooldown > 0)
            {
                nextState = sm.SetCooldownRemaining(nextState, ability, abilityCooldown);
            }
            switch (ability)
            {
                case Ability.WoG:
                    nextState = sm.SetHP(nextState, 0);
                    break;
                case Ability.SotR:
                    if (hit)
                    {
                        nextState = sm.SetHP(nextState, 0);
                        nextState = sm.SetTimeRemaining(nextState, Buff.SD, 0);
                    }
                    break;
                case Ability.CS:
                    if (hit) nextState = sm.IncHP(nextState);
                    break;
                case Ability.AS:
                    if (sm.TimeRemaining(nextState, Buff.GC) > 0) // GC HP is on cast
                    {
                        nextState = sm.IncHP(nextState);
                    }
                    nextState = sm.SetTimeRemaining(nextState, Buff.GC, 0);
                    break;
                case Ability.Inq:
                    nextState = sm.SetTimeRemaining(nextState, Buff.Inq, sm.HP(nextState) * gp.BuffDurationInSteps(Buff.Inq) / 3);
                    nextState = sm.SetHP(nextState, 0);
                    break;
                case Ability.J:
                    // 4.2: JotW triggered by J cast not J landing
                    nextState = sm.SetTimeRemaining(nextState, Buff.JotW, gp.BuffDurationInSteps(Buff.JotW));
                    if (gp.HpOnJudgement)
                    {
                        // TODO: test if HP is granted on cast or landing
                        nextState = sm.IncHP(nextState); // on cast
                        // if (hit) nextState = sm.IncHP(nextState); // on landing
                    }
                    break;
            }
            if (egProc)
            {
                nextState = sm.SetHP(nextState, sm.HP(state));
                nextState = sm.SetTimeRemaining(nextState, Buff.EGICD, gp.BuffDurationInSteps(Buff.EGICD));
            }
            if (gcProc)
            {
                nextState = sm.SetCooldownRemaining(nextState, Ability.AS, 0);
                nextState = sm.SetTimeRemaining(nextState, Buff.GC, gp.BuffDurationInSteps(Buff.GC));
            }
            if (sdProc)
            {
                nextState = sm.SetTimeRemaining(nextState, Buff.SD, gp.BuffDurationInSteps(Buff.SD));
            }
            // advance time
            nextState = sm.AdvanceTime(nextState, gp.AbilityCastTimeInSteps(ability));
            return nextState;
        }
        public static string StateToString(GraphParameters<TState> gp, IStateManager<TState> sm, TState state)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendFormat("HP{0}", sm.HP(state));
            string singleColumnNumberFormat = ",{1,1:#}";
            string doubleColumnNumberFormat = ",{1,2:##}";
            for (int offset = (int)Ability.CooldownIndicator + 1; offset < (int)Ability.Count; offset++)
            {
                sb.AppendFormat(gp.AbilityCooldownInSteps((Ability)offset) >= 10 ? doubleColumnNumberFormat : singleColumnNumberFormat,
                    (Ability)offset,
                    sm.CooldownRemaining(state, (Ability)offset));
            }
            sb.Append(",");
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                sb.AppendFormat(gp.BuffDurationInSteps((Buff)i) >= 10 ? doubleColumnNumberFormat : singleColumnNumberFormat,
                    (Buff)i,
                    sm.TimeRemaining(state, (Buff)i));
            }
            return sb.ToString();
        }
    }
}
