using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

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
            for (int i = 0; i < pq.Length; i++)
            {
                string action = pq[i];
                // check for buff present/not present ability prefixes
                if (action.StartsWith("I", StringComparison.InvariantCultureIgnoreCase) && !action.StartsWith("Inq"))
                {
                    bool buffMustBeActive = action[0] == 'I';
                    action = action.Substring(1);
                    int timeRemaining = StateHelper.TimeRemaining(state, Buff.INQ, gp);
                    if (buffMustBeActive && timeRemaining == 0) continue; // Inq with no buff
                    if (!buffMustBeActive && timeRemaining != 0) continue; // Inq with buff
                }
                if (action.StartsWith("SD", StringComparison.InvariantCultureIgnoreCase))
                {
                    bool buffMustBeActive = action[0] == 'S';
                    action = action.Substring(2);
                    int timeRemaining = StateHelper.TimeRemaining(state, Buff.SD, gp);
                    if (buffMustBeActive && timeRemaining == 0) continue; // SD with no buff
                    if (!buffMustBeActive && timeRemaining != 0) continue; // sd with buff
                }
                switch (action)
                {
                    case "SotR":
                        if (StateHelper.HP(state, gp) >= 3) return Ability.SotR;
                        break;
                    case "SotR2":
                        if (StateHelper.HP(state, gp) >= 2) return Ability.SotR;
                        break;
                    case "CS":
                        if (StateHelper.CooldownRemaining(state, Ability.CS, gp) == 0) return Ability.CS;
                        break;
                    case "WoG":
                        if (StateHelper.HP(state, gp) >= 3 &&
                            StateHelper.CooldownRemaining(state, Ability.WoG, gp) == 0) return Ability.WoG;
                        break;
                    case "HotR":
                        if (StateHelper.CooldownRemaining(state, Ability.HotR, gp) == 0) return Ability.HotR;
                        break;
                    case "HoW":
                        if (StateHelper.CooldownRemaining(state, Ability.HoW, gp) == 0) return Ability.HoW;
                        break;
                    case "HW":
                        if (StateHelper.CooldownRemaining(state, Ability.HW, gp) == 0) return Ability.HW;
                        break;
                    case "Inq":
                        if (StateHelper.HP(state, gp) >= 3 && 
                            StateHelper.CooldownRemaining(state, Ability.Inq, gp) == 0) return Ability.Inq;
                        break;
                    case "Inq2":
                        if (StateHelper.HP(state, gp) >= 2 &&
                            StateHelper.CooldownRemaining(state, Ability.Inq, gp) == 0) return Ability.Inq;
                        break;
                    case "Cons":
                        if (StateHelper.CooldownRemaining(state, Ability.Cons, gp) == 0) return Ability.Cons;
                        break;
                    case "J":
                        if (StateHelper.CooldownRemaining(state, Ability.J, gp) == 0) return Ability.J;
                        break;
                    case "AS":
                        if (StateHelper.CooldownRemaining(state, Ability.AS, gp) == 0) return Ability.AS;
                        break;
                    case "AS+":
                        // Use AS if it will generate HP
                        if (StateHelper.TimeRemaining(state, Buff.GC, gp) > 0 && 
                            StateHelper.CooldownRemaining(state, Ability.AS, gp) == 0) return Ability.AS;
                        break;
                    default:
                        throw new Exception(String.Format("Unknown priority queue action \"{0}\"", pq[i]));
                }
            }
            return Ability.Nothing;
        }
        public RotationPriorityQueue(string queue)
        {
            pq = queue.Split('>', ';', '-');
        }
        private string[] pq;
    }
}
