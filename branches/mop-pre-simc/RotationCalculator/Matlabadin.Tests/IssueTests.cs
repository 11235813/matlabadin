using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;
using System.IO;
using System.Threading.Tasks;

namespace Matlabadin.Tests
{
    [TestFixture]
    public class IssueTests
    {
        public string GetInputFile(string filename)
        {
            string[] dirs = 
            {
                @"testdata\",
                @"..\testdata\",
                @"..\..\testdata\",
                @"..\..\..\testdata\",
                @"Matlabadin.Tests\testdata\",
                @"..\Matlabadin.Tests\testdata\",
                @"..\..\..\Matlabadin.Tests\testdata\",
                @"..\..\..\..\Matlabadin.Tests\testdata\",
                @"..\..\..\..\..\Matlabadin.Tests\testdata\",
                @"..\..\..\..\..\..\Matlabadin.Tests\testdata\",
                @"RotationCalculator\Matlabadin.Tests\testdata\",
                @"..\RotationCalculator\Matlabadin.Tests\testdata\",
                @"..\..\..\RotationCalculator\Matlabadin.Tests\testdata\",
                @"..\..\..\..\RotationCalculator\Matlabadin.Tests\testdata\",
                @"..\..\..\..\..\RotationCalculator\Matlabadin.Tests\testdata\",
                @"..\..\..\..\..\..\RotationCalculator\Matlabadin.Tests\testdata\",
            };
            foreach (string dir in dirs)
            {
                string filepath = dir + filename;
                if (File.Exists(filepath)) return filepath;
            }
            throw new FileNotFoundException(String.Format("Unable to locate test input file {0}.", dirs));
        }
        //[Test]
        public void Issue19_StressTest()
        {
            while (true)
            {
                Directory.Delete("data", true);
                Program.Main(new string[] { GetInputFile("issue19.txt") });
                Program.Main(new string[] { GetInputFile("issue19-set2.txt") });
            }
        }
        //[Test]
        public void Issue19_TryAllCloneSources()
        {
            double[] mhit = File.ReadAllLines(GetInputFile("issue19.txt")).Select(a => Double.Parse(a.Split(' ')[5])).ToArray();
            double[] rhit = File.ReadAllLines(GetInputFile("issue19.txt")).Select(a => Double.Parse(a.Split(' ')[6])).ToArray();
            List<Task> taskList = new List<Task>();
            for (int i = 0; i < mhit.Length; i++)
            {
                int loopi = i;
                taskList.Add(Task.Factory.StartNew(() =>
                {
                    Int64GraphParameters sourceGP = new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("^WB>^SS>SotR>CS>J>AS>Cons>HW"),
                            PaladinSpec.Prot, PaladinTalents.SacredShield, PaladinGlyphs.None, 3, 0, 0, mhit[loopi], rhit[loopi]);
                    MatlabadinGraph<BitVectorState> sourceGraph = new MatlabadinGraph<BitVectorState>(sourceGP, sourceGP);
                    for (int j = 0; j < mhit.Length; j++)
                    {
                        Int64GraphParameters destGP = new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("^WB>^SS>SotR>CS>J>AS>Cons>HW"),
                                PaladinSpec.Prot, PaladinTalents.SacredShield, PaladinGlyphs.None, 3, 0, 0, mhit[j], rhit[j]);
                        if (i != j && destGP.HasSameShape(sourceGP))
                        {
                            try
                            {
                                MatlabadinGraph<BitVectorState> destGraph = new MatlabadinGraph<BitVectorState>(sourceGraph, destGP);
                            }
                            catch (Exception e)
                            {
                                throw new Exception(String.Format("Error on (i={4}){0},{1} -> (j={5}){2},{3}", mhit[loopi], rhit[loopi], mhit[j], rhit[j], loopi, j), e);
                            }
                        }
                    }
                }, TaskCreationOptions.PreferFairness));
            }
            Task.WaitAll(taskList.ToArray());
        }
        //[Test]
        public void Issue19_TestRaceCondition()
        {
            Int64GraphParameters sourceGP = new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("SotR>CS>J"),
                            PaladinSpec.Prot, PaladinTalents.SacredShield, PaladinGlyphs.None, 3, 0, 0, 0.9, 0.9);
            MatlabadinGraph<BitVectorState> sourceGraph = new MatlabadinGraph<BitVectorState>(sourceGP, sourceGP);
            List<Task> taskList = new List<Task>();
            for (int i = 0; i < 128000; i++)
            {
                taskList.Add(Task.Factory.StartNew(() =>
                {
                    Int64GraphParameters destGP = new Int64GraphParameters(new RotationPriorityQueue<BitVectorState>("SotR>CS>J"),
                                PaladinSpec.Prot, PaladinTalents.SacredShield, PaladinGlyphs.None, 3, 0, 0, 0.95, 0.95);
                    MatlabadinGraph<BitVectorState> destGraph = new MatlabadinGraph<BitVectorState>(sourceGraph, destGP);
                }, TaskCreationOptions.PreferFairness));
            }
            Task.WaitAll(taskList.ToArray());
        }
    }
}

