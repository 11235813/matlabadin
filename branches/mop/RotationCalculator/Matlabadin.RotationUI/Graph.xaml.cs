using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace Matlabadin.RotationUI
{
    /// <summary>
    /// Interaction logic for Graph.xaml
    /// </summary>
    public partial class Graph : UserControl
    {
        public Graph()
        {
            InitializeComponent();
        }

        private void Back_Click(object sender, RoutedEventArgs e)
        {
            (DataContext as GraphViewModel).GoBack();
        }

        private void Forward_Click(object sender, RoutedEventArgs e)
        {
            GraphViewModel vm = DataContext as GraphViewModel;
            object buttonDataContext = (e.Source as FrameworkElement).DataContext;
            TransitionViewModel transition = buttonDataContext as TransitionViewModel;
            vm.AdvanceTransition(transition);
        }
    }
}
