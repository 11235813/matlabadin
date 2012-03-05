using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin.RotationUI
{
    public class StateViewModel<T>
    {
        public StateViewModel(IStateManager<T> sm, T state)
        {
            HP = sm.HP(state);
            CS = sm.CooldownRemaining(state, Ability.CS);
            J = sm.CooldownRemaining(state, Ability.J);
            AS = sm.CooldownRemaining(state, Ability.AS);
            Cons = sm.CooldownRemaining(state, Ability.Cons);
            GC = sm.TimeRemaining(state, Buff.GC);
            SS = sm.TimeRemaining(state, Buff.SS);
            EF = sm.TimeRemaining(state, Buff.EF);
            WB = sm.TimeRemaining(state, Buff.WB);
            SB = sm.TimeRemaining(state, Buff.SotRSB);
        }
        public int HP { get; set; }
        public double CS { get; set; }
        public double AS { get; set; }
        public double J { get; set; }
        public double Cons { get; set; }
        public double GC { get; set; }
        public double SS { get; set; }
        public double EF { get; set; }
        public double WB { get; set; }
        public double SB { get; set; }
    }
}
