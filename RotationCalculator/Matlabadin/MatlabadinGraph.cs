using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.IO;

namespace Matlabadin
{
    /// <summary>
    /// FSM graph for the given graph parameters.
    /// Generates a graph from the given parameters and calculates probabilities.
    /// </summary>
    /// <remarks>Graphs that only differ in hit can be cloned and for new
    /// values of hit.</remarks>
    public class MatlabadinGraph<TState>
    {
        // default constructor, called from Program.GenerateGraph
        public MatlabadinGraph(GraphParameters<TState> gp, IStateManager<TState> sm)
        {
            this.GraphParameters = gp;
            this.StateManager = sm;
            GenerateGraph();
#if !NOSANITYCHECKS
            SanityCheck();
#endif
        }

        // sanity checks on the graph
        private void SanityCheck()
        {
            if (this.index.Length != this.lookup.Count) throw new Exception("Sanity failure: lookup size mismatch");
            if (this.index.Length != this.nextState.Length) throw new Exception("Sanity failure: nextState size mismatch");
            if (this.index.Length != this.choice.Length) throw new Exception("Sanity failure: choice size mismatch");
            foreach (Choice c in this.choice)
            {
                if (c == null)
                {
                    throw new Exception("Sanity failure: null choice");
                }
                if (!firstChoiceState.ContainsKey(c))
                {
                    throw new Exception(String.Format("Sanity failure: missing choice {0} in firstChoiceState", c));
                }   
            }
            foreach (Choice key in this.firstChoiceState.Keys)
            {
                if (firstChoiceState[key].Item1 != key) throw new Exception("Sanity failure: firstChoiceState maps choice to another choice");
            }
            for (int i = 0; i < index.Length; i++)
            {
                if (nextState[i].Length == 0) throw new Exception(String.Format("Sanity failure: no tranistion out of {0}th state", i));
                if (nextState[i].Length != choice[i].pr.Length) throw new Exception(String.Format("Sanity failure: {0}th state choice pr has {1} transitions, expected {2}", i, choice[i].pr.Length, nextState[i].Length));
                if (Math.Abs(choice[i].pr.Sum() - 1.0) > 1e-10) throw new Exception(String.Format("Sanity failure: {0}th state transition pr sum to {0}", i, choice[i].pr.Sum()));
                if (choice[i].pr.Any(p => p == 0)) throw new Exception(String.Format("Sanity failure: {0}th state has zero probability transition", i));
                for (int j = 0; j < nextState[i].Length; j++)
                {
                    // transitions are to valid states
                    if (nextState[i][j] < 0 || nextState[i][j] >= Size) throw new Exception(String.Format("Sanity failure: {0}th state has invalid transition to state {1}", i, nextState[i][j]));
                }
            }
        }

        /// <summary>
        /// Clones a given graph.
        /// </summary>
        /// <remarks>Cloning will only succeed if the graphs only differ in their transition probabilities.
        /// That is, they only differ in MeleeHit and SpellHit.</remarks>
        /// <param name="graph">Graph to clone.</param>
        /// <param name="gp">New parameters</param>
        public MatlabadinGraph(MatlabadinGraph<TState> graph, GraphParameters<TState> gp)
        {
            if (!graph.GraphParameters.HasSameShape(gp)) throw new ArgumentException("Graphs do not have the same shape");
            try
            {
                this.GraphParameters = gp;
                this.StateManager = graph.StateManager; // reuse the statemanager from the old graph
                this.lookup = graph.lookup;
                this.index = graph.index;
                this.nextState = graph.nextState;
                // replace the choices in the existing graph with the new choices
                // Since the graph has the same shape we don't have to generate the entire graph
                this.firstChoiceState = new Dictionary<Choice, Tuple<Choice, TState>>();
                Dictionary<Choice, Choice> choiceLookup = new Dictionary<Choice, Choice>();
                foreach (var kvp in graph.firstChoiceState.Values)
                {
                    Choice oldChoice = kvp.Item1;
                    TState state = kvp.Item2;
                    Choice newChoice = StateTransition<TState>.CalculateTransition(GraphParameters, StateManager, state).Choice;
                    this.firstChoiceState.Add(newChoice, new Tuple<Choice, TState>(newChoice, state));
                    choiceLookup.Add(oldChoice, newChoice);
                }
                this.choice = new Choice[graph.Size];
                for (int i = 0; i < this.choice.Length; i++)
                {
                    this.choice[i] = choiceLookup[graph.choice[i]];
                }
#if !NOSANITYCHECKS
                SanityCheck();
#endif
            }
            catch (Exception e)
            {
                throw new Exception(String.Format("Error cloning [{0}] to [{1}]", graph.GraphParameters.ParametersToString(), gp.ParametersToString()), e);
            }
        }

