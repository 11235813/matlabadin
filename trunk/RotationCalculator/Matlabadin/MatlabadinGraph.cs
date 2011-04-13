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
        public Dictionary<ulong, int> lookup; // maps state to state index
        public List<ulong> index; // maps state index to state
        public List<Choice> choice; // maps state index to choice made
        public List<NextStateTransitionIndex> nextState; // maps state index to choice and corresponding next state indexes
        private GraphParameters gp;
        private Func<ulong, GraphParameters, Ability> nextStateFunction;
        public void GenerateGraph()
        {
            ulong initialState = 0;
            lookup = new Dictionary<ulong, int>();
            index = new List<ulong>();
            choice = new List<Choice>();
            nextState = new List<NextStateTransitionIndex>();
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
                int nextStateIndex1 = -1;
                int nextStateIndex2 = -1;
                int nextStateIndex3 = -1;
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
        }
        public Dictionary<string, double> CalculateAggregates(double[] pr, out double averageStepDuration)
        {
            Dictionary<string, double> sumPr = new Dictionary<string, double>();
            double sumDuration = 0;
            for (int i = 0; i < pr.Length; i++)
            {
                Choice c = choice[i];
                sumDuration += c.stepsDuration;
                double currentPr;
                if (!sumPr.TryGetValue(c.action, out currentPr)) currentPr = 0;
                sumPr[c.action] = currentPr + pr[i];
            }
            averageStepDuration = sumDuration / pr.Length * 1.5 / gp.StepsPerGcd;
            return sumPr;
        }
        public double[] ConvergeStateProbability(double relTolerance = 1e-6, int maxIterations = 2048, double[] initialState = null)
        {
            if (initialState == null)
            {
                // Default initial state
                initialState = new double[nextState.Count];
                double initialPr = 1.0 / nextState.Count;
                for (int i = 0; i < initialState.Length; i++) initialState[i] = initialPr;
            }
            if (initialState.Length < nextState.Count)
            {
                // intial state is smaller than the number of states we have
                double[] newState = new double[nextState.Count];
                Array.Copy(initialState, newState, initialState.Length);
                initialState = newState;
            }
            double[] statePr = initialState;
            double lastAbsError = 1;
            double decayFactor = 0;
            double relError = 0;
            double absError = 0;
            int iteration = 0;
            do {
                relError = 0;
                absError = 0;
                // TODO: only check errors every few iterations as checking the error
                // take non-trivial time compared to actually doing an iteration
                double[] nextStatePr = CalculateNextStateProbability(statePr, decayFactor);
                for (int i = 0; i < nextStatePr.Length; i++)
                {
                    double currentAbsError = Math.Abs(statePr[i] - nextStatePr[i]);
                    absError = Math.Max(currentAbsError, absError);
                    if (currentAbsError > 0)
                    {
                        double currentRelError = currentAbsError / Math.Max(statePr[i], nextStatePr[i]);
                        relError = Math.Max(relError, currentRelError);
                    }
                }
                if (iteration > 64 && absError == lastAbsError)
                {
                    // give it some time to clear out the zero states.
                    // If we're still not converging it's likely to be oscillation
                    // start dampening the oscillations
                    decayFactor = 0.25;
                }
                lastAbsError = absError;
                statePr = nextStatePr;
            } while (relError > relTolerance && ++iteration < maxIterations);
            return statePr;
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
            double[] nextPr = new double[index.Count];
            for (int i = 0; i < index.Count; i++)
            {
                double statePr = pr[i];
                NextStateTransitionIndex next = nextState[i];
                Choice c = choice[i];
                // TODO: use a sentinal state pr[index.Count] to remove the branching
                if (next.nextStateIndex1 >= 0) nextPr[next.nextStateIndex1] += pr[i] * c.option1;
                if (next.nextStateIndex2 >= 0) nextPr[next.nextStateIndex2] += pr[i] * c.option2;
                if (next.nextStateIndex3 >= 0) nextPr[next.nextStateIndex3] += pr[i] * c.option3;
            }
            if (decayFactor != 0)
            {
                double updatedPortion = 1 - decayFactor;
                for (int i = 0; i < pr.Length; i++)
                {
                    nextPr[i] = decayFactor * pr[i] + updatedPortion * nextPr[i];
                }
            }
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
