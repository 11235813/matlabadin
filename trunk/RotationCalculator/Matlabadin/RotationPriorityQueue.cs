﻿using System;
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
            if (String.IsNullOrEmpty(queue)) return; // nothing to do for a rotation of nothing
            Match queueMatch = Regex.Match(">" + queue, @"^(?<element>>([^\[>\]]+(\[[^\]]+\])*))*$"); // add a > to the start of the queue then separate
            foreach (string rawActionString in queueMatch.Groups["element"].Captures.Cast<Capture>().Select(c => c.Value))
            {
                var conditions = new List<Func<GraphParameters<TState>, IStateManager<TState>, TState, bool>>();
                Match actionMatch = Regex.Match(rawActionString, @"^>(?<ability>[^\[>\]0-9]+)(?<numericSuffix>[0-9]*)(?<conditional>\[[^\]]+\])*$");
                if (!actionMatch.Success) throw new InvalidOperationException(String.Format("Invalid rotation {0}", queue));

                string numericSuffixString = actionMatch.Groups["numericSuffix"].Value;
                string abilityString = actionMatch.Groups["ability"].Value;
                List<string> conditionalStrings = actionMatch.Groups["conditional"].Captures.Cast<Capture>().Select(c => c.Value).ToList();
                // Special ability shorthands go here
                switch (abilityString)
                {
                    case "AS+":
                        // Use AS if it will generate HP
                        conditionalStrings.Add("[buffGC>0]");
                        conditions.Add((gp, sm, state) => sm.TimeRemaining(state, Buff.GC) > 0);
                        abilityString = "AS";
                        break;
                    case "^WB":
                        // If keeping up WB, we need to adjust for the HotR cooldown to keep full uptime
                        abilityString = "HotR";
                        conditionalStrings.Add("[buffWB<4.5]");
                        break;
                    case "^SS":
                    case "^EF":
                        // TODO: do we EF1 or EF3 when EF runs out?
                        abilityString = abilityString.Substring(1);
                        conditionalStrings.Add(String.Format("[buff{0}=0]", abilityString));
                        break;
                }
                if (!String.IsNullOrEmpty(numericSuffixString))
                {
                    conditionalStrings.Add(String.Format("[HP>={0}]", numericSuffixString));
                }
                List<Ability> conditionAbilityList;
                bool hpConditionEncountered;
                conditions.AddRange(ProcessConditions(conditionalStrings, out conditionAbilityList, out hpConditionEncountered));

                Ability ability = (Ability)Enum.Parse(typeof(Ability), abilityString);
                switch (ability) // Special ability-specific conditions go here
                {
                    case Ability.SS:
                    case Ability.SotR:
                        // Requires 3 HP to use
                        conditions.Add((gp, sm, state) => sm.HP(state) >= 3);
                        break;
                    case Ability.EF:
                    case Ability.WoG:
                        // Requires 1 HP to use
                        conditions.Add((gp, sm, state) => sm.HP(state) >= 1);
                        // no HP conditions on EF or WoG = default to 3 HP usage
                        if (!hpConditionEncountered)
                        {
                            conditions.Add((gp, sm, state) => sm.HP(state) >= 3);
                        }
                        break;
                }
                if (!conditionAbilityList.Contains(ability))
                {
                    // Ability must be off CD if no CD specified
                    // Delayed casts are modelled by specifying a cooldown conditional (eg CS[cdCS<=0.5])
                    conditions.Add((gp, sm, state) => sm.CooldownRemaining(state, ability) == 0);
                }
                // add to rotation
                abilityQueue.Add(ability);
                abilityConditionals.Add(conditions);
            }
        }

        private IEnumerable<Func<GraphParameters<TState>, IStateManager<TState>, TState, bool>>
            ProcessConditions(List<string> conditionalStrings, out List<Ability> conditionAbilityList, out bool hpConditionEncountered)
        {
            hpConditionEncountered = false;
            conditionAbilityList = new List<Ability>();
            var conditions = new List<Func<GraphParameters<TState>, IStateManager<TState>, TState, bool>>();
            foreach (string conditionString in conditionalStrings)
            {
                Match conditionMatch = Regex.Match(conditionString, @"^\[(?<type>(cd)|(buff|HP))(?<conditional>\w*)(?<operation>[><=]+)(?<value>\d*\.?\d*)\]$");
                string type = conditionMatch.Groups["type"].Value;
                string conditional = conditionMatch.Groups["conditional"].Value;
                string operation = conditionMatch.Groups["operation"].Value;
                double value = Double.Parse(conditionMatch.Groups["value"].Value);
                Func<GraphParameters<TState>, IStateManager<TState>, TState, double> getStateValue;
                if (type == "HP")
                {
                    getStateValue = (gp, sm, state) => sm.HP(state);
                    hpConditionEncountered = true;
                }
                else if (type == "cd")
                {
                    Ability a = (Ability)Enum.Parse(typeof(Ability), conditional);
                    getStateValue = (gp, sm, state) => sm.CooldownRemaining(state, a) * gp.StepDuration;
                    conditionAbilityList.Add(a);
                }
                else if (type == "buff")
                {
                    Buff b = (Buff)Enum.Parse(typeof(Buff), conditional);
                    getStateValue = (gp, sm, state) => sm.TimeRemaining(state, b) * gp.StepDuration;
                }
                else
                {
                    throw new ArgumentException(String.Format("Unable to process conditional {0} with unknown type {1}", conditionString, type));
                }
                Func<GraphParameters<TState>, IStateManager<TState>, TState, bool> condition = null;
                switch (operation)
                {
                    case "=": condition = (gp, sm, state) => getStateValue(gp, sm, state) == value; break;
                    case "==": condition = (gp, sm, state) => getStateValue(gp, sm, state) == value; break;
                    case ">": condition = (gp, sm, state) => getStateValue(gp, sm, state) > value; break;
                    case ">=": condition = (gp, sm, state) => getStateValue(gp, sm, state) >= value; break;
                    case "<": condition = (gp, sm, state) => getStateValue(gp, sm, state) < value; break;
                    case "<=": condition = (gp, sm, state) => getStateValue(gp, sm, state) <= value; break;
                }
                if (condition == null) throw new ArgumentException("Unknown conditional operator {0}", operation);
                conditions.Add(condition);
            }
            return conditions;
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