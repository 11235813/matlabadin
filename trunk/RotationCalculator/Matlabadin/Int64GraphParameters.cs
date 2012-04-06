using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public struct BitVectorState
    {
        public ulong hpcd;
        public ulong buff;
        public static implicit operator BitVectorState(ulong hp)
        {
            return new BitVectorState()
            {
                hpcd = hp,
                buff = 0L,
            };
        }
        public override bool Equals(object obj)
        {
            if (obj is BitVectorState) return Equals((BitVectorState)obj);
            return base.Equals(obj);
        }
        public bool Equals(BitVectorState state)
        {
            return this.hpcd == state.hpcd && this.buff == state.buff;
        }
        public override int GetHashCode()
        {
            return this.hpcd.GetHashCode() ^ this.buff.GetHashCode();
        }
        public static bool operator ==(BitVectorState a, BitVectorState b)
        {
            return a.Equals(b);
        }
        public static bool operator !=(BitVectorState a, BitVectorState b)
        {
            return !a.Equals(b);
        }
    }
    public class Int64GraphParameters : GraphParameters<BitVectorState>, IStateManager<BitVectorState>
    {
        public Int64GraphParameters(
            RotationPriorityQueue<BitVectorState> rotation,
            int stepsPerGcd,
            PaladinSpec spec,
            PaladinTalents talents,
            double haste,
            double mehit,
            double sphit)
            : base(
            rotation,
            stepsPerGcd,
            spec,
            talents,
            haste,
            mehit,
            sphit)
        {
            CalculateBitOffsets();
        }
        #region Bit-Encoded State Graph Parameters
        public int BitsUsed { get { return this.hpcdBitsUsed + this.buffBitsUsed; } }
        private int hpcdBitsUsed;
        private int buffBitsUsed;
        /// <summary>
        /// Calculates the bit packing required to encode the state in an unsigned 64 bit integer
        /// </summary>
        private void CalculateBitOffsets()
        {
            hpcdBitsUsed = 3; // HP takes the first three bits
            AbilityCooldownStartBit = new int[(int)Ability.Count];
            AbilityCooldownBits = new int[(int)Ability.Count];
            for (int i = (int)Ability.CooldownIndicator + 1; i < (int)Ability.Count; i++)
            {
                //int i = offset - (int)Ability.CooldownIndicator - 1;
                AbilityCooldownStartBit[i] = hpcdBitsUsed;
                Ability a = (Ability)i;
                int cd = AbilityCooldownInSteps(a);
                // compress state space by not recording CDs for unused abilities
                if (!Rotation.AbilitiesUsed.Contains(a) && !(a == Ability.CS && Rotation.AbilitiesUsed.Contains(Ability.HotR))) // don't remove CS if we have HotR
                {
                    cd = 0;
                }
                while (1 << AbilityCooldownBits[i] <= cd) AbilityCooldownBits[i]++;
                hpcdBitsUsed += AbilityCooldownBits[i];
            }
            // CS & HotR shared CD
            AbilityCooldownStartBit[(int)Ability.HotR] = AbilityCooldownStartBit[(int)Ability.CS];
            AbilityCooldownBits[(int)Ability.HotR] = AbilityCooldownBits[(int)Ability.CS];
            if (hpcdBitsUsed > 64) throw new ArgumentOutOfRangeException("HP & Ability CD bit-encoded state space larger than 64 bit");

            // another 64 bits for buff durations
            buffBitsUsed = 0;
            BuffDurationStartBit = new int[(int)Buff.Count];
            BuffDurationBits = new int[(int)Buff.Count];
            BuffStackStartBit = new int[(int)Buff.Count];
            BuffStackBits = new int[(int)Buff.Count];
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                BuffDurationStartBit[i] = buffBitsUsed;
                int cd = BuffDurationInSteps((Buff)i);
                while (1 << BuffDurationBits[i] <= cd) BuffDurationBits[i]++;
                buffBitsUsed += BuffDurationBits[i];
            }
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                BuffStackStartBit[i] = buffBitsUsed;
                int stacks = this.MaxBuffStacks((Buff)i) - 1; // only store stacks > 1
                while (1 << BuffStackBits[i] <= stacks) BuffStackBits[i]++;
                buffBitsUsed += BuffStackBits[i];
            }
            if (buffBitsUsed > 64) throw new ArgumentOutOfRangeException("Buff duration bit-encoded state space larger than 64 bit");
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
        #endregion
        #region IStateManager<BitVectorState>
        /// <summary>
        /// Cooldown remaining on the given ability
        /// </summary>
        /// <param name="ability">Ability</param>
        /// <returns>Cooldown remaining in ms.</returns>
        public int CooldownRemaining(BitVectorState state, Ability ability)
        {
            int numBits = AbilityCooldownBits[(int)ability];
            if (numBits <= 0) return 0;
            return Unpack(state.hpcd, AbilityCooldownStartBit[(int)ability], AbilityCooldownBits[(int)ability]);
        }
        /// <summary>
        /// Time remaining on the given buff.
        /// </summary>
        /// <param name="buff">Buff to check</param>
        /// <returns>Time remaining in ms.</returns>
        public int TimeRemaining(BitVectorState state, Buff buff)
        {
            return Unpack(state.buff, BuffDurationStartBit[(int)buff], BuffDurationBits[(int)buff]);
        }
        public BitVectorState SetTimeRemaining(BitVectorState state, Buff buff, int value)
        {
            int numBits = BuffDurationBits[(int)buff];
#if DEBUG
            if (value >= 1 << numBits) throw new ArgumentException(String.Format("Duration of {0} steps does not fit into {1} bits assigned to buff {2}", value, numBits, buff));
#endif
            state.buff = Pack(state.buff, BuffDurationStartBit[(int)buff], numBits, value);
            if (value == 0)
            {
                state.buff = Pack(state.buff, BuffStackStartBit[(int)buff], BuffStackBits[(int)buff], 0); // remove any buff stacks
            }
            return state;
        }
        public int HP(BitVectorState state)
        {
            return Unpack(state.hpcd, 0, 3);
        }
        public BitVectorState IncHP(BitVectorState state)
        {
            return SetHP(state, Math.Min(5, HP(state) + 1));
        }
        public BitVectorState SetHP(BitVectorState state, int hp)
        {
            state.hpcd = Pack(state.hpcd, 0, 3, hp);
            return state;
        }
        public BitVectorState SetCooldownRemaining(BitVectorState state, Ability ability, int cd)
        {
            int numBits = AbilityCooldownBits[(int)ability];
            if (numBits <= 0 && cd == 0) return state;
#if DEBUG
            if (cd >= 1 << numBits) throw new ArgumentException(String.Format("Cooldown of {0} steps does not fit into {1} bits assigned to ability {2}", cd, numBits, ability));
#endif
            state.hpcd = Pack(state.hpcd, AbilityCooldownStartBit[(int)ability], AbilityCooldownBits[(int)ability], cd);
            return state;
        }
        public BitVectorState AdvanceTime(BitVectorState state, int steps)
        {
            for (int offset = (int)Ability.CooldownIndicator + 1; offset < (int)Ability.Count; offset++)
            {
                state.hpcd = Pack(state.hpcd, AbilityCooldownStartBit[offset], AbilityCooldownBits[offset],
                    Math.Max(0, Unpack(state.hpcd, AbilityCooldownStartBit[offset], AbilityCooldownBits[offset]) - steps));
            }
            for (int i = 0; i < (int)Buff.Count; i++)
            {
                state = SetTimeRemaining(state, (Buff)i, Math.Max(0, TimeRemaining(state, (Buff)i) - steps));
            }
            return state;
        }
        public BitVectorState InitialState()
        {
            return new BitVectorState()
                {
                    hpcd = 0L,
                    buff = 0L,
                };
        }
        public bool ZeroCooldownRemainingForAllAbilities(BitVectorState state)
        {
            return state.hpcd <= 5;
        }
        public int Stacks(BitVectorState state, Buff buff)
        {
            if (TimeRemaining(state, buff) == 0) return 0;
            return Unpack(state.buff, BuffStackStartBit[(int)buff], BuffStackBits[(int)buff]) + 1;
        }
        public BitVectorState SetStacks(BitVectorState state, Buff buff, int stacks)
        {
            if (stacks == 0)
            {
                return SetTimeRemaining(state, buff, 0);
            }
#if DEBUG
            if (TimeRemaining(state, buff) == 0) throw new ArgumentException("Cannot set stacks of inactive buff");
            if (stacks - 1 >= 1 << BuffStackBits[(int)buff]) throw new ArgumentException(String.Format("{0} Buff stacks do not fit into {1} stacks bits assigned {2}", stacks, BuffStackBits[(int)buff], buff));
#endif
            state.buff = Pack(state.buff, BuffStackStartBit[(int)buff], BuffStackBits[(int)buff], stacks - 1);
            return state;
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
#if DEBUG
            if (value >= 1 << numBits || value < 0) throw new ArgumentOutOfRangeException(String.Format("value {0} does not fit in {1} bits", value, numBits));
#endif                
            ulong bitsToClear = ((ulong)~(-1 << numBits)) << startBit;
            state &= ~bitsToClear;
            state |= (ulong)value << startBit;
            return state;
        }
    }
}
