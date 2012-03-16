using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;

namespace Matlabadin.Tests
{
    [TestFixture]
    public class ArrayStateManagerTest : StateManagerTest<ArrayStateManager, StateArray>
    {
        public override ArrayStateManager StateManager
        {
            get
            {
                return new ArrayStateManager();
            }
        }
    }
}
