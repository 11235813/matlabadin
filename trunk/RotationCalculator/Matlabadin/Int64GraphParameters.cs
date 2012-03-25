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
            double rhit)
            : base(
            rotation,
            stepsPerGcd,
            mehit,
            rhit)
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
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                BuffDurationStartBit[i] = bit;
                int cd = BuffDurationInSteps((Buff)i);
                while (1 << BuffDurationBits[i] <= cd) BuffDurationBits[i]++;
                bit += BuffDurationBits[i];
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
            return Pack(state, BuffDurationStartBit[(int)buff], numBits, value);
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
                state = Pack(state, BuffDurationStartBit[i], BuffDurationBits[i],
                    Math.Max(0, Unpack(state, BuffDurationStartBit[i], BuffDurationBits[i]) - steps));
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
