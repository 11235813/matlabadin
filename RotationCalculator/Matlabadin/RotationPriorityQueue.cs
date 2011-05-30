using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace Matlabadin
{
    public class RotationPriorityQueue<TState>
    {
        public Ability ActionToTake(GraphParameters<TState> gp, IStateManager<TState> sm, TState state)
        {
            for (int i = 0; i < abilityQueue.Count; i++)
            {
                Ability ability = abilityQueue[i];
                // all conditionals must be met
                if (abilityConditionals[i].All(f => f(gp, sm, state))) return ability;
            }
            return Ability.Nothing;
        }
        public RotationPriorityQueue(string queue)
        {
            this.PriorityQueue = queue;
            this.distinctAbilitiesInRotation = new List<Ability>();
            this.abilityQueue = new List<Ability>();
            this.abilityConditionals = new List<List<Func<GraphParameters<TState>, IStateManager<TState>, TState, bool>>>();
            ProcessQueueString(queue);
        }
        private void ProcessQueueString(string queue)
        {
            string remainingQueue = queue;
            int i = 0;
            while (!String.IsNullOrEmpty(remainingQueue))
            {
                List<Ability> conditionalAbilityList = new List<Ability>();
                Match actionMatch = Regex.Match(remainingQueue, @"^(?<first>[^\[>\]]+(\[[^\]]+\])*)(>([^\[>\]]+(\[[^\]]+\])*))*");
                if (!actionMatch.Success) throw new InvalidOperationException(String.Format("Invalid rotation {0}", queue));
                abilityConditionals.Add(new List<Func<GraphParameters<TState>, IStateManager<TState>, TState, bool>>());

                string rawActionString = actionMatch.Groups["first"].Value;
                string action = rawActionString;
                // replace shorthand conditional with their full
                if (action.StartsWith("i")) action = action.Substring(1) + "[buffInq=0]";
                if (action.StartsWith("I") && !action.StartsWith("Inq")) action = action.Substring(1) + "[buffInq>0]";
                if (action.StartsWith("sd")) action = action.Substring(2) + "[buffSD=0]";
                if (action.StartsWith("SD")) action = action.Substring(2) + "[buffSD>0]";
                while (action.Contains("["))
                {
                    Match conditionMatch = Regex.Match(action, @"\[(?<type>(cd)|(buff))(?<conditional>\w+)(?<operation>[><=]+)(?<value>\d*\.?\d*)\]");
                    if (!conditionMatch.Success) throw new ArgumentException("Malformed conditional in rotation.");
                    string type = conditionMatch.Groups["type"].Value;
                    string conditional = conditionMatch.Groups["conditional"].Value;
                    string operation = conditionMatch.Groups["operation"].Value;
                    double value = Double.Parse(conditionMatch.Groups["value"].Value);
                    Func<IStateManager<TState>, TState, int> getRemaining;
                    if (type == "cd")
                    {
                        Ability a = (Ability)Enum.Parse(typeof(Ability), conditional);
                        getRemaining = (sm, state) => sm.CooldownRemaining(state, a);
                        conditionalAbilityList.Add(a);
                    }
                    else //if (type == "buff")
                    {
                        Buff b = (Buff)Enum.Parse(typeof(Buff), conditional);
                        getRemaining = (sm, state) => sm.TimeRemaining(state, b);
                    }
                    Func<GraphParameters<TState>, IStateManager<TState>, TState, bool> condition = null;
                    switch (operation)
                    {
                        case "=": condition = (gp, sm, state) => getRemaining(sm, state) == (int)(value / gp.StepDuration); break;
                        case "==": condition = (gp, sm, state) => getRemaining(sm, state) == (int)(value / gp.StepDuration); break;
                        case ">": condition = (gp, sm, state) => getRemaining(sm, state) > (int)(value / gp.StepDuration); break;
                        case ">=": condition = (gp, sm, state) => getRemaining(sm, state) >= (int)(value / gp.StepDuration); break;
                        case "<": condition = (gp, sm, state) => getRemaining(sm, state) < (int)(value / gp.StepDuration); break;
                        case "<=": condition = (gp, sm, state) => getRemaining(sm, state) <= (int)(value / gp.StepDuration); break;
                    }
                    if (condition == null) throw new ArgumentException("Unknown conditional operator {0}", operation);
                    abilityConditionals[i].Add(condition);
                    action = action.Replace(conditionMatch.Value, "");
                }
                switch (action) // Special ability-specific conditions go here
                {
                    case "Inq":
                    case "WoG":
                    case "SotR":
                        abilityConditionals[i].Add((gp, sm, state) => sm.HP(state) >= 3);
                        break;
                    case "Inq2":
                    case "WoG2":
                    case "SotR2":
                        abilityConditionals[i].Add((gp, sm, state) => sm.HP(state) >= 2);
                        action = action.Substring(0, action.Length - 1);
                        break;
                    case "Inq1":
                    case "WoG1":
                    case "SotR1":
                        abilityConditionals[i].Add((gp, sm, state) => sm.HP(state) >= 1);
                        action = action.Substring(0, action.Length - 1);
                        break;
                    case "AS+":
                        // Use AS if it will generate HP
                        abilityConditionals[i].Add((gp, sm, state) => sm.TimeRemaining(state, Buff.GC) > 0);
                        action = action.Substring(0, action.Length - 1);
                        break;
                }
                Ability ability = (Ability)Enum.Parse(typeof(Ability), action);
                if (!conditionalAbilityList.Contains(ability))
                {
                    // Ability must be off CD if no CD specified
                    // Delayed casts are modelled by specifying a cooldown conditional (eg CS[cdCS<=0.5])
                    abilityConditionals[i].Add((gp, sm, state) => sm.CooldownRemaining(state, ability) == 0);
                }
                abilityQueue.Add(ability);
                distinctAbilitiesInRotation.Add(ability);
                // move on to the next item in the queue
                remainingQueue = remainingQueue.Substring(rawActionString.Length);
                remainingQueue = remainingQueue.Trim('>');
                i++;
            }
        }
        public bool Contains(Ability a)
        {
            return distinctAbilitiesInRotation.Contains(a);
        }
        public string PriorityQueue { get; private set; }
        private List<Ability> distinctAbilitiesInRotation;
        private List<Ability> abilityQueue;
        private List<List<Func<GraphParameters<TState>, IStateManager<TState>, TState, bool>>> abilityConditionals;
    }
}