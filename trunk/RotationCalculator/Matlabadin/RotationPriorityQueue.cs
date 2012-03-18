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
            if (String.IsNullOrEmpty(queue)) return; // nothing to do for a rotation of nothing
            Match queueMatch = Regex.Match(">" + queue, @"^(?<element>>([^\[>\]]+(\[[^\]]+\])*))*$"); // add a > to the start of the queue then separate
            /*  Regular Expression dissection for Theck's sanity
             *      @"                         #designate as a literal string
             *      ^                          #signify the position before the first character
             *      (?<element>                #start the first group, this labels it "element" so we can pick it out later
             *          >                      #look for the '>' character (signifies start of an element)
             *          (                      #start the second group (ability plus numerical HP modifier)
             *              [^\[>\]]+          #don't match (^) open bracket ([), greater than (>), or close bracket (]) - this picks up alphanumerics (i.e. 'SotR5') and ^ (i.e. "^WB")
             *              (                  #start the third group (conditionals)
             *                  \[             #match open bracket
             *                      [^\]]+     #don't match anything with one or more closed brackets in-between the open and closed (this prevents i.e. [HP=3][buffWB=0] from matching as one conditional)
             *                  \]             #match close bracket
             *              )*                 #close third group, * signifies optional (0 or more instances) - this allows for SotR5 as well as SotR5[x][y][z] and anything in between
             *          )                      #close second group, not optional - we need to have something here, otherwise there's no ability defined
             *      )*                         #close first group, * signifies optional (0 or more instances) - this allows for ability chains (i.e. '>J>AS>SotR5[buffSS=0]' contains 3 instances of group 1)
             *      $                          #signify the position after last character
             *      "                          #end string
             *  Summary: we look for groups of ( > ( XXX# ( [cond1][cond2] ) ) ), i.e. ">J[HP<5]" or ">^WB[buffWB<0]" or ">Sotr5[HP<4]".  
             *  Group 3 (conditionals) are optional, Group 2 (ability designation) is not.  Group 1 is optional, in theory, but it would mean an empty queue if it were.
             */
            foreach (string rawActionString in queueMatch.Groups["element"].Captures.Cast<Capture>().Select(c => c.Value))  //queueMatch.Groups["element"] isolates the list of Group 1 captures (i.e. each >^XX#[cond] entry), this converts each capture into a raw string for processing
            {
                var conditions = new List<Func<GraphParameters<TState>, IStateManager<TState>, TState, bool>>();
                Match actionMatch = Regex.Match(rawActionString, @"^>(?<ability>[^\[>\]0-9]+)(?<numericSuffix>[0-9]*)(?<conditional>\[[^\]]+\])*$");
                /* Regular Expression dissection for Theck's sanity
                 *          @"                              #designate a literal string
                 *          ^                               #position of first character
                 *          >                               #each capture starts with >, we discard that
                 *          (?<ability>                     #Group 1 is the ability 
                 *              [^\[>\]0-9]+                #ability is a sequence of characters which contains no (^) [, >, ] characters or numbers (0-9); one or more characters in length (+)
                 *          )
                 *          (?<numericSuffix>               #Group 2 is the numeric suffix
                 *              [0-9]*                      #numeric suffix contains a sequence of zero or more (*) numbers
                 *          )
                 *          (?<conditional>                 #Group 3 is conditionals
                 *              \[[^\]]+\]                  #a conditional has the form [x], where x contains no bracket characters ( [^\] = no ])
                 *          )*                              #close group, look for zero or more (*) sequential group 3 entries (conditionals)
                 *          $"                              #signify position after last character, end string
                 * 
                 */
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
                //convert numerical suffix to conditional (i.e. SotR5 => SotR[HP>=5])
                if (!String.IsNullOrEmpty(numericSuffixString))  
                {
                    conditionalStrings.Add(String.Format("[HP>={0}]", numericSuffixString));
                }
                List<Ability> conditionAbilityList;
                bool hpConditionEncountered;
                conditions.AddRange(ProcessConditions(conditionalStrings, out conditionAbilityList, out hpConditionEncountered));  //process conditionals

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