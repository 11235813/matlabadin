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
        public bool UseConsGlyph { get; set; }
        public double MeleeHit { get; set; }
        public double RangeHit { get; set; }
        public double SDProcRate { get; set; }
        public double GCProcRate { get; set; }
        public double EGProcRate { get; set; }
        public bool RetT13 { get; set; }
        public bool CalculatePr { get; set; }

        public GraphViewModel Graph { get; private set; }
        public GraphParametersViewModel()
        {
            Rotation = "SotR>CS>AS>J";
            StepsPerGCD = 3;
            UseConsGlyph = false;
            MeleeHit = 0.735;
            RangeHit = 0.94;
            RetT13 = false;
            SDProcRate = 0.5;
            GCProcRate = 0.2;
            EGProcRate = 0;
            CalculatePr = true;
            GenerateGraph();
        }
        public void GenerateGraph()
        {
            RotationPriorityQueue<ulong> queue = new RotationPriorityQueue<ulong>(Rotation);
            Int64GraphParameters gp = new Int64GraphParameters(queue, StepsPerGCD, UseConsGlyph, MeleeHit, RangeHit, SDProcRate, GCProcRate, EGProcRate, RetT13);
            MatlabadinGraph<ulong> graph = new MatlabadinGraph<ulong>(gp, gp);
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
