using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public class MatlabadinGraph
    {
        public MatlabadinGraph(GraphParameters gp, Func<ulong, GraphParameters, Ability> nextStateFunction)
        {
            this.gp = gp;
            this.nextStateFunction = nextStateFunction;
        }
        public struct NextStateTransitionIndex
        {
            public int nextStateIndex1;
            public int nextStateIndex2;
            public int nextStateIndex3;
        }
        // TODO: move the lists to GenerateGraph and have arrays here as it has a non-trivial performance impact in the CalculateNextStateProbability loop
        public Dictionary<ulong, int> lookup; // maps state to state index
        public ulong[] index; // maps state index to state
        public Choice[] choice; // maps state index to choice made
        public NextStateTransitionIndex[] nextState; // maps state index to choice and corresponding next state indexes
        private GraphParameters gp;
        private Func<ulong, GraphParameters, Ability> nextStateFunction;
        private int nextStateIndexSentinal = -1;
        public void GenerateGraph()
        {
            ulong initialState = 0;
            Dictionary<ulong, int> lookup = new Dictionary<ulong, int>();
            List<ulong> index = new List<ulong>();
            List<Choice>  choice = new List<Choice>();
            List<NextStateTransitionIndex> nextState = new List<NextStateTransitionIndex>();
            index.Add(initialState);
            lookup[initialState] = 0;
            while (index.Count() > nextState.Count())
            {
                ulong currentState = index[nextState.Count()];
                //Console.WriteLine(StateHelper.StateToString(currentState, gp));
                Ability abilityChosen = nextStateFunction(currentState, gp);
                ulong nextState1;
                ulong nextState2;
                ulong nextState3;
                int nextStateIndex1 = nextStateIndexSentinal;
                int nextStateIndex2 = nextStateIndexSentinal;
                int nextStateIndex3 = nextStateIndexSentinal;
                Choice c = NextStates(currentState, abilityChosen, gp, out nextState1, out nextState2, out nextState3);
                if (nextState1 != UInt64.MaxValue && !lookup.TryGetValue(nextState1, out nextStateIndex1))
                {
                    nextStateIndex1 = index.Count();
                    index.Add(nextState1);
                    lookup[nextState1] = nextStateIndex1;
                }
                if (nextState2 != UInt64.MaxValue && !lookup.TryGetValue(nextState2, out nextStateIndex2))
                {
                    nextStateIndex2 = index.Count();
                    index.Add(nextState2);
                    lookup[nextState2] = nextStateIndex2;
                }
                if (nextState3 != UInt64.MaxValue && !lookup.TryGetValue(nextState3, out nextStateIndex3))
                {
                    nextStateIndex3 = index.Count();
                    index.Add(nextState3);
                    lookup[nextState3] = nextStateIndex3;
                }
                choice.Add(c);
                nextState.Add(new NextStateTransitionIndex()
                {
                    nextStateIndex1 = nextStateIndex1,
                    nextStateIndex2 = nextStateIndex2,
                    nextStateIndex3 = nextStateIndex3,
                });
            }
            this.lookup = lookup;
            this.index = index.ToArray();
            this.choice = choice.ToArray();
            this.nextState = nextState.ToArray();
        }
        private void ChangeNextStateIndexSentinal(int newSentinalIndex)
        {
            int length = nextState.Count();
            for (int i = 0; i < length; i++)
            {
                nextState[i] = new NextStateTransitionIndex()
                {
                    nextStateIndex1 = nextState[i].nextStateIndex1 == nextStateIndexSentinal ? newSentinalIndex : nextState[i].nextStateIndex1,
                    nextStateIndex2 = nextState[i].nextStateIndex2 == nextStateIndexSentinal ? newSentinalIndex : nextState[i].nextStateIndex2,
                    nextStateIndex3 = nextState[i].nextStateIndex3 == nextStateIndexSentinal ? newSentinalIndex : nextState[i].nextStateIndex3,
                };
            }
            nextStateIndexSentinal = newSentinalIndex;
        }
        public Dictionary<string, double> CalculateAggregates(double[] pr, out double averageStepDuration)
        {
            Dictionary<string, double> sumPr = new Dictionary<string, double>();
            double sumDuration = 0;
            int length = index.Length;
            for (int i = 0; i < length; i++)
            {
                Choice c = choice[i];
                sumDuration += c.stepsDuration;
                double currentPr;
                if (!sumPr.TryGetValue(c.Action, out currentPr)) currentPr = 0;
                sumPr[c.Action] = currentPr + pr[i];
            }
            averageStepDuration = sumDuration / length * 1.5 / gp.StepsPerGcd;
            return sumPr;
        }
        /// <summary>
        /// Calcualtes the state probabilities for the given graph using iterative approximation.
        /// </summary>
        /// <param name="relTolerance">Minimum relative tolerance at which to stop iterating early.</param>
        /// <param name="maxIterations">Maximum number of iterations.</param>
        /// <param name="iterationStride">Number of iterations between tolerance checks</param>
        /// <param name="initialState">Initial state probability distribution. Defaults to equal probability for all states.</param>
        /// <returns>Final state probability distribution</returns>
        public double[] ConvergeStateProbability(double relTolerance = 1e-6, int maxIterations = 4096, int iterationStride = 16, double[] initialState = null)
        {
            if (iterationStride <= 0) throw new ArgumentException("Stride must be greater than 1");
            if (initialState == null)
            {
                // Default initial state
                initialState = new double[nextState.Length + 1];
                double initialPr = 1.0 / nextState.Length;
                for (int i = 0; i < initialState.Length; i++) initialState[i] = initialPr;
            }
            if (initialState.Length < nextState.Length)
            {
                // intial state is smaller than the number of states we have
                double[] newState = new double[nextState.Length + 1];
                Array.Copy(initialState, newState, initialState.Length);
                initialState = newState;
            }
            double[] statePr = initialState;
            double relError, absError;
            double dampeningFactor = 0;
            int iteration = 0;
            do {
                for (int j = 0; j < iterationStride - 1; j++) statePr = CalculateNextStateProbability(statePr, dampeningFactor);
                double[] nextStatePr = CalculateNextStateProbability(statePr, dampeningFactor);
                CalculateError(statePr, nextStatePr, out relError, out absError);
                statePr = nextStatePr;
                iteration += iterationStride;

                if (iteration > 64)
                {
                    // Many (most?) rotations such as CS and SotR>CS>J oscillate when miss=0
                    // as the harmonics can be difficult to detect as the period is not known
                    // beforehand, we start decaying after an initial number of steps.
                    dampeningFactor = 0.125;
                }
            } while (relError > relTolerance && iteration < maxIterations);
            return statePr;
        }
        private void CalculateError(double[] pr1, double[] pr2, out double relError, out double absError)
        {
            relError = 0;
            absError = 0;
            int length = pr1.Length;
            for (int i = 0; i < length; i++)
            {
                double currentAbsError = Math.Abs(pr1[i] - pr2[i]);
                absError = Math.Max(currentAbsError, absError);
                if (currentAbsError > 0)
                {
                    double currentRelError = currentAbsError / Math.Max(pr1[i], pr2[i]);
                    relError = Math.Max(relError, currentRelError);
                }
            }
        }
        /// <summary>
        /// Calculates new state probabilities
        /// </summary>
        /// <remarks>
        /// The decayFactor prevents state probabilities stalling due to inaccurate initial conditions. For example, a 2 state
        /// graph each transitioning to the other state will causes the two states oscillate between their initial values and
        /// not converge to 0.5. A non-zero decay factor dampens this oscillation so convergence will eventually be reached.
        /// </remarks>
        /// <param name="pr">Current state probability</param>
        /// <param name="decayFactor">Weighting between current probabilities and next state probabilities. 0 indicates that the
        /// previous probabilities are ignored, 0 indicates no weight for the next state state probabilities.</param>
        /// <returns>Updated state probabilities</returns>
        public double[] CalculateNextStateProbability(double[] pr, double decayFactor = 0)
        {
            int length = index.Length;
            double[] nextPr = new double[length + 1];
            if (this.nextStateIndexSentinal != length)
            {
                // change our sentinal value to a placeholder state at the end of the probability array
                ChangeNextStateIndexSentinal(length);
            }
            for (int i = 0; i < length; i++)
            {
                double statePr = pr[i];
                NextStateTransitionIndex next = nextState[i];
                Choice c = choice[i];
                // as we're using a sentinal state, we don't need an
                // if (next.nextStateIndexN != nextStateIndexSentinal)
                // conditional which saves us from branching in this expensive
                // inner loop
                nextPr[next.nextStateIndex1] += pr[i] * c.option1;
                nextPr[next.nextStateIndex2] += pr[i] * c.option2;
                nextPr[next.nextStateIndex3] += pr[i] * c.option3;
            }
            if (decayFactor != 0)
            {
                double updatedPortion = 1 - decayFactor;
                for (int i = 0; i < length; i++)
                {
                    nextPr[i] = decayFactor * pr[i] + updatedPortion * nextPr[i];
                }
            }
            if (nextPr.Last() > 0) throw new Exception("Sanity check failure: sentinal value has non-zero probability");
            return nextPr;
        }
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
    }
}
