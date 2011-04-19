using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public class Program
    {
		public const double BaseMeleeHit = 1.0 - 0.08 - 0.065 - 0.14;
		public const double BaseRangeHit = 1.0 - 0.08;
        public static void Main(string[] args)
        {
            if (args.Length < 8) Usage();
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
			
			if (mehit < BaseMeleeHit) Console.Error.WriteLine("Warning: {0} melee hit would require negative hit rating", mehit);
			if (rhit < BaseRangeHit) Console.Error.WriteLine("Warning: {0} range hit would require negative hit rating", rhit);
			if (sd > 0.5) Console.Error.WriteLine("Warning: SD proc rate of {0} requires more than 2 talent points", sd);
			if (gc > 0.2) Console.Error.WriteLine("Warning: GC proc rate of {0} requires more than 2 talent points", gc);
			if (eg > 0.3) Console.Error.WriteLine("Warning: EG proc rate of {0} requires more than 2 talent points", eg);
			if (mehit > 1) { Console.Error.WriteLine("Warning: invalid melee hit {0}", mehit); Usage(); }
			if (rhit > 1) { Console.Error.WriteLine("Warning: invalid range hit {0}", rhit); Usage(); }
			if (sd < 0) { Console.Error.WriteLine("Warning: invalid sd proc rate {0}", sd); Usage(); }
			if (gc < 0) { Console.Error.WriteLine("Warning: invalid sd proc rate {0}", gc); Usage(); }
			if (eg < 0) { Console.Error.WriteLine("Warning: invalid sd proc rate {0}", eg); Usage(); }
			if (stepsPerGcd != 1 && stepsPerGcd != 3 && stepsPerGcd != 5) Console.Error.WriteLine("Warning: {0} steps per GCD is untested", stepsPerGcd);

            GraphParameters gp = new GraphParameters(stepsPerGcd, useConsGlyph, mehit, rhit, sd, gc, eg);
            MatlabadinGraph graph = new MatlabadinGraph(gp, RotationPriorityQueue.CreateRotationPriorityQueueNextStateFunction(rotation));
            DateTime startGraph = DateTime.Now;
            graph.GenerateGraph();
            DateTime startPr = DateTime.Now;
            int iterationsPerformed;
            double relTolerance, absTolerance;
            double[] pr = graph.ConvergeStateProbability(
                out iterationsPerformed,
                out relTolerance,
                out absTolerance);
            DateTime startAggregate = DateTime.Now;
            double avgDuration;
            var result = graph.CalculateAggregates(pr, out avgDuration);
            DateTime startPrint = DateTime.Now;
            foreach (var key in result.Keys.OrderBy(k => k))
            {
                Console.WriteLine("{0},{1}", key, result[key]);
            }
            Console.WriteLine("AvgDuration,{0}", avgDuration);
            Console.WriteLine("Stats_StateSize_Total,{0}", graph.index.Length);
            Console.WriteLine("Stats_StateSize_NonZero,{0}", pr.Count(p => p > 0));
            Console.WriteLine("Stats_Iterations,{0}", iterationsPerformed);
            Console.WriteLine("Stats_Tolerance_Relative,{0}", relTolerance);
            Console.WriteLine("Stats_Tolerance_Absolute,{0}", absTolerance);
            Console.WriteLine("Stats_Time_GenerateGraph,{0}", (startPr - startGraph).TotalSeconds);
            Console.WriteLine("Stats_Time_Converge,{0}", (startAggregate - startPr).TotalSeconds);
            Console.WriteLine("Stats_Time_Aggregate,{0}", (startPrint - startAggregate).TotalSeconds);
            Console.WriteLine("Param_Rotation,{0}", rotation);
            Console.WriteLine("Param_Hit_Melee,{0}", mehit);
            Console.WriteLine("Param_Hit_Ranged,{0}", rhit);
            Console.WriteLine("Param_Glyph_Cons,{0}", useConsGlyph);
            Console.WriteLine("Param_ProcRate_SD,{0}", sd);
            Console.WriteLine("Param_ProcRate_GC,{0}", gc);
            Console.WriteLine("Param_ProcRate_EG,{0}", eg);
        }
        public static void Usage()
        {
            string message = "Matlabadin.exe <rotation> <stepsPerGcd> <useConsGlyph> <mehit> <rhit> <sdProcRate> <gcProcRate> <egProcRate>";
            Console.WriteLine(message);
            Environment.Exit(1);
        }
    }
}
