using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public class StateArray
    {
        public int hp;
        public int[] cd;
        public int[] duration;
        public override bool Equals(object obj)
        {
            if (obj is StateArray) return Equals((StateArray)obj);
            return base.Equals(obj);
        }
        public bool Equals(StateArray sa)
        {
            if (this.hp != sa.hp) return false;
            for (int i = 0; i < this.cd.Length; i++)
            {
                if (this.cd[i] != sa.cd[i]) return false;
            }
            for (int i = 0; i < this.duration.Length; i++)
            {
                if (this.duration[i] != sa.duration[i]) return false;
            }
            return true;
        }
        public override int GetHashCode()
        {
            int hash = hp.GetHashCode();
            for (int i = 0; i < this.cd.Length; i++) hash |= (this.cd[i] << (i + 1)).GetHashCode();
            for (int i = 0; i < this.duration.Length; i++) hash |= (this.duration[i] << (i + 1 + this.cd.Length)).GetHashCode();
            return hash;
        }
        public static bool operator ==(StateArray a, StateArray b)
        {
            if (Object.ReferenceEquals(a, b)) return true;
            if (Object.ReferenceEquals(a, null)) return false;
            if (Object.ReferenceEquals(b, null)) return false;
            return a.Equals(b);
        }
        public static bool operator !=(StateArray a, StateArray b)
        {
            return !a.Equals(b);
        }
    }
    public class ArrayStateManager : IStateManager<StateArray>
    {
        public StateArray InitialState()
        {
            return new StateArray()
            {
                hp = 0,
                cd = new int[(int)Ability.Count - (int)Ability.CooldownIndicator],
                duration = new int[(int)Buff.Count],
            };
        }
        public int CooldownRemaining(StateArray state, Ability ability)
        {
            if (ability == Ability.HotR) return CooldownRemaining(state, Ability.CS);
            int index = (int)ability - (int)Ability.CooldownIndicator;
            if (index < 0) return 0;
            return state.cd[index];
        }
        public int TimeRemaining(StateArray state, Buff buff)
        {
            return state.duration[(int)buff];
        }
        public int HP(StateArray state)
        {
            return state.hp;
        }
        public StateArray IncHP(StateArray state)
        {
            return new StateArray()
            {
                hp = Math.Min(state.hp + 1, 3),
                cd = state.cd,
                duration = state.duration,
            };
        }
        public StateArray SetHP(StateArray state, int hp)
        {
            return new StateArray()
            {
                hp = hp,
                cd = state.cd,
                duration = state.duration,
            };
        }
        public StateArray SetCooldownRemaining(StateArray state, Ability ability, int cd)
        {
            if (ability == Ability.HotR) return SetCooldownRemaining(state, Ability.CS, cd);
            StateArray sa = new StateArray()
            {
                hp = state.hp,
                cd = (int[])state.cd.Clone(),
                duration = state.duration,
            };
            sa.cd[(int)ability - (int)Ability.CooldownIndicator] = cd;
            return sa;
        }
        public StateArray SetTimeRemaining(StateArray state, Buff buff, int value)
        {
            StateArray sa = new StateArray()
            {
                hp = state.hp,
                cd = state.cd,
                duration = (int[])state.duration.Clone(),
            };
            sa.duration[(int)buff] = value;
            return sa;
        }
        public StateArray AdvanceTime(StateArray state, int steps)
        {
            StateArray sa = new StateArray()
            {
                hp = state.hp,
                cd = (int[])state.cd.Clone(),
                duration = (int[])state.duration.Clone(),
            };
            for (int i = 0; i < (int)Ability.Count - (int)Ability.CooldownIndicator; i++)
            {
                sa.cd[i] = Math.Max(0, sa.cd[i] - steps);
            }
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                sa.duration[i] = Math.Max(0, sa.duration[i] - steps);
            }
            return sa;
        }
        public bool ZeroCooldownRemainingForAllAbilities(StateArray sa)
        {
            for (int i = 0; i < (int)Ability.Count - (int)Ability.CooldownIndicator; i++)
            {
                if (sa.cd[i] > 0) return false;
            }
            return true;
        }
    }
}
