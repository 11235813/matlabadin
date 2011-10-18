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
            WoG = sm.CooldownRemaining(state, Ability.WoG);
            CS = sm.CooldownRemaining(state, Ability.CS);
            J = sm.CooldownRemaining(state, Ability.J);
            AS = sm.CooldownRemaining(state, Ability.AS);
            Cons = sm.CooldownRemaining(state, Ability.Cons);
            HW = sm.CooldownRemaining(state, Ability.HW);
            HoW = sm.CooldownRemaining(state, Ability.HoW);
            GC = sm.TimeRemaining(state, Buff.GC);
            SD = sm.TimeRemaining(state, Buff.SD);
            Inq = sm.TimeRemaining(state, Buff.Inq);
            EGICD = sm.TimeRemaining(state, Buff.EGICD);
            JotW = sm.TimeRemaining(state, Buff.JotW);
        }
        public double WoG { get; set; }
        public double CS { get; set; }
        public double J { get; set; }
        public double AS { get; set; }
        public double Cons { get; set; }
        public double HW { get; set; }
        public double HoW { get; set; }
        public double GC { get; set; }
        public double SD { get; set; }
        public double Inq { get; set; }
        public double EGICD { get; set; }
        public double JotW { get; set; }
    }
}
