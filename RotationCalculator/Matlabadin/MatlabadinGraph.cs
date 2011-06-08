using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public class MatlabadinGraph<TState>
    {
        public MatlabadinGraph(GraphParameters<TState> gp, IStateManager<TState> sm)
        {
            this.GraphParameters = gp;
            this.StateManager = sm;
            GenerateGraph();
        }
        /// <summary>
        /// Clones a given graph.
        /// </summary>
        /// <remarks>Cloning will onyl succeed if the graphs only differ in their transition probabilities.
        /// That is, they only differ in MeleeHit and RangeHit.</remarks>
        /// <param name="graph">Graph to clone.</param>
        /// <param name="gp">New parameters</param>
        public MatlabadinGraph(MatlabadinGraph<TState> graph, GraphParameters<TState> gp)
        {
            if (!graph.GraphParameters.HasSameShape(gp)) throw new ArgumentException("Graphs do not have the same shape");
            this.GraphParameters = gp;
            this.StateManager = graph.StateManager;
            this.lookup = graph.lookup;
            this.index = graph.index;
            this.nextState = graph.nextState;

            // replace the choices in the existing graph with the new choices. Since the graph has the same shape we don't have to generate the entire graph
            TState[] tempNextStates;
            var choiceConversion =
                from kvp in graph.firstChoiceState
                select new {
                    OldChoice = kvp.Key,
                    NewChoice = StateHelper<TState>.NextStates(GraphParameters, StateManager, kvp.Value, out tempNextStates),
                    State = kvp.Value
                };
            this.firstChoiceState = choiceConversion.ToDictionary(n => n.NewChoice, n => n.State);
            Dictionary<Choice<TState>, Choice<TState>> choiceRemapping = choiceConversion.ToDictionary(n => n.OldChoice, n => n.NewChoice);
            this.choice = graph.choice.Select(c => choiceRemapping[c]).ToArray();
        }
        /// <summary>
        /// Number of distinct state in the graph
        /// </summary>
        public int Size { get { return index.Length; } }
        public GraphParameters<TState> GraphParameters { get; private set; }
        public IStateManager<TState> StateManager { get; private set; }
        private void GenerateGraph()
        {
            TState initialState = StateManager.InitialState();
            Dictionary<TState, int> lookup = new Dictionary<TState, int>();
            List<TState> index = new List<TState>();
            List<Choice<TState>> choice = new List<Choice<TState>>();
            List<int[]> nextState = new List<int[]>();
            firstChoiceState = new Dictionary<Choice<TState>, TState>();
            index.Add(initialState);
            lookup[initialState] = 0;
            while (index.Count() > nextState.Count())
            {
                TState currentState = index[nextState.Count()];
                //Console.WriteLine(StateHelper<TState>.StateToString(GraphParameters, StateManager, currentState));
                Ability abilityChosen = GraphParameters.Rotation.ActionToTake(GraphParameters, StateManager, currentState);
                TState[] currentNextState;
                int[] currentNextStateIndex;
                Choice<TState> c = StateHelper<TState>.NextStates(GraphParameters, StateManager, currentState, abilityChosen, out currentNextState);
                currentNextStateIndex = new int[currentNextState.Length];
                for (int i = 0; i < currentNextState.Length; i++)
                {
                    if (!lookup.TryGetValue(currentNextState[i], out currentNextStateIndex[i]))
                    {
                        currentNextStateIndex[i] = index.Count();
                        index.Add(currentNextState[i]);
                        lookup[currentNextState[i]] = currentNextStateIndex[i];
                    }
                }
                choice.Add(LookupStateChoice(c, currentState));
                nextState.Add(currentNextStateIndex);
            }
            this.lookup = lookup;
            this.index = index.ToArray();
            this.choice = choice.ToArray();
            this.nextState = nextState.ToArray();
        }
        private Choice<TState> LookupStateChoice(Choice<TState> choice, TState state)
        {
            if (firstChoiceState.ContainsKey(choice))
            {
                // return the cached value
                return firstChoiceState.Keys.First(c => c.Equals(choice));
            }
            else
            {
                // add to cache as this is the first state in which we have made this choice
                firstChoiceState[choice] = state;
                return choice;
            }
        }
        public Dictionary<string, double> CalculateResults(double[] pr, out double inqUptime, out double jotwUptime)
        {
            // t = time in state
            // pr = probability of being in state
            // sumtpr = sum(t*pr)
            // pr(choice) = sum[all state=choice](pr) / sumtpr
            Dictionary<string, double> cps = new Dictionary<string, double>();
            double sumtpr = 0;
            double suminqtpr = 0;
            double sumjotwtpr = 0;
            for (int i = 0; i < index.Length; i++)
            {
                Choice<TState> c = choice[i];
                double t = c.stepsDuration * GraphParameters.StepDuration;
                double inqt = c.inqDuration * GraphParameters.StepDuration;
                double jotwt = c.jotwDuration * GraphParameters.StepDuration;
                double tpr = t * pr[i];
                sumtpr += tpr;
                suminqtpr += inqt * pr[i];
                sumjotwtpr += jotwt * pr[i];
                if (c.Ability != Ability.Nothing)
                {
                    double currentPr;
                    if (!cps.TryGetValue(c.Action, out currentPr)) currentPr = 0;
                    cps[c.Action] = currentPr + pr[i];
                }
            }
            inqUptime = suminqtpr / sumtpr;
            jotwUptime = sumjotwtpr / sumtpr;
            return cps.ToDictionary(kvp => kvp.Key, kvp => kvp.Value / sumtpr);
        }
        /// <summary>
        /// Calcualtes the state probabilities for the given graph using iterative approximation.
        /// </summary>
        /// <remarks></remarks>
        /// <param name="relTolerance">Minimum relative tolerance at which to stop iterating early.</param>
        /// <param name="absTolerance">Absolute tolerance at which to stop iterating early.</param>
        /// <param name="maxIterations">Maximum number of iterations.</param>
        /// <param name="iterationStride">Number of iterations between tolerance checks</param>
        /// <param name="initialState">Initial state probability distribution. Defaults to equal probability for all states.</param>
        /// <returns>Final state probability distribution</returns>
        public double[] ConvergeStateProbability(
            out int iterationsPerformed,
            out double finalRelTolerance,
            out double finalAbsTolerance,
            double relTolerance = 1e-8,
            double absTolerance = 1e-10,
            int maxIterations = 4096,
            int iterationStride = 16,
            double[] initialState = null)
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

                // Many (most?) rotations such as CS and SotR>CS>J oscillate when miss=0
                // As the harmonics can be difficult to detect as the period is not known
                // beforehand, we start decaying after an initial number of steps.
                // If we dampen every iteration, relative tolerance will always be high
                // and we will never terminate due to small relative tolerance so we only
                // dampen sometimes
                dampeningFactor = ((iteration / iterationStride) % 4 == 3) ? 0.25 : 0;

                // some 0 probability subgraphs take a very long time to converge.
                // For example: the graph A->B, B->C, C->D, D->E, E->A(0.5), E->F(0.5), F->F
                // will have it's relative tolerance of 0.5 (undampened) until
                // floating point rounding sets them to zero at A,B,C,D,E~=1e-324
                // this takes many iterations so as a short-cut, we zero out any
                // sufficiently small state.
                // Theoretically, a large number of very small states could have a non-trivial
                // effect on the actual probabilities.
                ZeroVerySmallValues(statePr, absTolerance / index.Length / 2);
            } while (relError > relTolerance && absError > absTolerance && iteration < maxIterations);
            iterationsPerformed = iteration;
            finalRelTolerance = relError;
            finalAbsTolerance = absError;
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
        /// Zeroes out any probabilities that could have no effect on the result
        /// due to floating point rounding truncation.
        /// </summary>
        /// <param name="pr">Probabilities to process</param>
        private void ZeroVerySmallValues(double[] pr, double minValue)
        {
            for (int i = 0; i < pr.Length; i++)
            {
                if (pr[i] < minValue) pr[i] = 0;
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
            //UpdateFromNextState(pr, nextPr);
            //UpdateFromTransitions(pr, nextPr); // ~20% faster than UpdateFromNextState
            UpdateFromFixedWidthNextState(pr, nextPr); // ~40% faster than UpdateFromNextState
            if (decayFactor != 0)
            {
                double updatedPortion = 1 - decayFactor;
                for (int i = 0; i < length; i++)
                {
                    nextPr[i] = decayFactor * pr[i] + updatedPortion * nextPr[i];
                }
            }
            return nextPr;
        }
        private void UpdateFromNextState(double[] pr, double[] nextPr)
        {
            int length = index.Length;
            for (int i = 0; i < length; i++)
            {
                double statePr = pr[i];
                Choice<TState> c = choice[i];
                int[] next = nextState[i];
                int len = next.Length;
                for (int j = 0; j < len; j++)
                {
                    nextPr[next[j]] += statePr * c.pr[j];
                }
            }
        }
        #region Alternate next state implementation: group by #transitions
        private int[,] singleTransitions;
        private int[,] doubleTransitions;
        private int[,] tripleTransitions;
        private int[] remainingTransitions;
        private void UpdateFromTransitions(double[] pr, double[] nextPr)
        {
            if (singleTransitions == null)
            {
                InitTransitions();
            }
            int length = index.Length;
            UpdateSingleTransitions(pr, nextPr, singleTransitions);
            UpdateDoubleTransitions(pr, nextPr, doubleTransitions);
            UpdateTripleTransitions(pr, nextPr, tripleTransitions);
            UpdateRemainingTransitions(pr, nextPr, remainingTransitions);
        }
        private void InitTransitions()
        {
            // worth optimising this? We make 4 passes of nextState setting up
            singleTransitions = new int[nextState.Count(ns => ns.Length == 1), 2];
            doubleTransitions = new int[nextState.Count(ns => ns.Length == 2), 3];
            tripleTransitions = new int[nextState.Count(ns => ns.Length == 3), 4];
            remainingTransitions = new int[nextState.Count(ns => ns.Length > 3)];
            int offset1 = 0;
            int offset2 = 0;
            int offset3 = 0;
            int offsetRemaining = 0;
            for (int i = 0; i < nextState.Length; i++)
            {
                int[] ns = nextState[i];
                switch (ns.Length)
                {
                    case 1:
                        singleTransitions[offset1, 0] = i;
                        singleTransitions[offset1, 1] = nextState[i][0];
                        offset1++;
                        break;
                    case 2:
                        doubleTransitions[offset2, 0] = i;
                        doubleTransitions[offset2, 1] = nextState[i][0];
                        doubleTransitions[offset2, 2] = nextState[i][1];
                        offset2++;
                        break;
                    case 3:
                        tripleTransitions[offset3, 0] = i;
                        tripleTransitions[offset3, 1] = nextState[i][0];
                        tripleTransitions[offset3, 2] = nextState[i][1];
                        tripleTransitions[offset3, 3] = nextState[i][2];
                        offset3++;
                        break;
                    default:
                        remainingTransitions[offsetRemaining++] = i;
                        break;
                }
            }
        }
        private void UpdateSingleTransitions(double[] pr, double[] nextPr, int[,] transitions)
        {
            int length = transitions.Length / 2;
            for (int i = 0; i < length; i++)
            {
                int sourceIndex = transitions[i, 0];
                Choice<TState> c = choice[sourceIndex];
                double sourcePr = pr[sourceIndex];
                int destIndex1 = transitions[i, 1];
                nextPr[destIndex1] += sourcePr * c.pr[0];
            }
        }
        private void UpdateDoubleTransitions(double[] pr, double[] nextPr, int[,] transitions)
        {
            int length = transitions.Length / 3;
            for (int i = 0; i < length; i++)
            {
                int sourceIndex = transitions[i, 0];
                Choice<TState> c = choice[sourceIndex];
                double sourcePr = pr[sourceIndex];
                int destIndex1 = transitions[i, 1];
                int destIndex2 = transitions[i, 2];
                nextPr[destIndex1] += sourcePr * c.pr[0];
                nextPr[destIndex2] += sourcePr * c.pr[1];
            }
        }
        private void UpdateTripleTransitions(double[] pr, double[] nextPr, int[,] transitions)
        {
            int length = transitions.Length / 4;
            for (int i = 0; i < length; i++)
            {
                int sourceIndex = transitions[i, 0];
                Choice<TState> c = choice[sourceIndex];
                double sourcePr = pr[sourceIndex];
                int destIndex1 = transitions[i, 1];
                int destIndex2 = transitions[i, 2];
                int destIndex3 = transitions[i, 3];
                nextPr[destIndex1] += sourcePr * c.pr[0];
                nextPr[destIndex2] += sourcePr * c.pr[1];
                nextPr[destIndex3] += sourcePr * c.pr[2];
            }
        }
        private void UpdateRemainingTransitions(double[] pr, double[] nextPr, int[] states)
        {
            int length = states.Length;
            for (int i = 0; i < length; i++)
            {
                int sourceIndex = states[i];
                Choice<TState> c = choice[sourceIndex];
                double sourcePr = pr[sourceIndex];
                int[] next = nextState[sourceIndex];
                int len = next.Length;
                for (int j = 0; j < len; j++)
                {
                    nextPr[next[j]] += sourcePr * c.pr[j];
                }
            }
        }
        #endregion
        #region Alternate next state implementation: sentinal state
        private Nullable<bool> fwPossible;
        private int[,] fwNextState;
        private double[][] fwPr;
        private void UpdateFromFixedWidthNextState(double[] pr, double[] nextPr)
        {
            // fall back to using transitions for next states
            if (fwPossible.HasValue && !fwPossible.Value) UpdateFromTransitions(pr, nextPr);

            if (fwNextState == null) InitFixedWidthNextState();
            int length = index.Length;
            for (int i = 0; i < length; i++)
            {
                double statePr = pr[i];
                double[] nextStatePr = fwPr[i];
                nextPr[fwNextState[i, 0]] += statePr * nextStatePr[0];
                nextPr[fwNextState[i, 1]] += statePr * nextStatePr[1];
                nextPr[fwNextState[i, 2]] += statePr * nextStatePr[2];
            }
        }
        private void InitFixedWidthNextState()
        {
            int sentinal = index.Length;
            fwNextState = new int[nextState.Length, 3];
            fwPr = new double[nextState.Length][];
            List<double[]> uniquePr = new List<double[]>();
            for (int i = 0; i < index.Length; i++)
            {
                double[] pr = choice[i].pr;
                double[] fixedWidthPr = new double[]
                {
                    pr[0],
                    pr.Length > 1 ? pr[1] : 0,
                    pr.Length > 2 ? pr[2] : 0,
                };
                fwPr[i] = FixedWidthGetCachedArray(uniquePr, fixedWidthPr);
                int[] next = nextState[i];
                int nextLength = next.Length;
                fwNextState[i, 0] = (nextLength > 0) ? next[0] : sentinal;
                fwNextState[i, 1] = (nextLength > 1) ? next[1] : sentinal;
                fwNextState[i, 2] = (nextLength > 2) ? next[2] : sentinal;
                if (nextLength > 3)
                {
                    // only works for up to 3 transitions: abort now
                    fwPossible = false;
                    return;
                }
            }
        }
        private double[] FixedWidthGetCachedArray(List<double[]> cache, double[] array)
        {
            for (int i = 0; i < cache.Count; i++)
            {
                double[] cached = cache[i];
                if (cached[0] == array[0]
                    && cached[1] == array[1]
                    && cached[2] == array[2])
                {
                    return cached;
                }
            }
            cache.Add(array);
            return array;
        }
        #endregion
        #region TODO: optimisations
        // converge with floats before switching to double
        // coalesce identical choice.pr[] arrays
        // Try the iterative algorithm that requires a L + I + U form by splitting transitions from a state to itself into two states
        #endregion
        // should all be private but we're exposing for now to make testing easier
        public Dictionary<TState, int> lookup; // maps state to state index
        public TState[] index; // maps state index to state
        public Choice<TState>[] choice; // maps state index to choice made
        public int[][] nextState; // maps state index to choice and corresponding next state indexes
        private Dictionary<Choice<TState>, TState> firstChoiceState; // The first state in which given choice was encountered
    }
}