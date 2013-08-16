using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    public enum PaladinSpec
    {
        /// <summary>
        /// Protection
        /// </summary>
        Prot,
        /// <summary>
        /// Holy
        /// </summary>
        Holy,
        /// <summary>
        /// Retribution
        /// </summary>
        Ret,
    }
    public class PaladinSpecHelper
    {
        public static bool TryParse(string s, out PaladinSpec result)
        {
            return Enum.TryParse<PaladinSpec>(s, out result);
        }
    }
}
