using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;

namespace Matlabadin.Tests
{
    [TestFixture]
    public class ChoiceTest : MatlabadinTest
    {
        double[] PR = new double[] { 1 };
        int[] UBD = new int[] { 0, 0, 0, 0, 0, };
        int[][] BD1 = new int[][] { new int[] { 0 } };
        int[][] BD2 = new int[][] { new int[] { 0, 0, } };
        int[][] BD3 = new int[][] { new int[] { 0, 0, 0, } };
        [Test]
        public void ChoiceShouldExposeOptions()
        {
            Choice c = new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, UBD, BD3);
            Assert.AreEqual(0.7, c.pr[0]);
            Assert.AreEqual(0.2, c.pr[1]);
            Assert.AreEqual(0.1, c.pr[2]);
        }
        [Test]
        public void ChoiceShouldExposeDuration()
        {
            Assert.AreEqual(3, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, UBD, BD3).stepsDuration);
            Assert.AreEqual(5, new Choice(Ability.CS, 5, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, UBD, BD3).stepsDuration);
        }
        [Test]
        public void ActionShouldBeAbility()
        {
            Assert.AreEqual("CS", new Choice(Ability.CS, 3, PR, 3, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("J", new Choice(Ability.J, 3, PR, 3, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
        }
        [Test]
        [ExpectedException(typeof(ArgumentException))]
        public void BuffDuration_ShouldNotExceedStepsDuration()
        {
            new Choice(Ability.CS, 3, PR, 3, false, false, 0, 0, false, false, false, 0, new int[] { 4, 0, 0, 0, 0, }, BD1);
        }
        [Test]
        public void ActionShouldSuffixBoGForWoGorEFOnly()
        {
            Assert.AreEqual("CS", new Choice(Ability.CS, 3, PR, 3, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("WoG", new Choice(Ability.WoG, 3, PR, 3, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("WoG(BoG3)", new Choice(Ability.WoG, 3, PR, 3, true, false, 0, 3, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("WoG2(BoG2)", new Choice(Ability.WoG, 3, PR, 2, true, false, 0, 2, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("EF2(BoG2)", new Choice(Ability.EF, 3, PR, 2, true, false, 0, 2, false, false, false, 0, UBD, BD1).Action[0]);
        }
        [Test]
        public void ActionShouldNotSuffixHPOnDP()
        {
            Assert.AreEqual("WoG", new Choice(Ability.WoG, 3, PR, 0, false, false, 0, 0, false, true, false, 0, UBD, BD1).Action[0]);
        }
        [Test]
        public void ActionShouldSuffixAW()
        {
            Assert.AreEqual("CS(AW)", new Choice(Ability.CS, 3, PR, 3, false, false, 0, 0, true, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("WoG(AW)", new Choice(Ability.WoG, 3, PR, 3, false, false, 0, 0, true, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("WoG(BoG5)(AW)", new Choice(Ability.WoG, 3, PR, 3, true, false, 0, 5, true, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("WoG2(BoG4)(AW)", new Choice(Ability.WoG, 3, PR, 2, true, false, 0, 4, true, false, false, 0, UBD, BD1).Action[0]);
        }
        [Test]
        public void ActionShouldSuffixGoWoG()
        {
            Assert.AreEqual("CS(GoWoG1)", new Choice(Ability.CS, 3, PR, 3, false, false, 0, 0, false, false, false, 1, UBD, BD1).Action[0]);
            Assert.AreEqual("WoG(GoWoG2)", new Choice(Ability.WoG, 3, PR, 3, false, false, 0, 0, false, false, false, 2, UBD, BD1).Action[0]);
            Assert.AreEqual("WoG(BoG5)(GoWoG3)", new Choice(Ability.WoG, 3, PR, 3, true, false, 0, 5, false, false, false, 3, UBD, BD1).Action[0]);
            Assert.AreEqual("WoG2(BoG4)(GoWoG1)", new Choice(Ability.WoG, 3, PR, 2, true, false, 0, 4, false, false, false, 1, UBD, BD1).Action[0]);
        }
        [Test]
        public void ActionShouldSuffixHA()
        {
            Assert.AreEqual("CS(HA)", new Choice(Ability.CS, 3, PR, 3, false, false, 0, 0, false, false, true, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("HotR(HA)", new Choice(Ability.HotR, 3, PR, 3, false, false, 0, 0, false, false, true, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("J(HA)", new Choice(Ability.J, 3, PR, 3, false, false, 0, 0, false, false, true, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("AS(GC)(HA)", new Choice(Ability.AS, 3, PR, 3, false, true, 0, 0, false, false, true, 0, UBD, BD1).Action[0]);
        }
        [Test]
        [ExpectedException(typeof(ArgumentException))]
        public void Choice_ShouldThrowExceptionForNonWogWogss()
        {
            new Choice(Ability.CS, 3, PR, 3, true, false, 0, 2, false, false, false, 0, UBD, BD1);
        }
        [Test]
        public void ActionShouldSuffixGCForASOnly()
        {
            Assert.AreEqual("CS", new Choice(Ability.CS, 3, PR, 3, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("AS", new Choice(Ability.AS, 3, PR, 3, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("AS(GC)", new Choice(Ability.AS, 3, PR, 2, false, true, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
        }
        [Test]
        public void ActionShouldSuffixSHStacksForFoLOnly()
        {
            Assert.AreEqual("FoL(SH0)", new Choice(Ability.FoL, 3, PR, 3, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("FoL(SH1)", new Choice(Ability.FoL, 3, PR, 3, false, false, 1, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("FoL(SH2)", new Choice(Ability.FoL, 3, PR, 3, false, false, 2, 0, false, false, false, 0, UBD, BD1).Action[0]);
        }
        [Test]
        [ExpectedException(typeof(ArgumentException))]
        public void Choice_ShouldThrowExceptionForNonFoLSH()
        {
            new Choice(Ability.CS, 3, PR, 3, false, false, 1, 0, false, false, false, 0, UBD, BD1);
        }
        [Test]
        [ExpectedException(typeof(ArgumentException))]
        public void Choice_ShouldThrowExceptionForNonAsAsgc()
        {
            new Choice(Ability.CS, 3, PR, 3, false, true, 0, 0, false, false, false, 0, UBD, BD1);
        }
        [Test]
        public void ActionShouldSuffixHPForWoGAndEFWhenLessThan3()
        {
            Assert.AreEqual("EF0", new Choice(Ability.EF, 3, PR, 0, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("EF1", new Choice(Ability.EF, 3, PR, 1, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("EF2", new Choice(Ability.EF, 3, PR, 2, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("EF", new Choice(Ability.EF, 3, PR, 3, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("EF", new Choice(Ability.EF, 3, PR, 4, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("EF", new Choice(Ability.EF, 3, PR, 5, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("WoG0", new Choice(Ability.WoG, 3, PR, 0, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("WoG1", new Choice(Ability.WoG, 3, PR, 1, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("WoG2", new Choice(Ability.WoG, 3, PR, 2, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("WoG", new Choice(Ability.WoG, 3, PR, 3, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("WoG", new Choice(Ability.WoG, 3, PR, 4, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
            Assert.AreEqual("WoG", new Choice(Ability.WoG, 3, PR, 5, false, false, 0, 0, false, false, false, 0, UBD, BD1).Action[0]);
        }
        [Test]
        public void Choice_Equality_ShouldIncorporateGC()
        {
            Assert.AreNotEqual(new Choice(Ability.AS, 3, PR, 2, false, false, 0, 0, false, false, false, 0, UBD, BD1),
                new Choice(Ability.AS, 3, PR, 2, false, true, 0, 0, false, false, false, 0, UBD, BD1));
        }
        [Test]
        public void ChoiceDefineEqualityAndHashCode()
        {
            Choice c11 = new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, UBD, BD3);
            Choice c12 = new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, UBD, BD3);
            Choice c21 = new Choice(Ability.SS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, UBD, BD3);
            Choice c22 = new Choice(Ability.SS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, UBD, BD3);
            Assert.AreEqual(c11, c12);
            Assert.AreEqual(c21, c22);
            Assert.AreEqual(c12, c11);
            Assert.AreEqual(c22, c21);
            Assert.AreNotEqual(c11, c21);
            Assert.AreNotEqual(c11, c22);
            Assert.AreNotEqual(c12, c21);
            Assert.AreNotEqual(c12, c22);
            Assert.AreEqual(c11.GetHashCode(), c12.GetHashCode());
            Assert.AreEqual(c21.GetHashCode(), c22.GetHashCode());
            Assert.AreEqual(c12.GetHashCode(), c11.GetHashCode());
            Assert.AreEqual(c22.GetHashCode(), c21.GetHashCode());
            Assert.AreNotEqual(c11.GetHashCode(), c21.GetHashCode());
            Assert.AreNotEqual(c11.GetHashCode(), c22.GetHashCode());
            Assert.AreNotEqual(c12.GetHashCode(), c21.GetHashCode());
            Assert.AreNotEqual(c12.GetHashCode(), c22.GetHashCode());

            // duration & probabilies also change equality
            Assert.AreNotEqual(new Choice(Ability.SS, 2, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, UBD, BD3),
                               new Choice(Ability.SS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, UBD, BD3));
            Assert.AreNotEqual(new Choice(Ability.SS, 3, new double[] { 0.7, 0.3 }, 0, false, false, 0, 0, false, false, false, 0, UBD, BD2),
                               new Choice(Ability.SS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, UBD, BD3));
        }
        [Test]
        public void EqualityShouldIncludeBuffDuration()
        {
            Choice c = new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, UBD, BD3);
            Assert.AreEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, new int[] { 0, 0, 0, 0, 0 }, new int[][] { new int[] { 0, 0, 0 } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, new int[] { 1, 0, 0, 0, 0 }, new int[][] { new int[] { 0, 0, 0 } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, new int[] { 0, 1, 0, 0, 0 }, new int[][] { new int[] { 0, 0, 0 } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, new int[] { 0, 0, 1, 0, 0 }, new int[][] { new int[] { 0, 0, 0 } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, new int[] { 0, 0, 0, 1, 0 }, new int[][] { new int[] { 0, 0, 0 } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, new int[] { 0, 0, 0, 0, 1 }, new int[][] { new int[] { 0, 0, 0 } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, new int[] { 0, 0, 0, 0, 0 }, new int[][] { new int[] { 1, 0, 0 } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, new int[] { 0, 0, 0, 0, 0 }, new int[][] { new int[] { 0, 1, 0 } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, new int[] { 0, 0, 0, 0, 0 }, new int[][] { new int[] { 0, 0, 1 } }));
        }
        [Test]
        public void Concatenate_ShouldUseFirstAbilityUnlessNothing()
        {
            Choice cCons = new Choice(Ability.Cons, 3, PR, 0, false, false, 0, 0, false, false, false, 0, UBD, BD1);
            Choice cCS = new Choice(Ability.CS, 3, PR, 0, false, false, 0, 0, false, false, false, 0, UBD, BD1);
            Choice cNothing = new Choice(Ability.Nothing, 3, PR, 0, false, false, 0, 0, false, false, false, 0, UBD, BD1);
            Assert.AreEqual(Ability.Cons, cNothing.Concatenate(cCons).Ability);
            Assert.AreEqual(Ability.Cons, cCons.Concatenate(cNothing).Ability);
            Assert.AreEqual(Ability.Cons, cCons.Concatenate(cCS).Ability);
        }
        [Test]
        public void Concatenate_ShouldAppendActions()
        {
            Choice cCons = new Choice(Ability.Cons, 3, PR, 0, false, false, 0, 0, false, false, false, 0, UBD, BD1);
            Choice cNothing = new Choice(Ability.Nothing, 3, PR, 0, false, false, 0, 0, false, false, false, 0, UBD, BD1);
            Choice cCS = new Choice(Ability.CS, 3, PR, 0, false, false, 0, 0, false, false, false, 0, UBD, BD1);
            Choice c = cCons.Concatenate(cNothing).Concatenate(cCS);
            Assert.AreEqual("Cons", c.Action[0]);
            Assert.AreEqual("CS", c.Action[1]);
        }
        [Test]
        public void NothingShouldHaveNoAction()
        {
            Choice cNothing = new Choice(Ability.Nothing, 3, PR, 0, false, false, 0, 0, false, false, false, 0, UBD, BD1);
            Assert.IsNotNull(cNothing.Action);
            Assert.AreEqual(0, cNothing.Action.Length);
        }
        [Test]
        [ExpectedException(typeof(InvalidOperationException))]
        public void ConcatenateShouldNotAllowConcatenationWhenThereIsAChoiceOfNextStates()
        {
            Choice cNothing = new Choice(Ability.Nothing, 3, new double[] { 0.5, 0.4, 0.1 }, 0, false, false, 0, 0, false, false, false, 0, UBD, BD3);
            cNothing.Concatenate(cNothing);
        }
        [Test]
        public void ConcatenateShouldAddStepsDurations()
        {
            Choice cNothing = new Choice(Ability.Nothing, 1, new double[] { 1 }, 0, false, false, 0, 0, false, false, false, 0, UBD, BD1);
            Choice c = cNothing.Concatenate(cNothing);
            Assert.AreEqual(2, c.stepsDuration, 2);
        }
        [Test]
        public void ConcatenateShouldAddBuffDurations()
        {
            Choice cNothing = new Choice(Ability.Nothing, 5, new double[] { 1, }, 0, false, false, 0, 0, false, false, false, 0, new int[] { 1, 2, 3, 4, 5, }, new int[][] { new int[] { 1, } });
            Choice c = cNothing.Concatenate(cNothing);
            Assert.AreEqual(2, c.unforkedBuffDuration[0]);
            Assert.AreEqual(4, c.unforkedBuffDuration[1]);
            Assert.AreEqual(6, c.unforkedBuffDuration[2]);
            Assert.AreEqual(8, c.unforkedBuffDuration[3]);
            Assert.AreEqual(10, c.unforkedBuffDuration[4]);
            Assert.AreEqual(2, c.forkedBuffDuration[0][0]);
            //Assert.AreEqual(4, c.forkedBuffDuration[0][1]);
            //Assert.AreEqual(6, c.forkedBuffDuration[0][2]);
        }
        [Test]
        public void ConcatenateShouldSetHPBasedOnAbilityUsage()
        {
            Choice cNothing = new Choice(Ability.Nothing, 1, new double[] { 1 }, 1, false, false, 0, 0, false, false, false, 0, UBD, BD1);
            Choice c = cNothing.Concatenate(
                new Choice(Ability.WoG, 0, new double[] { 1 }, 1, false, false, 0, 0, false, false, false, 0, UBD, BD1));
            // Test data only possible if we introduce HP decay modelling which is unlikely
            Assert.IsTrue(c.Action[0].Contains("1"));
        }
        [Test]
        public void ConcatenateShouldSetPrBasedOnContatenatedChoice()
        {
            double[] pr = new double[] { 0.5, 0.5 };
            Choice cNothing = new Choice(Ability.Nothing, 1, new double[] { 1 }, 0, false, false, 0, 0, false, false, false, 0, UBD, BD1);
            Choice c = cNothing.Concatenate(
                new Choice(Ability.J, 3, pr, 0, false, false, 0, 0, false, false, false, 0, UBD, BD2));
            Assert.IsTrue(pr.SequenceEqual(c.pr));
        }
    }
}

