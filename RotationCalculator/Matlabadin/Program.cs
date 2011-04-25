using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace Matlabadin
{
    public class Program
    {
		public const double BaseMeleeHit = 1.0 - 0.08 - 0.065 - 0.14;
		public const double BaseRangeHit = 1.0 - 0.08;
        public static void Main(string[] args)
        {
            if (args.Length == 0)
            {
                ParallelProcess(Console.In);
            }
            else if (args.Length == 1)
            {
                using (TextReader tr = new StreamReader(args[0]))
                {
                    ParallelProcess(tr);
                }
            }
            else
            {
                ProcessParams(args);
            }
        }
        private static void ParallelProcess(TextReader input)
        {
            List<Task> taskList = new List<Task>();
            foreach (string[] inputArgs in GetInputs(input))
            {
                string[] args = inputArgs;
                taskList.Add(Task.Factory.StartNew(() => ProcessParams(args), TaskCreationOptions.PreferFairness));
            }
            Task.WaitAll(taskList.ToArray());
        }
        private static IEnumerable<string[]> GetInputs(TextReader input)
        {
            // Parse each input line into parameters
            string line;
            int lineNumber = 0;
            while (true)
            {
                line = input.ReadLine();
                lineNumber++;
                if (String.IsNullOrEmpty(line)) break;
                yield return line.Split(' ', '\t');
            }
        }
        private static void ProcessParams(string[] args)
        {
            if (args.Length < 8) Usage();
            string rotation;
            int stepsPerGcd;
            bool useConsGlyph;
            double mehit, rhit, sd, gc, eg;
            rotation = args[0];
            if (!Int32.TryParse(args[1], out stepsPerGcd)) Usage();
            if (!Boolean.TryParse(args[2], out useConsGlyph)) Usage();
            if (!Double.TryParse(args[3], out mehit)) Usage();
            if (!Double.TryParse(args[4], out rhit)) Usage();
            if (!Double.TryParse(args[5], out sd)) Usage();
            if (!Double.TryParse(args[6], out gc)) Usage();
            if (!Double.TryParse(args[7], out eg)) Usage();
            string file = args.Length >= 9 ? args[8] : null;
            ProcessGraph(file, rotation, stepsPerGcd, useConsGlyph, mehit, rhit, sd, gc, eg);
        }
        private static void ProcessGraph(string file, string rotation, int stepsPerGcd, bool useConsGlyph, double mehit, double rhit, double sd, double gc, double eg)
        {
            if (file == null)
            {
                ProcessGraph(Console.Out, rotation, stepsPerGcd, useConsGlyph, mehit, rhit, sd, gc, eg);
            }
            else
            {
                FileInfo fi = new FileInfo(file);
                if (fi.Exists)
                {
                    Console.Error.WriteLine("Output file {0} already exists: skipping", file);
                    return;
                }
                if (!fi.Directory.Exists)
                {
                    fi.Directory.Create();
                }
                using (StreamWriter sw = new StreamWriter(file, false))
                {
                    ProcessGraph(sw, rotation, stepsPerGcd, useConsGlyph, mehit, rhit, sd, gc, eg);
                }
            }
        }
        private static void ProcessGraph(TextWriter stream, string rotation, int stepsPerGcd, bool useConsGlyph, double mehit, double rhit, double sd, double gc, double eg)
        {
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
            double inqUptime;
            var result = graph.CalculateAggregates(pr, out avgDuration, out inqUptime);
            DateTime startPrint = DateTime.Now;
            foreach (var key in result.Keys.OrderBy(k => k))
            {
                stream.WriteLine("{0},{1}", key, result[key]);
            }
            stream.WriteLine("AvgDuration,{0}", avgDuration);
            stream.WriteLine("InqUptime,{0}", inqUptime);
            stream.WriteLine("Stats_StateSize_Total,{0}", graph.index.Length);
            stream.WriteLine("Stats_StateSize_NonZero,{0}", pr.Count(p => p > 0));
            stream.WriteLine("Stats_Iterations,{0}", iterationsPerformed);
            stream.WriteLine("Stats_Tolerance_Relative,{0}", relTolerance);
            stream.WriteLine("Stats_Tolerance_Absolute,{0}", absTolerance);
            stream.WriteLine("Stats_Time_GenerateGraph,{0}", (startPr - startGraph).TotalSeconds);
            stream.WriteLine("Stats_Time_Converge,{0}", (startAggregate - startPr).TotalSeconds);
            stream.WriteLine("Stats_Time_Aggregate,{0}", (startPrint - startAggregate).TotalSeconds);
            stream.WriteLine("Param_Rotation,{0}", rotation);
            stream.WriteLine("Param_Hit_Melee,{0}", mehit);
            stream.WriteLine("Param_Hit_Ranged,{0}", rhit);
            stream.WriteLine("Param_Glyph_Cons,{0}", useConsGlyph);
            stream.WriteLine("Param_ProcRate_SD,{0}", sd);
            stream.WriteLine("Param_ProcRate_GC,{0}", gc);
            stream.WriteLine("Param_ProcRate_EG,{0}", eg);
        }
        public static void Usage()
        {
            string message = "Matlabadin.exe <rotation> <stepsPerGcd> <useConsGlyph> <mehit> <rhit> <sdProcRate> <gcProcRate> <egProcRate> [<outputfile>]" + Environment.NewLine
                + "Input parameters can also be read from the command line using the same argument format as above";
            Console.WriteLine(message);
            Console.Error.WriteLine(message);
            Environment.Exit(1);
        }
    }
}