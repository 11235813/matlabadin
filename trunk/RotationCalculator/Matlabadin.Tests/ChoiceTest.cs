﻿using System;
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
        int[][] BD1 = new int[][] { new int[] { 0 }, new int[] { 0 }, new int[] { 0 }, new int[] { 0 } };
        int[][] BD2 = new int[][] { new int[] { 0, 0, }, new int[] { 0, 0, }, new int[] { 0, 0, }, new int[] { 0, 0, } };
        int[][] BD3 = new int[][] { new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, } };
        [Test]
        public void ChoiceShouldExposeOptions()
        {
            Choice c = new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, BD3);
            Assert.AreEqual(0.7, c.pr[0]);
            Assert.AreEqual(0.2, c.pr[1]);
            Assert.AreEqual(0.1, c.pr[2]);
        }
        [Test]
        public void ChoiceShouldExposeDuration()
        {
            Assert.AreEqual(3, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, BD3).stepsDuration);
            Assert.AreEqual(5, new Choice(Ability.CS, 5, new double[] { 0.7, 0.2, 0.1 }, 0, false, BD3).stepsDuration);
        }
        [Test]
        public void ActionShouldBeAbility()
        {
            Assert.AreEqual("CS", new Choice(Ability.CS, 3, PR, 3, false, BD1).Action);
            Assert.AreEqual("J", new Choice(Ability.J, 3, PR, 3, false, BD1).Action);
            Assert.AreEqual("Nothing", new Choice(Ability.Nothing, 3, PR, 3, false, BD1).Action);
        }
        [Test]
        [ExpectedException(typeof(ArgumentException))]
        public void WoGSS_ShouldBeSetForWogOnly()
        {
            new Choice(Ability.CS, 3, PR, 3, true, BD1);
        }
        [Test]
        [ExpectedException(typeof(ArgumentException))]
        public void BuffDuration_ShouldNotExceedStepsDuration()
        {
            new Choice(Ability.CS, 3, PR, 3, true, new int[][] { new int[] { 0 }, new int[] { 0 }, new int[] { 7 }, new int[] { 0 } });
        }
        [Test]
        public void ActionShouldSuffixSSForWoGOnly()
        {
            Assert.AreEqual("CS", new Choice(Ability.CS, 3, PR, 3, false, BD1).Action);
            Assert.AreEqual("WoG", new Choice(Ability.WoG, 3, PR, 3, false, BD1).Action);
            Assert.AreEqual("WoG(SS)", new Choice(Ability.WoG, 3, PR, 3, true, BD1).Action);
            Assert.AreEqual("WoG2(SS)", new Choice(Ability.WoG, 3, PR, 2, true, BD1).Action);
        }
        [Test]
        public void ActionShouldSuffixHPForWoGAndEFWhenLessThan3()
        {
            Assert.AreEqual("EF0", new Choice(Ability.EF, 3, PR, 0, false, BD1).Action);
            Assert.AreEqual("EF1", new Choice(Ability.EF, 3, PR, 1, false, BD1).Action);
            Assert.AreEqual("EF2", new Choice(Ability.EF, 3, PR, 2, false, BD1).Action);
            Assert.AreEqual("EF", new Choice(Ability.EF, 3, PR, 3, false, BD1).Action);
            Assert.AreEqual("EF", new Choice(Ability.EF, 3, PR, 4, false, BD1).Action);
            Assert.AreEqual("EF", new Choice(Ability.EF, 3, PR, 5, false, BD1).Action);
            Assert.AreEqual("WoG0", new Choice(Ability.WoG, 3, PR, 0, false, BD1).Action);
            Assert.AreEqual("WoG1", new Choice(Ability.WoG, 3, PR, 1, false, BD1).Action);
            Assert.AreEqual("WoG2", new Choice(Ability.WoG, 3, PR, 2, false, BD1).Action);
            Assert.AreEqual("WoG", new Choice(Ability.WoG, 3, PR, 3, false, BD1).Action);
            Assert.AreEqual("WoG", new Choice(Ability.WoG, 3, PR, 4, false, BD1).Action);
            Assert.AreEqual("WoG", new Choice(Ability.WoG, 3, PR, 5, false, BD1).Action);
        }
        [Test]
        public void ChoiceDefineEqualityAndHashCode()
        {
            Choice c11 = new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, BD3);
            Choice c12 = new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, BD3);
            Choice c21 = new Choice(Ability.SS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, BD3);
            Choice c22 = new Choice(Ability.SS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, BD3);
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
            Assert.AreNotEqual(new Choice(Ability.SS, 2, new double[] { 0.7, 0.2, 0.1 }, 0, false, BD3),
                               new Choice(Ability.SS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, BD3));
            Assert.AreNotEqual(new Choice(Ability.SS, 3, new double[] { 0.7, 0.3 }, 0, false, BD2),
                               new Choice(Ability.SS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, BD3));
        }
        [Test]
        public void EqualityShouldIncludeBuffDuration()
        {
            Choice c = new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, BD3);
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, new int[][] { new int[] { 1, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, new int[][] { new int[] { 0, 1, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, new int[][] { new int[] { 0, 0, 1, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, new int[][] { new int[] { 0, 0, 0, }, new int[] { 1, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, new int[][] { new int[] { 0, 0, 0, }, new int[] { 0, 1, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, new int[][] { new int[] { 0, 0, 0, }, new int[] { 0, 0, 1, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, new int[][] { new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 1, 0, 0, }, new int[] { 0, 0, 0, } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, new int[][] { new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 1, 0, }, new int[] { 0, 0, 0, } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, new int[][] { new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 1, }, new int[] { 0, 0, 0, } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, new int[][] { new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 1, 0, 0, } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, new int[][] { new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 1, 0, } }));
            Assert.AreNotEqual(c, new Choice(Ability.CS, 3, new double[] { 0.7, 0.2, 0.1 }, 0, false, new int[][] { new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 0, }, new int[] { 0, 0, 1, } }));
        }
        [Test]
        [ExpectedException(typeof(InvalidOperationException))]
        public void ConcatenateShouldNotAllowConcatenationToActualAbilities()
        {
            Choice cCS = new Choice(Ability.CS, 3, PR, 0, false, BD1);
            Choice cNothing = new Choice(Ability.Nothing, 3, PR, 0, false, BD1);
            cCS.Concatenate(cNothing);
        }
        [Test]
        [ExpectedException(typeof(InvalidOperationException))]
        public void ConcatenateShouldNotAllowConcatenationWhenThereIsAChoiceOfNextStates()
        {
            Choice cNothing = new Choice(Ability.Nothing, 3, new double[] { 0.5, 0.4, 0.1 }, 0, false, BD3);
            cNothing.Concatenate(cNothing);
        }
        [Test]
        public void ConcatenateShouldAddStepsDurations()
        {
            Choice cNothing = new Choice(Ability.Nothing, 1, new double[] { 1 }, 0, false, BD1);
            Choice c = cNothing.Concatenate(cNothing);
            Assert.AreEqual(2, c.stepsDuration, 2);
        }
        [Test]
        public void ConcatenateShouldAddBuffDurations()
        {
            Choice cNothing = new Choice(Ability.Nothing, 3, new double[] { 1 }, 0, false, new int[][] { new int[] { 0 }, new int[] { 1 }, new int[] { 2 }, new int[] { 3 } });
            Choice c = cNothing.Concatenate(cNothing);
            Assert.AreEqual(0, c.buffDuration[0][0]);
            Assert.AreEqual(2, c.buffDuration[1][0]);
            Assert.AreEqual(4, c.buffDuration[2][0]);
            Assert.AreEqual(6, c.buffDuration[3][0]);
        }
        [Test]
        public void ConcatenateShouldSetHPBasedOnAbilityUsage()
        {
            Choice cNothing = new Choice(Ability.Nothing, 1, new double[] { 1 }, 1, false, BD1);
            Choice c = cNothing.Concatenate(
                new Choice(Ability.WoG, 0, new double[] { 1 }, 1, false, BD1));
            // Test data only possible if we introduce HP decay modelling which is unlikely
            Assert.IsTrue(c.Action.Contains("1"));
        }
        [Test]
        public void ConcatenateShouldSetPrBasedOnContatenatedChoice()
        {
            double[] pr = new double[] { 0.5, 0.5 };
            Choice cNothing = new Choice(Ability.Nothing, 1, new double[] { 1 }, 0, false, BD1);
            Choice c = cNothing.Concatenate(
                new Choice(Ability.J, 3, pr, 0, false, BD2));
            Assert.IsTrue(pr.SequenceEqual(c.pr));
            Assert.IsTrue(BD2.SelectMany(x => x).SequenceEqual(c.buffDuration.SelectMany(x => x)));
        }
    }
}
