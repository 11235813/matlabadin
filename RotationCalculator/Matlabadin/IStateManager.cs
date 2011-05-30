using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
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
        /// <returns>Cooldown remaining in steps</returns>
        int CooldownRemaining(TState state, Ability ability);
        /// <summary>
        /// Time remaining on the given buff.
        /// </summary>
        /// <param name="state">state</param>
        /// <param name="buff">Buff to check</param>
        /// <returns>Time remaining in steps</returns>
        int TimeRemaining(TState state, Buff buff);
        /// <summary>
        /// Holy Power
        /// </summary>
        /// <param name="state">state</param>
        /// <returns>Holy Power</returns>
        int HP(TState state);
        TState IncHP(TState state);
        TState SetHP(TState state, int hp);
        TState SetCooldownRemaining(TState state, Ability ability, int cd);
        TState SetTimeRemaining(TState state, Buff buff, int value);
        /// <summary>
        /// Advances the state to a future time
        /// </summary>
        /// <param name="state">Initial state</param>
        /// <param name="steps">Steps to advance</param>
        /// <returns>State after advancing the given number of steps</returns>
        TState AdvanceTime(TState state, int steps);
    }
}
