using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;

namespace Matlabadin.Tests
{
    [TestFixture]
    public class Int64StateManagerTest : StateManagerTest<Int64GraphParameters, BitVectorState>
    {
        public override Int64GraphParameters StateManager
        {
            get
            {
                return new Int64GraphParameters(R, 3, PaladinSpec.Prot,
                    PaladinTalents.SelflessHealer | PaladinTalents.EternalFlame | PaladinTalents.SacredShield,
                    0, 0.5, 0.5);
            }
        }
        [Test]
        [ExpectedException(typeof(ArgumentException))]
        public void SetCooldownRemaining_ShouldThrowExceptionForExcessiveCooldown()
        {
            StateManager.SetCooldownRemaining(0, Ability.CS, 16); // 9 step CD = 4 bits => 16 doesn't fit
        }
        [Test]
        [ExpectedException(typeof(ArgumentException))]
        public void SetTimeRemaining_ShouldThrowExceptionForExcessiveCooldown()
        {
            StateManager.SetTimeRemaining(0, Buff.GCD, 4); // 3 step CD = 2 bits => 4 doesn't fit
        }
    }
}
