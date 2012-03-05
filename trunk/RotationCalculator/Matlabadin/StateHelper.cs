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
                case Ability.HotR:
                case Ability.CS:
                    nextState = new TState[]
                    {
                        UseAbility(gp, sm, state, a, waitSteps, false), // miss
                        UseAbility(gp, sm, state, a, waitSteps, true), // hit
                        UseAbility(gp, sm, state, a, waitSteps, true, gcProc: true), // hit & gc
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
                case Ability.J:
                case Ability.AS:
                    nextState = new TState[]
                    {
                        UseAbility(gp, sm, state, a, waitSteps, false), // miss
                        UseAbility(gp, sm, state, a, waitSteps, true), // hit
                    };
                    pr = new double[]
                    {
                        1 - gp.RangeHit,
                        gp.RangeHit,
                    };
                    break;
                // Can't miss
                case Ability.Cons:
                case Ability.Nothing:
                case Ability.WoG:
                case Ability.EF:
                case Ability.SS:
                    nextState = new TState[]
                    {
                        UseAbility(gp, sm, state, a, waitSteps),
                    };
                    pr = new double[] { 1, };
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
            bool gcProc = false)
        {
            //if (state == UInt64.MaxValue) throw new ArgumentException("Invalid state");
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
            int hp = sm.HP(nextState);
            int availableHp = Math.Min(3, hp);
            switch (ability)
            {
                case Ability.WoG:
                    nextState = sm.SetHP(nextState, hp - availableHp);
                    break;
                case Ability.SotR:
                    if (availableHp < 3) throw new InvalidOperationException("SotR cast with less than 3 HP");
                    if (hit)
                    {
                        nextState = sm.SetHP(nextState, hp - availableHp);
                        nextState = sm.SetTimeRemaining(nextState, Buff.SotRSB, gp.BuffDurationInSteps(Buff.SotRSB));
                    }
                    break;
                case Ability.HotR:
                    if (hit)
                    {
                        nextState = sm.SetTimeRemaining(nextState, Buff.WB, gp.BuffDurationInSteps(Buff.WB));
                        nextState = sm.IncHP(nextState);
                    }
                    break;
                case Ability.CS:
                    if (hit)
                    {
                        nextState = sm.IncHP(nextState);
                    }
                    break;
                case Ability.J:
                    if (hit)
                    {
                        nextState = sm.IncHP(nextState);
                        // TODO Selfless Healer buff
                    }
                    break;
                case Ability.AS:
                    if (sm.TimeRemaining(nextState, Buff.GC) > 0) // GC HP is on cast
                    {
                        nextState = sm.IncHP(nextState);
                    }
                    nextState = sm.SetTimeRemaining(nextState, Buff.GC, 0);
                    break;
                case Ability.SS:
                    if (availableHp < 3) throw new InvalidOperationException("SS cast with less than 3 HP");
                    nextState = sm.SetHP(nextState, hp - availableHp);
                    nextState = sm.SetTimeRemaining(nextState, Buff.SS, gp.BuffDurationInSteps(Buff.SS));
                    break;
                case Ability.EF:
                    nextState = sm.SetHP(nextState, hp - availableHp);
                    nextState = sm.SetTimeRemaining(nextState, Buff.EF, gp.BuffDurationInSteps(Buff.EF));
                    // TODO efStacks = availableHp
                    break;
            }
            if (gcProc)
            {
                nextState = sm.SetCooldownRemaining(nextState, Ability.AS, 0);
                nextState = sm.SetTimeRemaining(nextState, Buff.GC, gp.BuffDurationInSteps(Buff.GC));
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
