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
        public Dictionary<string, double> CalculateResults(double[] pr, out double inqUptime)
        {
            // t = time in state
            // pr = probability of being in state
            // sumtpr = sum(t*pr)
            // pr(choice) = sum[all state=choice](pr) / sumtpr
            Dictionary<string, double> cps = new Dictionary<string, double>();
            double sumtpr = 0;
            double suminqtpr = 0;
            for (int i = 0; i < index.Length; i++)
            {
                Choice<TState> c = choice[i];
                double t = c.stepsDuration * GraphParameters.StepDuration;
                double inqt = c.inqDuration * GraphParameters.StepDuration;
                double tpr = t * pr[i];
                sumtpr += tpr;
                suminqtpr += inqt * pr[i];
                if (c.Ability != Ability.Nothing)
                {
                    double currentPr;
                    if (!cps.TryGetValue(c.Action, out currentPr)) currentPr = 0;
                    cps[c.Action] = currentPr + pr[i];
                }
            }
            inqUptime = suminqtpr / sumtpr;
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
            double[] nextPr = new double[length];
            for (int i = 0; i < length; i++)
            {
                double statePr = pr[i];
                int[] next = nextState[i];
                Choice<TState> c = choice[i];
                for (int j = 0; j < next.Length; j++)
                {
                    nextPr[next[j]] += statePr * c.pr[j];
                }
            }
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
        // should all be private but we're exposing for now to make testing easier
        public Dictionary<TState, int> lookup; // maps state to state index
        public TState[] index; // maps state index to state
        public Choice<TState>[] choice; // maps state index to choice made
        public int[][] nextState; // maps state index to choice and corresponding next state indexes
        private Dictionary<Choice<TState>, TState> firstChoiceState; // The first state in which given choice was encountered
    }
}
