using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public class Int64GraphParameters : GraphParameters<ulong>, IStateManager<ulong>
    {
        public Int64GraphParameters(
            RotationPriorityQueue<ulong> rotation,
            int stepsPerGcd,
            double mehit,
            double sphit,
            bool selflessHealer = false)
            : base(
            rotation,
            stepsPerGcd,
            mehit,
            sphit,
            selflessHealer)
        {
            CalculateBitOffsets();
        }
        #region Bit-Encoded State Graph Parameters
        /// <summary>
        /// Calculates the bit packing required to encode the state in an unsigned 64 bit integer
        /// </summary>
        private void CalculateBitOffsets()
        {
            int bit = 3; // HP takes the first three bits
            AbilityCooldownStartBit = new int[(int)Ability.Count];
            AbilityCooldownBits = new int[(int)Ability.Count];
            for (int i = (int)Ability.CooldownIndicator + 1; i < (int)Ability.Count; i++)
            {
                //int i = offset - (int)Ability.CooldownIndicator - 1;
                AbilityCooldownStartBit[i] = bit;
                Ability a = (Ability)i;
                int cd = AbilityCooldownInSteps(a);
                // compress state space by not recording CDs for unused abilities
                if (!Rotation.Contains(a) && !(a == Ability.CS && Rotation.Contains(Ability.HotR))) // don't remove CS if we have HotR
                {
                    cd = 0;
                }
                while (1 << AbilityCooldownBits[i] <= cd) AbilityCooldownBits[i]++;
                bit += AbilityCooldownBits[i];
            }
            // CS & HotR shared CD
            AbilityCooldownStartBit[(int)Ability.HotR] = AbilityCooldownStartBit[(int)Ability.CS];
            AbilityCooldownBits[(int)Ability.HotR] = AbilityCooldownBits[(int)Ability.CS];

            BuffDurationStartBit = new int[(int)Buff.Count];
            BuffDurationBits = new int[(int)Buff.Count];
            BuffStackStartBit = new int[(int)Buff.Count];
            BuffStackBits = new int[(int)Buff.Count];
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                BuffDurationStartBit[i] = bit;
                int cd = BuffDurationInSteps((Buff)i);
                while (1 << BuffDurationBits[i] <= cd) BuffDurationBits[i]++;
                bit += BuffDurationBits[i];
            }
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                BuffStackStartBit[i] = bit;
                int stacks = this.MaxBuffStacks((Buff)i) - 1; // only store stacks > 1
                while (1 << BuffStackBits[i] <= stacks) BuffStackBits[i]++;
                bit += BuffStackBits[i];
            }
            if (bit > 64) throw new ArgumentOutOfRangeException("bit-encoded state space larger than 64 bit");
            
            zeroCooldownBitMask = 0;
            for (int i = 0; i < AbilityCooldownStartBit.Length; i++)
            {
                for (int j = 0; j < AbilityCooldownBits[i]; j++)
                {
                    zeroCooldownBitMask |= 1UL << (AbilityCooldownStartBit[i] + j);
                }
            }
        }
        // should be private: exposed purely for testing purposes
        public int[] AbilityCooldownStartBit;
        public int[] AbilityCooldownBits;
        public int[] BuffDurationStartBit;
        public int[] BuffDurationBits;
        public int[] BuffStackStartBit;
        /// <remarks>
        /// Only buffs with multiple stacks need to be stored and the first stack is implicit in a non-zero duration.
        /// Eg: if a buff can stack twice, we only need 1 bit of storage: 1 stack = 0x0, 2 stacks = 0x1.
        /// </remarks>
        public int[] BuffStackBits;
        private ulong zeroCooldownBitMask;
        #endregion
        #region IStateManager<ulong>
        /// <summary>
        /// Cooldown remaining on the given ability
        /// </summary>
        /// <param name="ability">Ability</param>
        /// <returns>Cooldown remaining in ms.</returns>
        public int CooldownRemaining(ulong state, Ability ability)
        {
            int numBits = AbilityCooldownBits[(int)ability];
            if (numBits <= 0) return 0;
            return Unpack(state, AbilityCooldownStartBit[(int)ability], AbilityCooldownBits[(int)ability]);
        }
        /// <summary>
        /// Time remaining on the given buff.
        /// </summary>
        /// <param name="buff">Buff to check</param>
        /// <returns>Time remaining in ms.</returns>
        public int TimeRemaining(ulong state, Buff buff)
        {
            return Unpack(state, BuffDurationStartBit[(int)buff], BuffDurationBits[(int)buff]);
        }
        public ulong SetTimeRemaining(ulong state, Buff buff, int value)
        {
            int numBits = BuffDurationBits[(int)buff];
            if (value >= 1 << numBits) throw new ArgumentException(String.Format("Duration of {0} steps does not fit into {1} bits assigned to buff {2}", value, numBits, buff));
            state = Pack(state, BuffDurationStartBit[(int)buff], numBits, value);
            if (value == 0)
            {
                state = Pack(state, BuffStackStartBit[(int)buff], BuffStackBits[(int)buff], 0); // remove any buff stacks
            }
            return state;
        }
        public int HP(ulong state)
        {
            return Unpack(state, 0, 3);
        }
        public ulong IncHP(ulong state)
        {
            return SetHP(state, Math.Min(5, HP(state) + 1));
        }
        public ulong SetHP(ulong state, int hp)
        {
            return Pack(state, 0, 3, hp);
        }
        public ulong SetCooldownRemaining(ulong state, Ability ability, int cd)
        {
            int numBits = AbilityCooldownBits[(int)ability];
            if (numBits <= 0 && cd == 0) return state;
            if (cd >= 1 << numBits) throw new ArgumentException(String.Format("Cooldown of {0} steps does not fit into {1} bits assigned to ability {2}", cd, numBits, ability));
            return Pack(state, AbilityCooldownStartBit[(int)ability], AbilityCooldownBits[(int)ability], cd);
        }
        public ulong AdvanceTime(ulong state, int steps)
        {
            for (int offset = (int)Ability.CooldownIndicator + 1; offset < (int)Ability.Count; offset++)
            {
                state = Pack(state, AbilityCooldownStartBit[offset], AbilityCooldownBits[offset],
                    Math.Max(0, Unpack(state, AbilityCooldownStartBit[offset], AbilityCooldownBits[offset]) - steps));
            }
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                state = SetTimeRemaining(state, (Buff)i, Math.Max(0, TimeRemaining(state, (Buff)i) - steps));
            }
            return state;
        }
        public ulong InitialState()
        {
            return 0;
        }
        public bool ZeroCooldownRemainingForAllAbilities(ulong state)
        {
            return (zeroCooldownBitMask & state) == 0;
        }
        public int Stacks(ulong state, Buff buff)
        {
            if (TimeRemaining(state, buff) == 0) return 0;
            return Unpack(state, BuffStackStartBit[(int)buff], BuffStackBits[(int)buff]) + 1;
        }
        public ulong SetStacks(ulong state, Buff buff, int stacks)
        {
            if (stacks == 0)
            {
                return SetTimeRemaining(state, buff, 0);
            }
            if (TimeRemaining(state, buff) == 0) throw new ArgumentException("Cannot set stacks of inactive buff");
            if (stacks - 1 >= 1 << BuffStackBits[(int)buff]) throw new ArgumentException(String.Format("{0} Buff stacks do not fit into {1} stacks bits assigned {2}", stacks, BuffStackBits[(int)buff], buff));
            return Pack(state, BuffStackStartBit[(int)buff], BuffStackBits[(int)buff], stacks - 1);
        }
        #endregion
        private static int Unpack(ulong state, int startBit, int numBits)
        {
            ulong shifted = (state >> startBit);
            ulong result = shifted & (ulong)~(-1 << numBits);
            return (int)result;
        }
        private static ulong Pack(ulong state, int startBit, int numBits, int value)
        {
            if (value >= 1 << numBits || value < 0) throw new ArgumentOutOfRangeException(String.Format("value {0} does not fit in {1} bits", value, numBits));
            ulong bitsToClear = ((ulong)~(-1 << numBits)) << startBit;
            state &= ~bitsToClear;
            state |= (ulong)value << startBit;
            return state;
        }
    }
}
