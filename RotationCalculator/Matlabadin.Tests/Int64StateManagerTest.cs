using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Matlabadin.Tests
{
    [TestClass]
    public class Int64StateManagerTest : StateManagerTest<Int64GraphParameters, ulong>
    {
        public override Int64GraphParameters StateManager
        {
            get
            {
                return new Int64GraphParameters(R, 3, 0.5, 0.5);
            }
        }
    }
}
