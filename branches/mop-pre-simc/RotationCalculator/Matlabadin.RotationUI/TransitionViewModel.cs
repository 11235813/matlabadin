using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin.RotationUI
{
    public class TransitionViewModel
    {
        public Choice Choice { get; set; }
        public double Pr { get; set; }
        public StateNodeViewModel Source { get; set; }
        public StateNodeViewModel Destination { get; set; }
    }
}
