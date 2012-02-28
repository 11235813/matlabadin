using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Matlabadin.Tests
{
    [TestClass]
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
