using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace Matlabadin
{
    public class RotationPriorityQueue
    {
        public static Func<ulong, GraphParameters, Ability> CreateRotationPriorityQueueNextStateFunction(string queue)
        {
            RotationPriorityQueue rpq = new RotationPriorityQueue(queue);
            return (state, gp) => rpq.ActionToTake(state, gp);
        }
        public Ability ActionToTake(ulong state, GraphParameters gp)
        {
            for (int i = 0; i < abilityQueue.Count; i++)
            {
                Ability ability = abilityQueue[i];
                // all conditionals must be met
                if (!abilityConditionals[i].All(f => f(state, gp))) continue;
                // ability must be off CD
                if (StateHelper.CooldownRemaining(state, ability, gp) == 0)
                {
                    return ability;
                }
            }
            return Ability.Nothing;
        }
        public RotationPriorityQueue(string queue)
        {
            abilityQueue = new List<Ability>();
            abilityConditionals = new List<List<Func<ulong, GraphParameters, bool>>>();
            string remainingQueue = queue;
            int i = 0;
            while (!String.IsNullOrEmpty(remainingQueue))
            {
                Match actionMatch = Regex.Match(remainingQueue, @"^(?<first>[^\[>\]]+(\[[^\]]+\])*)(>([^\[>\]]+(\[[^\]]+\])*))*");
                if (!actionMatch.Success) throw new InvalidOperationException(String.Format("Invalid rotation {0}", queue));
                abilityConditionals.Add(new List<Func<ulong, GraphParameters, bool>>());

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
                    Func<ulong, GraphParameters, int> getRemaining;
                    if (type == "cd")
                    {
                        Ability a = (Ability)Enum.Parse(typeof(Ability), conditional);
                        getRemaining = (state, gp) => StateHelper.CooldownRemaining(state, a, gp);
                    }
                    else //if (type == "buff")
                    {
                        Buff b = (Buff)Enum.Parse(typeof(Buff), conditional);
                        getRemaining = (state, gp) => StateHelper.TimeRemaining(state, b, gp);
                    }
                    Func<ulong, GraphParameters, bool> condition = null;
                    switch (operation)
                    {
                        case "=":  condition = (state, gp) => getRemaining(state, gp) == (int)(value / gp.StepDuration); break;
                        case "==": condition = (state, gp) => getRemaining(state, gp) == (int)(value / gp.StepDuration); break;
                        case ">":  condition = (state, gp) => getRemaining(state, gp) >  (int)(value / gp.StepDuration); break;
                        case ">=": condition = (state, gp) => getRemaining(state, gp) >= (int)(value / gp.StepDuration); break;
                        case "<":  condition = (state, gp) => getRemaining(state, gp) <  (int)(value / gp.StepDuration); break;
                        case "<=": condition = (state, gp) => getRemaining(state, gp) <= (int)(value / gp.StepDuration); break;
                    }
                    abilityConditionals[i].Add(condition);
                    action = action.Replace(conditionMatch.Value, "");
                }
                switch (action) // Special ability-specific conditions go here
                {
                    case "Inq":
                    case "WoG":
                    case "SotR":
                        abilityConditionals[i].Add((state, gp) => StateHelper.HP(state, gp) >= 3);
                        break;
                    case "Inq2":
                    case "WoG2":
                    case "SotR2":
                        abilityConditionals[i].Add((state, gp) => StateHelper.HP(state, gp) >= 2);
                        action = action.Substring(0, action.Length - 1);
                        break;
                    case "Inq1":
                    case "WoG1":
                    case "SotR1":
                        abilityConditionals[i].Add((state, gp) => StateHelper.HP(state, gp) >= 1);
                        action = action.Substring(0, action.Length - 1);
                        break;
                    case "AS+":
                        // Use AS if it will generate HP
                        abilityConditionals[i].Add((state, gp) => StateHelper.TimeRemaining(state, Buff.GC, gp) > 0);
                        action = action.Substring(0, action.Length - 1);
                        break;
                }
                Ability ability = (Ability)Enum.Parse(typeof(Ability), action);
                abilityQueue.Add(ability);
                // move on to the next item in the queue
                remainingQueue = remainingQueue.Substring(rawActionString.Length);
                remainingQueue = remainingQueue.Trim('>');
                i++;
            }
        }
        private List<Ability> abilityQueue;
        private List<List<Func<ulong, GraphParameters, bool>>> abilityConditionals;
    }
}
