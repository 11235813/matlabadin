using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;

namespace Matlabadin.RotationUI
{
    public class GraphParametersViewModel : INotifyPropertyChanged
    {
        public string Rotation { get; set; }
        public int StepsPerGCD { get; set; }
        public double MeleeHit { get; set; }
        public double RangeHit { get; set; }
        public bool CalculatePr { get; set; }

        public GraphViewModel Graph { get; private set; }
        public GraphParametersViewModel()
        {
            Rotation = "SotR>CS>AS>J";
            StepsPerGCD = 3;
            MeleeHit = 0.735;
            RangeHit = 0.94;
            CalculatePr = true;
            GenerateGraph();
        }
        public void GenerateGraph()
        {
            RotationPriorityQueue<BitVectorState> queue = new RotationPriorityQueue<BitVectorState>(Rotation);
            Int64GraphParameters gp = new Int64GraphParameters(queue, StepsPerGCD, PaladinSpec.Prot, PaladinTalents.None, 0, MeleeHit, RangeHit);
            MatlabadinGraph<BitVectorState> graph = new MatlabadinGraph<BitVectorState>(gp, gp);
            double[] pr = null;
            if (CalculatePr)
            {
                int iterations;
                double relTol, absTol;
                pr = graph.ConvergeStateProbability(out iterations, out relTol, out absTol);
            }
            Graph = new GraphViewModel(graph, pr);
            NotifyPropertyChanged("Graph");
        }
        private void NotifyPropertyChanged(string property)
        {
            if (PropertyChanged != null) PropertyChanged(this, new PropertyChangedEventArgs(property));
        }
        public event PropertyChangedEventHandler PropertyChanged;
    }
}
