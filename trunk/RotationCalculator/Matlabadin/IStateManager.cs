using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    /// <summary>
    /// Associated interface that exposes information about an opaque state object.
    /// </summary>
    /// <typeparam name="TState">Underlying type of the opaque state object.</typeparam>
    public interface IStateManager<TState>
    {
        /// <summary>
        /// Initial state with all abilities off CD and not buffs active.
        /// </summary>
        /// <returns>Initial state</returns>
        TState InitialState();
        /// <summary>
        /// Cooldown remaining on the given ability
        /// </summary>
        /// <param name="state">state</param>
        /// <param name="ability">Ability</param>
        /// <returns>Cooldown remaining in steps, including any GCD cooldown preventing ability casting</returns>
        int CooldownRemaining(TState state, Ability ability);
        /// <summary>
        /// Time remaining on the given buff.
        /// </summary>
        /// <param name="state">state</param>
        /// <param name="buff">Buff to check</param>
        /// <returns>Time remaining in steps</returns>
        int TimeRemaining(TState state, Buff buff);
        /// <summary>
        /// Number of stacks of the given buff
        /// </summary>
        /// <param name="state">state</param>
        /// <param name="buff">Buff to check</param>
        /// <returns>Number of stacks of the given buff</returns>
        int Stacks(TState state, Buff buff);
        /// <summary>
        /// Holy Power
        /// </summary>
        /// <param name="state">state</param>
        /// <returns>Holy Power</returns>
        int HP(TState state);
        /// <summary>
        /// Increments holy power
        /// </summary>
        /// <param name="state">state</param>
        /// <returns>New state</returns>
        TState IncHP(TState state);
        /// <summary>
        /// Sets holy power
        /// </summary>
        /// <param name="state">state</param>
        /// <returns>new state</returns>
        TState SetHP(TState state, int hp);
        /// <summary>
        /// Sets the cooldown of the given ability
        /// </summary>
        /// <param name="state">state</param>
        /// <param name="ability">ability to set cooldown for</param>
        /// <param name="cd">cooldown duration is steps</param>
        /// <returns>New state</returns>
        TState SetCooldownRemaining(TState state, Ability ability, int cd);
        /// <summary>
        /// Sets the remaining buff duration for the given buff
        /// </summary>
        /// <param name="state">state</param>
        /// <param name="buff">buff to set duration for</param>
        /// <param name="value">duration of buff in steps</param>
        /// <returns>New state</returns>
        TState SetTimeRemaining(TState state, Buff buff, int value);
        /// <summary>
        /// Sets the number of stacks of the given buff
        /// </summary>
        /// <param name="state">state</param>
        /// <param name="buff">buff to set duration for</param>
        /// <param name="value">number of buff stacks</param>
        /// <returns>New state</returns>
        TState SetStacks(TState state, Buff buff, int stacks);
        /// <summary>
        /// Advances the state to a future time
        /// </summary>
        /// <param name="state">Initial state</param>
        /// <param name="steps">Steps to advance</param>
        /// <returns>State after advancing the given number of steps</returns>
        TState AdvanceTime(TState state, int steps);
        /// <summary>
        /// Determines if all abilities are off cooldown
        /// </summary>
        /// <param name="state">state</param>
        /// <returns>true if all abilities are off cooldown, false otherwise.</returns>
        bool ZeroCooldownRemainingForAllAbilities(TState state);
    }
}
