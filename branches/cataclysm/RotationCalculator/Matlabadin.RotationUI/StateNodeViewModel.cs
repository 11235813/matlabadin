using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin.RotationUI
{
    public class StateNodeViewModel
    {
        public StateViewModel<ulong> State { get; set; }
        public Choice<ulong> Choice { get; set; }
        public double Pr { get; set; }
        public List<TransitionViewModel> NextTransitions { get; set; }
        public List<TransitionViewModel> PreviousTransitions { get; set; }
    }
}
