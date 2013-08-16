using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    /// <summary>
    /// Simulates all possible transitions and calculates
    /// mean casts for all possible scenarios.
    /// </summary>
    public class MatlabadinSimTree<TState>
    {
        public IStateManager<TState> StateManager { get; private set; }
        public GraphParameters<TState> GraphParameters { get; private set; }
        public MatlabadinSimTree(GraphParameters<TState> gp, IStateManager<TState> sm)
        {
            this.GraphParameters = gp;
            this.StateManager = sm;
        }
        public ActionSummary Calculate(int simDurationInSteps)
        {
            IDictionary<TState, FrontierNode> frontier = new Dictionary<TState, FrontierNode>();
            frontier.Add(StateManager.InitialState(), new FrontierNode());
            for (int currentStep = 0; currentStep < simDurationInSteps; currentStep++)
            {
                IDictionary<TState, FrontierNode> newFrontier = new Dictionary<TState, FrontierNode>();
                while (frontier.Any())
                {
                    KeyValuePair<TState, FrontierNode> currentNode = frontier.First();
                    frontier.Remove(currentNode.Key);

                    // TODO: cache transitions
                    StateTransition<TState> transition = new StateTransition<TState>(GraphParameters, StateManager, currentNode.Key);
#if !NOSANITYCHECKS
                    if (transition.Choice.stepsDuration > 1) throw new Exception("Sanity failure: transition not a single step");
#endif
                    IDictionary<TState, FrontierNode> targetFrontier = transition.Choice.stepsDuration == 0 ? frontier : newFrontier;
                    for (int i = 0; i < transition.NextStates.Length; i++)
                    {
                        TState nextState = transition.NextStates[i];
                        FrontierNode nextNode = currentNode.Value.Append(transition.Choice, i);
                        if (!targetFrontier.ContainsKey(nextState))
                        {
                            // Add to new frontier node
                            targetFrontier[nextState] = nextNode;
                        }
                        else
                        {
                            // Merge with existing frontier node
                            targetFrontier[nextState] = targetFrontier[nextState].MergeWith(nextNode);
                        }
                    }
                }
                frontier = newFrontier;
            }
            // Aggregate results
            FrontierNode result = Aggregate(frontier.Values);
#if !NOSANITYCHECKS
            if (Math.Abs(result.pr - 1.0) > 1e-7) throw new Exception("Sanity check failure: pr does not sum to 1");
#endif
            // Rescale output to match MatlabadinGraph casts/s output format
            double totalSeconds = simDurationInSteps * GraphParameters.StepDuration;
            return new ActionSummary
            {
                // TODO refactor Matlabadin.CalculateResults() buff uptime remapping so it can be used here
                //BuffUptime = result.buffUptime.Select(x => x / simDurationInSteps).ToArray(),
                Action = result.actionPr.ToDictionary(x => x.Key, x => x.Value / totalSeconds),
            };
        }
        private FrontierNode Aggregate(IEnumerable<FrontierNode> nodes)
        {
            // TODO: reduce floating point rounding errors introduced by unordered 
            FrontierNode result = new FrontierNode() { pr = 0, };
            foreach (FrontierNode node in nodes) result = result.MergeWith(node);
            return result;
        }
        private class FrontierNode
        {
            public FrontierNode()
            {
                this.pr = 1;
                this.actionPr = new Dictionary<string, double>();
                this.buffUptime = new double[(int)Buff.Count];
            }
            /// <summary>
            /// probability of being in this node
            /// </summary>
            public double pr;
            /// <summary>
            /// Total action contribution
            /// </summary>
            public Dictionary<string, double> actionPr;
            /// <summary>
            /// Total buff steps contribution
            /// </summary>
            public double[] buffUptime;
            public FrontierNode Append(Choice c, int n)
            {
                FrontierNode result = new FrontierNode();
                double transitionPr = this.pr * c.pr[n];
                result.pr = transitionPr;
                result.actionPr = this.actionPr;
                if (c.Action.Any())
                {
                    // set the pr contribution as the previous node contribution * the pr of transitioning to this new node
                    result.actionPr = new Dictionary<string, double>(this.actionPr.Keys.Count + c.Action.Length);
                    foreach (var kvp in this.actionPr)
                    {
                        result.actionPr[kvp.Key] = kvp.Value * c.pr[n];
                    }
                    // Add the contribution of the action(s) performed by this transition
                    foreach (string action in c.Action)
                    {
                        if (result.actionPr.ContainsKey(action)) result.actionPr[action] += transitionPr;
                        else result.actionPr[action] = transitionPr;
                    }
                }
                result.buffUptime = this.buffUptime;
                if (c.stepsDuration > 0)
                {
                    result.buffUptime = result.buffUptime.Zip(
                        c.buffDuration.Select(x => x * transitionPr * c.stepsDuration),
                        (a, b) => a * c.pr[n] + b).ToArray();
                }
                return result;
            }
            public FrontierNode MergeWith(FrontierNode node)
            {
                FrontierNode result = new FrontierNode();
                result.pr = this.pr + node.pr;
                result.buffUptime = this.buffUptime.Zip(node.buffUptime, (a, b) => a + b).ToArray();
                result.actionPr = new Dictionary<string, double>(this.actionPr);
                foreach (string actionKey in node.actionPr.Keys)
                {
                    if (result.actionPr.ContainsKey(actionKey)) result.actionPr[actionKey] += node.actionPr[actionKey];
                    else result.actionPr[actionKey] = node.actionPr[actionKey];
                }
                return result;
            }
        }
    }
}
