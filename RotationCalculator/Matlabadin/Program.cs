using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public class Program
    {
        public static void Main(string[] args)
        {
            if (args.Length != 8) Usage();
            string rotation = args[0];
            int stepsPerGcd;
            bool useConsGlyph;
            double mehit, rhit, sd, gc, eg;
            if (!Int32.TryParse(args[1], out stepsPerGcd)) Usage();
            if (!Boolean.TryParse(args[2], out useConsGlyph)) Usage();
            if (!Double.TryParse(args[3], out mehit)) Usage();
            if (!Double.TryParse(args[4], out rhit)) Usage();
            if (!Double.TryParse(args[5], out sd)) Usage();
            if (!Double.TryParse(args[6], out gc)) Usage();
            if (!Double.TryParse(args[7], out eg)) Usage();

            GraphParameters gp = new GraphParameters(stepsPerGcd, useConsGlyph, mehit, rhit, sd, gc, eg);
            MatlabadinGraph graph = new MatlabadinGraph(gp, RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction(rotation));
            DateTime startGraph = DateTime.Now;
            graph.GenerateGraph();
            DateTime startPr = DateTime.Now;
            double[] pr = graph.ConvergeStateProbability();
            DateTime startAggregate = DateTime.Now;
            double avgDuration;
            var result = graph.CalculateAggregates(pr, out avgDuration);
            DateTime startPrint = DateTime.Now;
            Console.WriteLine("AvgDuration,{0}", avgDuration);
            foreach (var entry in result)
            {
                Console.WriteLine("{0},{1}", entry.Key, entry.Value);
            }
        }
        public static void Usage()
        {
            string message = "Matlabadin.exe <rotation> <stepsPerGcd> <useConsGlyph> <mehit> <rhit> <sdProcRate> <gcProcRate> <egProcRate>";
            Console.WriteLine(message);
            Environment.Exit(1);
        }
    }
}