        /// <summary>
        /// Number of distinct state in the graph
        /// </summary>
        public int Size { get { return index.Length; } }
        public GraphParameters<TState> GraphParameters { get; private set; }
        public IStateManager<TState> StateManager { get; private set; }

        /// <summary>
        /// Generates the state transition graph for the given graph parameters; called by the constructor, calls StateTransition.CalculateTransition
        /// </summary>
        private void GenerateGraph()
        {
            TState initialState = StateManager.InitialState();
            Dictionary<TState, int> lookup = new Dictionary<TState, int>();
            List<TState> index = new List<TState>();
            List<Choice> choice = new List<Choice>();
            List<int[]> nextState = new List<int[]>();
            firstChoiceState = new Dictionary<Choice, Tuple<Choice, TState>>();
            index.Add(initialState);
            lookup[initialState] = 0;
            while (index.Count() > nextState.Count())
            {
                TState currentState = index[nextState.Count()];
                //Console.WriteLine(StateHelper<TState>.StateToString(GraphParameters, StateManager, currentState));
                StateTransition<TState> transition = StateTransition<TState>.CalculateTransition(GraphParameters, StateManager, currentState);
                Choice c = transition.Choice;
                int[] currentNextStateIndex = new int[transition.NextStates.Length];
                for (int i = 0; i < transition.NextStates.Length; i++)
                {
                    if (!lookup.TryGetValue(transition.NextStates[i], out currentNextStateIndex[i]))
                    {
                        currentNextStateIndex[i] = index.Count();
                        index.Add(transition.NextStates[i]);
                        lookup[transition.NextStates[i]] = currentNextStateIndex[i];
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

        private Choice LookupStateChoice(Choice choice, TState state)
        {
            if (firstChoiceState.ContainsKey(choice))
            {
                // return the cached value
                return firstChoiceState[choice].Item1;
            }
            else
            {
                // add to cache as this is the first state in which we have made this choice
                firstChoiceState[choice] = new Tuple<Choice,TState>(choice, state);
                return choice;
            }
        }

        /// <summary>
        /// Calculates state probabilities and outputs aggregated ability usage information.
        /// </summary>
        /// <param name="pr">initial estimation</param>
        /// <param name="inqUptime">Inquistion uptime</param>
        /// <param name="jotwUptime">JotW uptime</param>
        /// <returns>Action frequency table</returns>
        public ActionSummary CalculateResults(double[] pr)
        {
            // t = time in state
            // pr = probability of being in state
            // sumtpr = sum(t*pr)
            // pr(choice) = sum[all state=choice](pr) / sumtpr
            Dictionary<string, double> cps = new Dictionary<string, double>();
            double sumtpr = 0;
            double[] sumbufftpr = new double[GraphParameters.BuffTrackingArraySize];
            for (int i = 0; i < index.Length; i++)
            {
                Choice c = choice[i];
                double t = c.stepsDuration * GraphParameters.StepDuration;
                double tpr = t * pr[i];
                sumtpr += tpr;
                foreach (string action in c.Action)
                {
                    double currentPr;
                    if (!cps.TryGetValue(action, out currentPr)) currentPr = 0;
                    cps[action] = currentPr + pr[i];
                }
                // aggregate buff durations
                for (int j = 0; j < GraphParameters.BuffTrackingArraySize; j++)
                {
                    if (c.buffDuration[j] > c.stepsDuration) throw new Exception("Sanity check failure: buff duration exceeds step duration");
                    sumbufftpr[j] += pr[i] * GraphParameters.StepDuration * c.buffDuration[j];
                }
            }
            cps.Remove("Nothing"); // Nothing casts are not a meaningful measure of anything
            double[] buffUptimeValues = sumbufftpr.Select(buffsumtpr => buffsumtpr / sumtpr).ToArray();
            double[][] buffUptime = new double[(int)Buff.UptimeTrackedBuffs][];
            int offset = 0;
            for (int i = 0; i < (int)Buff.UptimeTrackedBuffs; i++)
            {
                Buff b = (Buff)i;
                int maxStacks = GraphParameters.MaxBuffStacks(b);
                if (maxStacks == 0) continue;
                buffUptime[i] = buffUptimeValues.Skip(offset).Take(maxStacks).ToArray();
                offset += maxStacks;
            }
            return new ActionSummary()
            {
                Action = cps.ToDictionary(kvp => kvp.Key, kvp => kvp.Value / sumtpr),
                BuffStacksUptime = buffUptime,
            };
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
            int maxIterations = 32768,
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
        /// <summary>
        /// Calculates the maximum relative and absolute delta between the two state probability sets
        /// </summary>
        /// <param name="pr1">First set</param>
        /// <param name="pr2">Second set</param>
        /// <param name="relError">Maximum relative difference</param>
        /// <param name="absError">Maximum absolute difference</param>
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
        /// previous probabilities are ignored, 1 indicates no weight for the next state state probabilities.</param>
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
                Choice c = choice[i];
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
                Choice c = choice[sourceIndex];
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
                Choice c = choice[sourceIndex];
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
                Choice c = choice[sourceIndex];
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
                Choice c = choice[sourceIndex];
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
        // DONE[UpdateFromFixedWidthNextState] coalesce identical choice.pr[] arrays
        // Try the iterative algorithm that requires a L + I + U form by splitting transitions from a state to itself into two states
        #endregion
        // should all be private but we're exposing for now to make testing easier
        public Dictionary<TState, int> lookup; // maps state to state index
        public TState[] index; // maps state index to state
        public Choice[] choice; // maps state index to choice made
        public int[][] nextState; // maps state index to choice and corresponding next state indexes
        private Dictionary<Choice, Tuple<Choice, TState>> firstChoiceState; // The first state in which given choice was encountered
        #region Debugging helpers
        public void GraphToCsv(TextWriter stream, double[] pr)
        {
            // Header line
            stream.Write("Index,Pr,Action,StepsDuration,HP");
            for (int i = 0; i < (int)Ability.Count; i++)
            {
                stream.Write(',');
                stream.Write(((Ability)i).ToString());
            }
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                stream.Write(',');
                stream.Write(((Buff)i).ToString());
                stream.Write(',');
                stream.Write(((Buff)i).ToString());
                stream.Write(" Stacks");
            }
            for (int i = 0; i < 3; i++)
            {
                stream.Write(",TransitionPr");
                stream.Write(i);
                stream.Write(",TransitionNextState");
                stream.Write(i);
            }
            stream.WriteLine();
            for (int i = 0; i < Size; i++)
            {
                StateToCsv(stream, i, pr[i]);
            }
        }
        private void StateToCsv(TextWriter stream, int offset, double pr)
        {
            if (offset >= this.Size) throw new ArgumentException();
            TState state = this.index[offset];
            stream.Write(offset);
            stream.Write(',');
            stream.Write(pr);
            stream.Write(',');
            if (choice[offset].Action.Length == 0)
            {
                stream.Write("Nothing");
            }
            else
            {
                stream.Write(choice[offset].Action[0]);
                for (int i = 1; i < choice[offset].Action.Length; i++)
                {
                    stream.Write('>');
                    stream.Write(choice[offset].Action[i]);
                }
            }
            stream.Write(',');
            stream.Write(choice[offset].stepsDuration);
            // dump state
            stream.Write(',');
            stream.Write(StateManager.HP(state));
            for (int i = 0; i < (int)Ability.Count; i++)
            {
                stream.Write(',');
                stream.Write(StateManager.CooldownRemaining(state, (Ability)i));
            }
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                stream.Write(',');
                stream.Write(StateManager.TimeRemaining(state, (Buff)i));
                stream.Write(',');
                stream.Write(StateManager.Stacks(state, (Buff)i));
            }
            // Write transitions in order of likelyhood
            foreach (var transition in choice[offset].pr
                .Select((pri, i) =>
                    new {
                        Pr = pri,
                        NextState = nextState[offset][i],
                    })
                .OrderByDescending(x => x.Pr))
            {
                stream.Write(',');
                stream.Write(transition.Pr);
                stream.Write(',');
                stream.Write(transition.NextState);
            }
            stream.WriteLine();
        }
        public string StateToString(TState state)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendFormat("HP{0}", StateManager.HP(state));
            string singleColumnNumberFormat = ",{1,1:#}";
            string doubleColumnNumberFormat = ",{1,2:##}";
            for (int offset = (int)Ability.CooldownIndicator + 1; offset < (int)Ability.Count; offset++)
            {
                sb.AppendFormat(GraphParameters.AbilityCooldownInSteps((Ability)offset) >= 10 ? doubleColumnNumberFormat : singleColumnNumberFormat,
                    (Ability)offset,
                    StateManager.CooldownRemaining(state, (Ability)offset));
            }
            sb.Append(",");
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                sb.AppendFormat(GraphParameters.BuffDurationInSteps((Buff)i) >= 10 ? doubleColumnNumberFormat : singleColumnNumberFormat,
                    (Buff)i,
                    StateManager.TimeRemaining(state, (Buff)i));
            }
            return sb.ToString();
        }
        #endregion
    }
}