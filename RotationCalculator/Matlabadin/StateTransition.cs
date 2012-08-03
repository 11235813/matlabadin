﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    /// <summary>
    /// Encapsulates a transition from an initial state,
    /// to one or more next states as a result of using
    /// an ability.
    /// </summary>
    /// <typeparam name="TState">state type</typeparam>
    public class StateTransition<TState>
    {
        /// <summary>
        /// Initial state before transitioning
        /// </summary>
        public TState StateInitial { get; private set; }
        /// <summary>
        /// State immediately before ability use
        /// </summary>
        public TState StatePreAbility { get; private set; }
        /// <summary>
        /// States immediate after ability use
        /// </summary>
        public TState[] StatePostAbility { get; private set; }
        /// <summary>
        /// States when GCD has completed and another ability could be used
        /// </summary>
        public TState[] NextStates { get; private set; }
        /// <summary>
        /// Choice associated with the <see cref="StatePostAbility"/> next states
        /// </summary>
        public Choice Choice { get; private set; }

        /// <summary>
        /// Calculates the state transitions from the given state; this is called from MatlabadinGraph.GenerateGraph()
        /// </summary>
        /// <param name="gp">Graph Parameters</param>
        /// <param name="sm">State Manager</param>
        /// <param name="state">state to transition from</param>
        /// <returns>state transitions information</returns>
        public static StateTransition<TState> CalculateTransition(
            GraphParameters<TState> gp,
            IStateManager<TState> sm,
            TState state)
        {
            // this calls the constructors below to create the StateTransition object
            StateTransition<TState> transition = new StateTransition<TState>(gp, sm, state);
            // Coalesse consecutive single-choice transitions
            List<TState> concatenatedTransitions = null;
            List<Choice> concatenatedChoices = null;
            while (transition.NextStates.Length == 1)
            {
                if (concatenatedTransitions == null)
                {
                    concatenatedTransitions = new List<TState>();
                    concatenatedChoices = new List<Choice>();
                }
                // A->B->C->A should convert to an A->A transition
                if (transition.NextStates[0].Equals(transition.StateInitial))
                {
                    return transition;
                }
                // A->B->C->B should convert to an A->B transition
                // NOTE: this operation can break the graph up into subgraphs. Consider:
                // A->B->C->A, D->A, E->B
                // This will be broken up into D->A->A, E->B->B
                // This behaviour is acceptable since a) cycles of single transitions are
                // pr sinks and b) A->A & B->B are equivalent from an action aggregation
                // perspective.
                for (int i = 0; i < concatenatedTransitions.Count; i++)
                {
                    if (transition.NextStates[0].Equals(concatenatedTransitions[i]))
                    {
                        // roll back our concatenation to the start of the cycle we just detected
                        transition.Choice = concatenatedChoices[i];
                        return transition;
                    }
                }
                concatenatedTransitions.Add(transition.NextStates[0]);
                concatenatedChoices.Add(transition.Choice);
                StateTransition<TState> nextTransition = new StateTransition<TState>(gp, sm, transition.NextStates[0]);
                transition.Choice = transition.Choice.Concatenate(nextTransition.Choice);
                transition.NextStates = nextTransition.NextStates;
            }
            return transition;
        }

        /// <summary>
        /// Creates a StateTransition object from the given state, called from StateTransition.CalculateTransition
        /// </summary>
        /// <param name="gp">Graph Parameters</param>
        /// <param name="sm">State Manager</param>
        /// <param name="state">state to transition from</param>
        public StateTransition(
            GraphParameters<TState> gp,
            IStateManager<TState> sm,
            TState state)
            : this(
                gp,
                sm,
                state,
                // Use the graph parameter rotation to determine the action to
                gp.Rotation.ActionToTake(gp, sm, state))
        {
        }
        // This constructor is called by the above one (note the different arguments), and it calls CalculateStateTransition
        public StateTransition(
            GraphParameters<TState> gp,
            IStateManager<TState> sm,
            TState state,
            Ability ability)
        {
            StateInitial = state;
            CalculateStateTransition(gp, sm, ability);
#if !NOSANITYCHECKS
            SanityCheck();
#endif
        }

        /// <summary>
        /// Calculates the state transition state and choice information based on the <see cref="StateInitial"/> state.  Called from the constructor above
        /// </summary>
        /// <param name="gp">Graph Parameters</param>
        /// <param name="sm">State Manager</param>
        private void CalculateStateTransition(
            GraphParameters<TState> gp,
            IStateManager<TState> sm,
            Ability ability)
        {
            // check if we have to wait
            int waitSteps = sm.CooldownRemaining(StateInitial, ability);
            if (gp.AbilityOnGcd(ability)) waitSteps = Math.Max(waitSteps, sm.TimeRemaining(StateInitial, Buff.GCD));
            // Advance time to before ability usage
            StatePreAbility = waitSteps == 0 ? StateInitial : sm.AdvanceTime(StateInitial, waitSteps);

            // Use ability
            double[] pr = CalculatesStatePostAbility(gp, sm, ability);

            // Cull transitions with zero probability
            pr = CullStatePostAbilityZeroProbabilityTransitions(pr);

            // Advance time after ability usage
            int abilitySteps = gp.AbilityCastTimeInSteps(ability);
            NextStates = new TState[StatePostAbility.Length];
            for (int i = 0; i < StatePostAbility.Length; i++)
            {
                NextStates[i] = sm.AdvanceTime(StatePostAbility[i], abilitySteps);
            }

            // Calculate uptime of tracked buffs. 
            // during this transition, how many steps was the tracked buff active for?
            int[] unforkedBuffSteps = new int[(int)Buff.UptimeTrackedUnforkedBuffs];
            for (int i = 0; i < (int)Buff.UptimeTrackedUnforkedBuffs; i++)
            {
                unforkedBuffSteps[i] = Math.Min(waitSteps, sm.TimeRemaining(StateInitial, (Buff)i))
                    + Math.Min(abilitySteps, sm.TimeRemaining(StatePostAbility[0], (Buff)i));
#if !NOSANITYCHECKS
                for (int j = 1; j < StatePostAbility.Length; j++)
                {
                    if (Math.Min(abilitySteps, sm.TimeRemaining(StatePostAbility[j], (Buff)i)) !=
                        Math.Min(abilitySteps, sm.TimeRemaining(StatePostAbility[0], (Buff)i)))
                    {
                        throw new InvalidOperationException("Sanity check failure: forked buff duration detected for unforked buff");
                    }
                }
#endif
            }
            // In the case of Weakening Blows uptime this depends on whether HotR hit or not
            // SotR buff may or may not also exhibit this behaviour
            int[][] forkedBuffSteps = new int[(int)Buff.UptimeTrackedForkedBuffs - (int)Buff.UptimeTrackedUnforkedBuffs][];
            for (int i = 0; i < (int)Buff.UptimeTrackedForkedBuffs - (int)Buff.UptimeTrackedUnforkedBuffs; i++)
            {
                Buff buff = (Buff)(i + (int)Buff.UptimeTrackedUnforkedBuffs);
                int waitBuffUptimeSteps = Math.Min(waitSteps, sm.TimeRemaining(StateInitial, buff));
                forkedBuffSteps[i] = new int[StatePostAbility.Length];
                for (int j = 0; j < StatePostAbility.Length; j++)
                {
                    forkedBuffSteps[i][j] = waitBuffUptimeSteps + Math.Min(abilitySteps, sm.TimeRemaining(StatePostAbility[j], buff));
                }
            }
            // Create the choice
            Choice = new Choice(
                ability,
                waitSteps + abilitySteps,
                pr,
                sm.HP(StateInitial),
                (ability == Ability.WoG || ability == Ability.EF) && sm.TimeRemaining(StatePreAbility, Buff.BoG) > 0,
                ability == Ability.AS && sm.TimeRemaining(StatePreAbility, Buff.GC) > 0,
                ability == Ability.FoL ? sm.Stacks(StatePreAbility, Buff.SH) : 0,
                (ability == Ability.WoG || ability == Ability.EF) ? sm.Stacks(StatePreAbility, Buff.BoG) : 0,
                sm.TimeRemaining(StatePreAbility, Buff.AW) > 0,
                sm.TimeRemaining(StatePreAbility, Buff.DP) > 0,
                (ability == Ability.CS || ability == Ability.J || ability == Ability.HotR || (ability == Ability.AS && sm.TimeRemaining(StatePreAbility, Buff.GC) > 0)) && sm.TimeRemaining(StatePreAbility, Buff.HA) > 0,
                unforkedBuffSteps,
                forkedBuffSteps);
        }

        /// <summary>
        /// Calculates the set of possible states as a result of using the given ability, called from CalculateStateTransition
        /// </summary>
        /// <param name="gp">Graph Parameters</param>
        /// <param name="sm">State Manager</param>
        /// <param name="ability">Ability to use</param>
        /// <returns>Probability of each of the <see cref="StatePostAbility"/> transitions</returns>
        private double[] CalculatesStatePostAbility(GraphParameters<TState> gp, IStateManager<TState> sm, Ability ability)
        {
            double[] pr;
            switch (ability)
            {
                case Ability.HotR:
                case Ability.CS:
                    StatePostAbility = new TState[]
                    {
                        UseAbility(gp, sm, StatePreAbility, ability, false), // miss
                        UseAbility(gp, sm, StatePreAbility, ability, true), // hit
                        UseAbility(gp, sm, StatePreAbility, ability, true, gcProc: true), // hit & gc
                    };
                    double gcProcPr = gp.MeleeHit * gp.GrandCrusaderProcRate;
                    pr = new double[]
                    {
                        1 - gp.MeleeHit,
                        1 - (1 - gp.MeleeHit + gcProcPr),
                        gcProcPr,
                    };
                    break;
                case Ability.SotR:
                    StatePostAbility = new TState[]
                    {
                        UseAbility(gp, sm, StatePreAbility, ability, false), // miss
                        UseAbility(gp, sm, StatePreAbility, ability, true), // hit & no DivPurp
                        UseAbility(gp, sm, StatePreAbility, ability, true, dpProc: true), // hit & DivPurp
                    };
                    pr = new double[]
                    {
                        1 - gp.MeleeHit,
                        gp.MeleeHit * (1-gp.DivinePurposeProcRate),
                        gp.MeleeHit * gp.DivinePurposeProcRate,
                    };
                    break;
                case Ability.J:
                case Ability.AS:
                    StatePostAbility = new TState[]
                    {
                        UseAbility(gp, sm, StatePreAbility, ability, false), // miss
                        UseAbility(gp, sm, StatePreAbility, ability, true), // hit
                    };
                    pr = new double[]
                    {
                        1 - gp.SpellHit,
                        gp.SpellHit,
                    };
                    break;
                case Ability.WoG:
                case Ability.EF:
                    StatePostAbility = new TState[]
                    {
                        UseAbility(gp, sm, StatePreAbility, ability, false), // no DivPurp
                        UseAbility(gp, sm, StatePreAbility, ability, false, dpProc: true), // DivPurp
                    };
                    pr = new double[]
                    {
                        1 - gp.DivinePurposeProcRate,
                        gp.DivinePurposeProcRate,
                    };
                    break;
                // Can't miss
                case Ability.Cons:
                case Ability.HW:
                case Ability.HoW:
                case Ability.Nothing:
                case Ability.SS:
                case Ability.FoL:
                case Ability.AW:
                case Ability.HPr:
                case Ability.LH:
                case Ability.ES:
                case Ability.HA:
                    StatePostAbility = new TState[]
                    {
                        UseAbility(gp, sm, StatePreAbility, ability),
                    };
                    pr = new double[] { 1, };
                    break;
                default:
                    throw new ArgumentException(String.Format("Unknown ability {0}", ability));
            }
            return pr;
        }
        /// <summary>
        /// Removes zero probability transitions from the available StatePostAbility transitions
        /// </summary>
        /// <param name="pr">Probability of each state transition</param>
        /// <returns>Probability of each state transition with zero probability transitions culled</returns>
        private double[] CullStatePostAbilityZeroProbabilityTransitions(double[] pr)
        {
            int zeroes = 0;
            foreach(double p in pr) if (p == 0) zeroes++;
            if (zeroes != 0)
            {
                int nonZeroCount = StatePostAbility.Length - zeroes;
                TState[] newState = new TState[nonZeroCount];
                double[] newPr = new double[nonZeroCount];
                int offset = 0;
                for (int i = 0; i < StatePostAbility.Length; i++)
                {
                    if (pr[i] != 0)
                    {
                        newState[offset] = StatePostAbility[i];
                        newPr[offset] = pr[i];
                        offset++;
                    }
                }
                StatePostAbility = newState;
                return newPr;
            }
            else
            {
                return pr;
            }
        }
        /// <summary>
        /// Uses the given ability
        /// </summary>
        /// <param name="gp">Graph Parameters</param>
        /// <param name="sm">State Manager</param>
        /// <param name="state">state immediately before using ability</param>
        /// <param name="ability">ability to use</param>
        /// <param name="waitSteps">Time to wait before</param>
        /// <param name="hit">whether ability hit or not</param>
        /// <param name="gcProc">whether a Grand Crusader proc occurred or not</param>
        /// <returns>state immediately after using ability</returns>
        public static TState UseAbility(
            GraphParameters<TState> gp,
            IStateManager<TState> sm,
            TState state,
            Ability ability,
            bool hit = true,
            bool gcProc = false,
            bool dpProc = false)
        {
            if (sm.CooldownRemaining(state, ability) > 0) throw new InvalidOperationException(String.Format("Attempting to use {0} whilest still on cooldown", ability));
            if (gp.AbilityOnGcd(ability) && sm.TimeRemaining(state, Buff.GCD) > 0) throw new InvalidOperationException(String.Format("Attempting to use {0} before GCD complete", ability));
            TState nextState = state;
            int hp = sm.HP(nextState);
            int availableHp = Math.Min(3, hp);
            int abilityCooldown = gp.AbilityCooldownInSteps(ability);
            if (abilityCooldown > 0)
            {
                nextState = sm.SetCooldownRemaining(nextState, ability, abilityCooldown);
            }
            if (gp.Spec == PaladinSpec.Prot && ability == Ability.J && gp.Talents.Includes(PaladinTalents.SanctifiedWrath) && sm.TimeRemaining(state, Buff.AW) > 0)
            {
                // reduce CD by 50%
                abilityCooldown /= 2;
                nextState = sm.SetCooldownRemaining(nextState, ability, abilityCooldown);
            }
            switch (ability)
            {
                case Ability.WoG:
                    if (sm.TimeRemaining(nextState, Buff.DP) > 0) // Consume DP first
                    {
                        nextState = sm.SetTimeRemaining(nextState, Buff.DP, 0);
                    }
                    else  // otherwise use HP
                    {
                        nextState = sm.SetHP(nextState, hp - availableHp);
                    }
                    break;
                case Ability.SotR:
                    if ((availableHp < 3) && (sm.TimeRemaining(nextState, Buff.DP) == 0) ) throw new InvalidOperationException("SotR cast with less than 3 HP and no DP");
                    // use HP or DP (always)
                    if (sm.TimeRemaining(nextState, Buff.DP) > 0) // Consume DP first
                    {
                        nextState = sm.SetTimeRemaining(nextState, Buff.DP, 0);
                    }
                    else // otherwise use HP
                    {
                        nextState = sm.SetHP(nextState, hp - availableHp);
                    }
                    // reset SotRSB duration to full
                    nextState = sm.SetTimeRemaining(nextState, Buff.SotRSB, gp.BuffDurationInSteps(Buff.SotRSB));
                    // set BoG duration to full, increment stacks
                    int bogStacks = sm.Stacks(nextState, Buff.BoG);
                    nextState = sm.SetTimeRemaining(nextState, Buff.BoG, gp.BuffDurationInSteps(Buff.BoG));
                    nextState = sm.SetStacks(nextState, Buff.BoG, Math.Min(bogStacks + 1, gp.MaxBuffStacks(Buff.BoG)));
                    break;
                case Ability.HotR:
                    if (hit)
                    {
                        nextState = sm.SetTimeRemaining(nextState, Buff.WB, gp.BuffDurationInSteps(Buff.WB));
                        nextState = IncHP(sm, state, nextState);
                    }
                    break;
                case Ability.CS:
                    if (hit)
                    {
                        nextState = IncHP(sm, state, nextState);
                    }
                    break;
                case Ability.J:
                    if (hit)
                    {
                        nextState = IncHP(sm, state, nextState);
                        if (gp.Talents.Includes(PaladinTalents.SelflessHealer))
                        {
                            int shStacks = sm.Stacks(nextState, Buff.SH);
                            nextState = sm.SetTimeRemaining(nextState, Buff.SH, gp.BuffDurationInSteps(Buff.SH));
                            nextState = sm.SetStacks(nextState, Buff.SH, Math.Min(shStacks + 1, gp.MaxBuffStacks(Buff.SH)));
                        }
                    }
                    break;
                case Ability.AS:
                    if (sm.TimeRemaining(nextState, Buff.GC) > 0) // GC HP is on cast
                    {
                        nextState = IncHP(sm, state, nextState);
                    }
                    nextState = sm.SetTimeRemaining(nextState, Buff.GC, 0);
                    break;
                case Ability.SS:
                    nextState = sm.SetTimeRemaining(nextState, Buff.SS, gp.BuffDurationInSteps(Buff.SS));
                    break;
                case Ability.EF:
                    if (sm.TimeRemaining(nextState, Buff.DP) > 0)
                    {
                        nextState = sm.SetTimeRemaining(nextState, Buff.DP, 0);
                    }
                    else
                    {
                        nextState = sm.SetHP(nextState, hp - availableHp);
                    }
                    nextState = sm.SetTimeRemaining(nextState, Buff.EF, gp.BuffDurationInSteps(Buff.EF));
                    // TODO efStacks = availableHp
                    break;
                case Ability.FoL:
                    nextState = sm.SetStacks(nextState, Buff.SH, 0);
                    break;
                case Ability.AW:
                    nextState = sm.SetTimeRemaining(nextState, Buff.AW, gp.BuffDurationInSteps(Buff.AW));
                    break;
                case Ability.HA:
                    nextState = sm.SetTimeRemaining(nextState, Buff.HA, gp.BuffDurationInSteps(Buff.HA));
                    break;
            }
            if (gcProc)
            {
                nextState = sm.SetCooldownRemaining(nextState, Ability.AS, 0);
                nextState = sm.SetTimeRemaining(nextState, Buff.GC, gp.BuffDurationInSteps(Buff.GC));
            }
            if (dpProc)
            {
                if (gp.Talents.Includes(PaladinTalents.DivinePurpose)) // this might be unnecessary since we set the proc rate to 0 in GraphParameters if untalented
                {
                    nextState = sm.SetTimeRemaining(nextState, Buff.DP, gp.BuffDurationInSteps(Buff.DP));
                }

            }
            if (gp.AbilityTriggersGcd(ability))
            {
                nextState = sm.SetTimeRemaining(nextState, Buff.GCD, gp.StepsPerHastedGcd);
            }
            return nextState;
        }
        private static TState IncHP(IStateManager<TState> sm, TState state, TState nextState)
        {
            nextState = sm.IncHP(nextState);
            if (sm.TimeRemaining(state, Buff.HA) > 0)
            {
                nextState = sm.IncHP(nextState);
                nextState = sm.IncHP(nextState);
            }
            return nextState;
        }
        private void SanityCheck()
        {
            if (NextStates == null) throw new Exception("Sanity failure: NextStates null");
            if (StatePostAbility == null) throw new Exception("Sanity failure: StatePostAbility null");
            if (Choice == null) throw new Exception("Choice: StatePostAbility null");
            if (NextStates.Length == 0) throw new Exception("Sanity failure: NextStates length 0");
            if (NextStates.Length != StatePostAbility.Length) throw new Exception("Sanity failure: NextStates and StatePostAbility lengths differ");
            if (NextStates.Length != Choice.pr.Length) throw new Exception("Sanity failure: NextStates and pr lengths differ");
        }
    }
}
