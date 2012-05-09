﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using System.Diagnostics;

namespace Matlabadin
{
    public class Program
    {
		public const double BaseMeleeHit = 1.0 - 0.075 - 0.075 - 0.075;
		public const double BaseSpellHit = 1.0 - 0.15;
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
            HashSet<string> processedInputs = new HashSet<string>();
            // Optimisation: order tasks to take advantage of graph reuse based on Task.Factory.Scheduler.MaximumConcurrencyLevel
            foreach (string[] inputArgs in GetInputs(input))
            {
                string[] args = inputArgs;
                string line = args.Aggregate("", (ln, s) => ln + " " + s);
                if (processedInputs.Contains(line))
                {
                    Console.Error.WriteLine("Duplicate input detected - only generating graph once ({0})", line);
                }
                else
                {
                    processedInputs.Add(line);
                    taskList.Add(Task.Factory.StartNew(() => ProcessParams(args), TaskCreationOptions.PreferFairness));
                }
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
            if (args.Length < 6) Usage();
            string rotation;
            int stepsPerHastedGcd;
            PaladinTalents talents;
            PaladinSpec spec;
            double haste, mehit, sphit;
            rotation = args[0];
            // "Matlabadin.exe <rotation> <spec> <talents> <stepsPerGcd> <hasted> <mehit> <sphit> [<outputfile>]" + Environment.NewLine
            //                      0       1       2           3          4         5       6        7
            if (!PaladinSpecHelper.TryParse(args[1], out spec)) Usage();
            if (!PaladinTalentsHelper.TryParse(args[2], out talents)) Usage();
            if (!Int32.TryParse(args[3], out stepsPerHastedGcd)) Usage();
            if (!Double.TryParse(args[4], out haste)) Usage();
            if (!Double.TryParse(args[5], out mehit)) Usage();
            if (!Double.TryParse(args[6], out sphit)) Usage();
            string file = args.Length >= 8 ? args[7] : null;
            ProcessGraph(file, rotation, spec, talents, stepsPerHastedGcd, haste, mehit, sphit);
        }
        private static DateTime BuildTime = new FileInfo(typeof(Program).Assembly.Location).CreationTime;
        private static void ProcessGraph(
            string file,
            string rotation,
            PaladinSpec spec,
            PaladinTalents talents,
            int stepsPerHastedGcd,
            double haste,
            double mehit,
            double sphit)
        {
            if (file == null)
            {
                ProcessGraph(Console.Out, rotation, spec, talents, stepsPerHastedGcd, haste, mehit, sphit);
            }
            else
            {
                FileInfo fi = new FileInfo(file);
                if (fi.Exists && fi.Length == 0)
                {
                    Console.Error.WriteLine("Deleting empty file {0}", file);
                }
                if (fi.Exists)
                {
                    if (fi.CreationTime < BuildTime)
                    {
                        Console.Error.WriteLine("Output file {0} already exists: skipping", file);
                        return;
                    }
                    else
                    {
                        Console.Error.WriteLine("Deleting file {0} as it was generated by a previous build.", file);
                    }
                }
                if (!fi.Directory.Exists)
                {
                    fi.Directory.Create();
                }
                using (StringWriter sw = new StringWriter())
                {
                    ProcessGraph(sw, rotation, spec, talents, stepsPerHastedGcd, haste, mehit, sphit);
                    File.WriteAllText(file, sw.ToString());
                }
            }
        }
        private static void ProcessGraph(
            TextWriter stream,
            string rotation,
            PaladinSpec spec,
            PaladinTalents talents,
            int stepsPerHastedGcd,
            double haste,
            double mehit,
            double sphit)
        {
            if (mehit < BaseMeleeHit) Console.Error.WriteLine("Warning: {0} melee hit would require negative hit rating", mehit);
            if (sphit < BaseSpellHit) Console.Error.WriteLine("Warning: {0} spell hit would require negative hit rating", sphit);
            if (mehit > 1) { Console.Error.WriteLine("Warning: invalid melee hit {0}", mehit); Usage(); }
            if (sphit > 1) { Console.Error.WriteLine("Warning: invalid range hit {0}", sphit); Usage(); }
            RotationPriorityQueue<BitVectorState> queue = new RotationPriorityQueue<BitVectorState>(rotation);
            Int64GraphParameters gp = new Int64GraphParameters(queue, spec, talents, stepsPerHastedGcd, haste, mehit, sphit);
            if (!String.IsNullOrEmpty(gp.ApproximationErrors)) Console.Error.WriteLine("Warning: Inexact duration modelling: {0}", gp.ApproximationErrors);
            Stopwatch generateGraphStopWatch = new Stopwatch();
            generateGraphStopWatch.Start();
            double[] hintPr;
            MatlabadinGraph<BitVectorState> graph = GenerateGraph(gp, rotation, out hintPr);
            generateGraphStopWatch.Stop();
            Stopwatch convergeStopWatch = new Stopwatch();
            convergeStopWatch.Start();
            int iterationsPerformed;
            double relTolerance, absTolerance;
            double[] pr = graph.ConvergeStateProbability(
                out iterationsPerformed,
                out relTolerance,
                out absTolerance,
                initialState: hintPr);
            convergeStopWatch.Stop();
            Stopwatch aggregateStopWatch = new Stopwatch();
            aggregateStopWatch.Start();
            ActionSummary result = graph.CalculateResults(pr);
            aggregateStopWatch.Stop();
            foreach (var key in result.Action.Keys.OrderBy(k => k))
            {
                stream.WriteLine("{0},{1}", key, result.Action[key]);
            }
            stream.WriteLine("Uptime_GCD,{0}", result.BuffUptime[(int)Buff.GCD]);
            stream.WriteLine("Uptime_SacredShield,{0}", result.BuffUptime[(int)Buff.SS]);
            stream.WriteLine("Uptime_EternalFlame,{0}", result.BuffUptime[(int)Buff.EF]);
            stream.WriteLine("Uptime_WeakenedBlows,{0}", result.BuffUptime[(int)Buff.WB]);
            stream.WriteLine("Uptime_AvengingWrath,{0}", result.BuffUptime[(int)Buff.AW]);
            stream.WriteLine("Uptime_SotRShieldBlock,{0}", result.BuffUptime[(int)Buff.SotRSB]);
            stream.WriteLine("Stats_StateSpace_TotalStatesTraversed,{0}", graph.Size);
            stream.WriteLine("Stats_StateSpace_NonZero,{0}", pr.Count(p => p > 0));
            stream.WriteLine("Stats_State_BitsRequired,{0}", gp.BitsUsed);
            stream.WriteLine("Stats_Iterations,{0}", iterationsPerformed);
            stream.WriteLine("Stats_ReusedExistingGraph,{0}", hintPr != null ? 1 : 0);
            stream.WriteLine("Stats_Tolerance_Relative,{0}", relTolerance);
            stream.WriteLine("Stats_Tolerance_Absolute,{0}", absTolerance);
            stream.WriteLine("Stats_Time_GenerateGraph,{0}", generateGraphStopWatch.ElapsedMilliseconds);
            stream.WriteLine("Stats_Time_Converge,{0}", convergeStopWatch.ElapsedMilliseconds);
            stream.WriteLine("Stats_Time_Aggregate,{0}", aggregateStopWatch.ElapsedMilliseconds);
            stream.WriteLine("Stats_Time_Aggregate,{0}", aggregateStopWatch.ElapsedMilliseconds);
            stream.WriteLine("Param_Rotation,{0}", gp.Rotation.PriorityQueue);
            stream.WriteLine("Param_Spec,{0}", gp.Spec);
            stream.WriteLine("Param_Talents,{0}", gp.Talents.ToLongString());            
            stream.WriteLine("Param_StepsPerHastedGCD,{0}", gp.StepsPerHastedGcd);
            stream.WriteLine("Param_Haste,{0}", gp.Haste);
            stream.WriteLine("Param_Hit_Melee,{0}", gp.MeleeHit);
            stream.WriteLine("Param_Hit_Spell,{0}", gp.SpellHit);
            if (!String.IsNullOrWhiteSpace(gp.ApproximationErrors))
            {
                foreach (string error in gp.ApproximationErrors.Split(';'))
                {
                    if (!String.IsNullOrWhiteSpace(error))
                    {
                        stream.WriteLine("Warnings_Fidelity,{0}", error);
                    }
                }
            }
            CacheGraph(graph, pr);
        }
        private static void CacheGraph(MatlabadinGraph<BitVectorState> mg, double[] pr)
        {
            string rotation = mg.GraphParameters.Rotation.PriorityQueue;
            lock (existingGraphs)
            {
                if (!existingGraphs.ContainsKey(rotation))
                {
                    existingGraphs[rotation] = new List<Tuple<MatlabadinGraph<BitVectorState>, double[]>>();
                }
                existingGraphs[rotation].Add(new Tuple<MatlabadinGraph<BitVectorState>, double[]>(mg, pr));
            }
        }
        private static MatlabadinGraph<BitVectorState> GenerateGraph(Int64GraphParameters gp, string rotation, out double[] hintPr)
        {
            // If we have previously generated a graph for the rotation, we can reuse that one and we only need to recalculate
            // the state probabilities due to differing hit/expertise.
            Tuple<MatlabadinGraph<BitVectorState>, double[]> closestMatch = null;
            lock (existingGraphs)
            {
                if (existingGraphs.ContainsKey(rotation))
                {
                    // use the graph with the closest euclidian distance in hit/expertise space since that should have
                    // state probabilities closest to ours.
                    closestMatch = existingGraphs[rotation]
                        .Where(mg => mg.Item1.GraphParameters.HasSameShape(gp))
                        .OrderBy(mg => (mg.Item1.GraphParameters.MeleeHit - gp.MeleeHit) * (mg.Item1.GraphParameters.MeleeHit - gp.MeleeHit)
                            + (mg.Item1.GraphParameters.SpellHit - gp.SpellHit) * (mg.Item1.GraphParameters.SpellHit - gp.SpellHit))
                        .FirstOrDefault();
                }
            }
            if (closestMatch != null)
            {
                hintPr = closestMatch.Item2;
                return new MatlabadinGraph<BitVectorState>(closestMatch.Item1, gp);
            }
            hintPr = null;
            return new MatlabadinGraph<BitVectorState>(gp, gp);
        }
        private static Dictionary<string, List<Tuple<MatlabadinGraph<BitVectorState>, double[]>>> existingGraphs = new Dictionary<string, List<Tuple<MatlabadinGraph<BitVectorState>, double[]>>>();
        public static void Usage()
        {
            string message = "Matlabadin.exe <rotation> <spec> <talents> <stepsPerHastesGcd> <haste> <mehit> <sphit> [<outputfile>]" + Environment.NewLine
                + "Multiple parrallel executions can be performed by inputting multiple lines with each line containing the argument format as above." + Environment.NewLine
                + "\t<spec>: Holy, Prot or Ret" + Environment.NewLine
                + "\t<talents>: 6 digit string indicating the talent position in the calculator: 000000 = no talents, 001000 = Selfless Healer, 002000 = Eternal Flame, 002003 = EF & Execution Sentence, etc" + Environment.NewLine
                + "\t<stepsPerGcd>: Steps per 1.5s interval" + Environment.NewLine
                + "\t<haste>: Paper-doll haste. 0.5 haste = 50% = 1.0s hasted GCD" + Environment.NewLine
                + "\t<mehit>: Melee hit. 0.0 = 100% miss rate, 1.0 = 0% miss rate" + Environment.NewLine
                + "\t<sphit>: Spell hit. 0.0 = 100% miss rate, 1.0 = 0% miss rate" + Environment.NewLine;
            Console.WriteLine(message);
            Console.Error.WriteLine(message);
            Environment.Exit(1);
        }
    }
}