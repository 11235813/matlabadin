using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections.ObjectModel;
using System.ComponentModel;

namespace Matlabadin.RotationUI
{
    public class GraphViewModel : INotifyPropertyChanged
    {
        private MatlabadinGraph<ulong> graph;
        public GraphViewModel(MatlabadinGraph<ulong> graph, double[] pr)
        {
            this.graph = graph;
            nodes = new List<StateNodeViewModel>();
            for (int i = 0; i < graph.Size; i++)
            {
                nodes.Add(new StateNodeViewModel()
                {
                    Pr = pr == null ? Double.NaN : pr[i],
                    Choice = graph.choice[i],
                    NextTransitions = new List<TransitionViewModel>(),
                    PreviousTransitions = new List<TransitionViewModel>(),
                    State = new StateViewModel<ulong>(graph.StateManager, graph.index[i]),
                });
            }
            for (int i = 0; i < graph.Size; i++)
            {
                for (int j = 0; j < graph.nextState[i].Length; j++)
                {
                    var transition = new TransitionViewModel()
                    {
                        Choice = graph.choice[i],
                        Pr = graph.choice[i].pr[j],
                        Source = nodes[i],
                        Destination = nodes[graph.nextState[i][j]],
                    };
                    nodes[i].NextTransitions.Add(transition);
                    nodes[graph.nextState[i][j]].PreviousTransitions.Add(transition);
                }
            }
            CurrentState = nodes[0];
            History = new ObservableCollection<TransitionViewModel>();
        }
        public void AdvanceTransition(TransitionViewModel t)
        {
            // Ignore transitions you can't go to
            if (!CurrentState.NextTransitions.Contains(t)) throw new InvalidOperationException("Transition must be from current state");
            History.Add(t);
            CurrentState = t.Destination;
            NotifyPropertyChanged("CurrentState");
        }
        public void GoBack()
        {
            if (History.Count == 0) return;
            CurrentState = History[History.Count - 1].Source;
            History.RemoveAt(History.Count - 1);
            NotifyPropertyChanged("CurrentState");
        }
        public List<StateNodeViewModel> nodes;
        public ObservableCollection<TransitionViewModel> History { get; set; }
        public StateNodeViewModel CurrentState { get; set; }
        public int NumberOfStates { get; set; }
        private void NotifyPropertyChanged(string property)
        {
            if (PropertyChanged != null) PropertyChanged(this, new PropertyChangedEventArgs(property));
        }
        public event PropertyChangedEventHandler PropertyChanged;
    }
}
