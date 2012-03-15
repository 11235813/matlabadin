using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace Matlabadin
{
    /// <summary>
    /// RotationPriorityQueue takes a 'rotation' string and determines
    /// which ability would be used by that rotation in the given state.
    /// 
    /// Rotations strings consist of a > seperated list of abilities
    /// each with zero or more conditionals. Ability capitalisation
    /// and spelling must match that of Ability.cs. The ability
    /// Nothing performs no action for the given state.
    /// 
    /// Holy Power: Abilities that use holy power can be post-pended
    /// with the minimum holy power required for the ability to be used.
    /// The default is 3 holy power.
    /// 
    /// Conditionals: conditionals take the following form:
    /// [<type><Ability><op><value>]
    /// where
    /// type is "buff" or "cd" or "HP" (if "HP", ability is omitted)
    /// op is one of < > <= >= = 
    /// value is a numeric value
    /// 
    /// Example: HW[cdCS>0][buffGC>1]>CS[buffInq>0]>Cons[HP=2]>Inq2
    ///  - will use Holy Wrath if Holy Wrath and Crusader Strike are off cooldown and the Grand Crusader buff has at least 1 second remaining
    ///  - will use Crusader Strike if Crusader Strike is off cooldown and the Inquisition self-buff is active
    ///  - will use Consecration if Consecration is off cooldown and Holy Power is 2
    ///  - will use Inquisition if 2 or more holy power is available
    ///  - will do nothing if the above abilities were not used
    /// 
    /// Note that all abilities have an implicit condition that the
    /// cooldown of the ability in the current state is zero unless
    /// an explicit cooldown is specified, in which case the cast is
    /// delayed until the cooldown is up.
    /// 
    /// Example: CS[cdCS<=0.5]                                      >
    ///  - will cast Crusader Strike as soon as it is off cooldown if the CS cooldown is half a second or less
    ///  
    /// Buff uptime:
    /// A short-hand for keeping up a buff can be written using ^ and the buff name.
    /// Eg: ^WB>J casts HotR to ensure Weakening Blows uptime
    /// </summary>
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
                // Check for "keep up" operator
                if (action.StartsWith("^"))
                {
                    string buff = action.Substring(1);
                    if (buff.Contains("[")) buff = buff.Substring(0, action.IndexOf("[") - 1); // strip conditionals
                    switch (buff)
                    {
                        case "WB":
                            // If keeping up WB, we need to adjust for the HotR cooldown to keep full uptime
                            action = action.Replace("^WB", "HotR[buffWB<4.5]");
                            break;
                        case "SS":
                        case "EF": // TODO: do we EF1 or EF3 when EF runs out?
                            // Ability name same as buff name
                            action = action.Replace("^" + buff, buff + "[buff" + buff + "=0]");
                            break;
                        default:
                            throw new Exception("Mechanics for keeping up " + buff + " not yet implemented.");
                    }
                    // TODO keep up & numeric suffix (such as ^EF4) not supported together.
                    // To properly support this, we should change the regex and
                    // add capture groups to pull out the ability/buff
                    // and prefixes and suffixes.
                }
                // Process any conditionals, remove from action string
                while (action.Contains("["))
                {
                    action = ProcessConditional(i, conditionalAbilityList, action);
                }
                // Check for numeric suffic
                if (Char.IsNumber(action[action.Length - 1]))
                {
                    // Add holy power condition
                    int minHP = Int32.Parse(action.Substring(action.Length - 1));
                    abilityConditionals[i].Add((gp, sm, state) => sm.HP(state) >= minHP);
                    action = action.Substring(0, action.Length - 1);
                }
                else if (!rawActionString.Contains("HP"))
                {
                    // no HP conditions on EF or WoG = default to 3 HP usage
                    switch (action)
                    {
                        case "EF":
                        case "WoG":
                            abilityConditionals[i].Add((gp, sm, state) => sm.HP(state) >= 3);
                            break;
                    }
                }
                switch (action) // Special ability-specific conditions go here
                {
                    case "SS":
                    case "SotR":
                        abilityConditionals[i].Add((gp, sm, state) => sm.HP(state) >= 3);
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
                // move on to the next item in the queue
                remainingQueue = remainingQueue.Substring(rawActionString.Length);
                remainingQueue = remainingQueue.Trim('>');
                i++;
            }
        }

        private string ProcessConditional(int i, List<Ability> conditionalAbilityList, string action)
        {
            Match conditionMatch = Regex.Match(action, @"\[(?<type>(cd)|(buff|HP))(?<conditional>\w*)(?<operation>[><=]+)(?<value>\d*\.?\d*)\]");
            if (!conditionMatch.Success) throw new ArgumentException("Malformed conditional in rotation.");
            string type = conditionMatch.Groups["type"].Value;
            string conditional = conditionMatch.Groups["conditional"].Value;
            string operation = conditionMatch.Groups["operation"].Value;
            double value = Double.Parse(conditionMatch.Groups["value"].Value);
            Func<GraphParameters<TState>, IStateManager<TState>, TState, bool> condition;
            if (type == "HP")
            {
                condition = GetHPConditionalMethod(operation, value);
            }
            else
            {
                condition = GetCdBuffConditionalMethod(conditionalAbilityList, type, conditional, operation, value);
            }
            if (condition == null) throw new ArgumentException("Unknown conditional operator {0}", operation);
            abilityConditionals[i].Add(condition);
            action = action.Replace(conditionMatch.Value, "");
            return action;
        }
        private static Func<GraphParameters<TState>, IStateManager<TState>, TState, bool> GetHPConditionalMethod(string operation, double value)
        {
            Func<GraphParameters<TState>, IStateManager<TState>, TState, bool> condition = null;
            switch (operation)
            {
                case "=": condition = (gp, sm, state) => sm.HP(state) == (int)(value); break;
                case "==": condition = (gp, sm, state) => sm.HP(state) == (int)(value); break;
                case ">": condition = (gp, sm, state) => sm.HP(state) > (int)(value); break;
                case ">=": condition = (gp, sm, state) => sm.HP(state) >= (int)(value); break;
                case "<": condition = (gp, sm, state) => sm.HP(state) < (int)(value); break;
                case "<=": condition = (gp, sm, state) => sm.HP(state) <= (int)(value); break;
            }
            return condition;
        }
        private static Func<GraphParameters<TState>, IStateManager<TState>, TState, bool> GetCdBuffConditionalMethod(List<Ability> conditionalAbilityList, string type, string conditional, string operation, double value)
        {
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
            return condition;
        }
        public bool Contains(Ability a)
        {
            return abilityQueue.Contains(a);
        }
        public string PriorityQueue { get; private set; }
        private List<Ability> abilityQueue;
        private List<List<Func<GraphParameters<TState>, IStateManager<TState>, TState, bool>>> abilityConditionals;
    }
}