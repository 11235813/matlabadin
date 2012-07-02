using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Matlabadin
{
    [Flags]
    public enum PaladinTalents
    {
        None = 0x0,
        #region Level 15
        SpeedOfLight = 0x1,
        LongArmOfTheLaw = 0x2,
        PursuitOfJustice=0x4,
        #endregion
        #region Level 30
        FistOfJustice = 0x8,
        Repentance = 0x10,
        BurdenOfGuilt = 0x20,
        #endregion
        #region Level 45
        SelflessHealer = 0x40,
        EternalFlame = 0x80,
        SacredShield = 0x100,
        #endregion
        #region Level 60
        HandOfPurity = 0x200,
        UnbreakableSpirit = 0x400,
        Clemency = 0x800,
        #endregion
        #region Level 75
        HolyAvenger = 0x1000,
        SanctifiedWrath = 0x2000,
        DivinePurpose = 0x4000,
        #endregion
        #region Level 90
        HolyPrism = 0x8000,
        LightsHammer = 0x10000,
        ExecutionSentence = 0x20000,
        #endregion
        All = 0x381C0,
    }
    public static class PaladinTalentsHelper
    {
        /// <summary>
        /// Parse PaladinTalents from a string.
        /// </summary>
        /// <example>
        /// "111111" corresponds to talent choices: SpeedOfLight, FistOfJustice, SelflessHealer, HandOfPurity, HolyAvenger, HolyPrism
        /// "000000" corresponds to no talents
        /// "112233" corresponds to talent choices: SpeedOfLight, FistOfJustice, EternalFlame, UnbreakableSpirit, DivinePurpose, ExecutionSentence
        /// </example>
        /// <remarks>
        /// PaladinTalents are represented as a string containing digits, with each digit
        /// corresponding to the 1-based position in the talent calculator.
        /// </remarks>
        /// <param name="s"></param>
        /// <param name="result"></param>
        /// <returns></returns>
        public static bool TryParse(string s, out PaladinTalents result)
        {
            if (String.IsNullOrEmpty(s))
            {
                result = PaladinTalents.None;
                return true;
            }
            int temp;
            if (Int32.TryParse(s, out temp))
            {
                result = PaladinTalents.None;
                for (int i = 0; i < 6 && i < s.Length; i++)
                {
                    int choice = 0;
                    if (Int32.TryParse(s[i].ToString(), out choice))
                    {
                        if (choice == 0)
                        {
                            // No talent at their tier
                        }
                        else if (choice > 0 && choice <= 3)
                        {
                            result = (PaladinTalents)((int)result | (1 << (3 * i + choice - 1)));
                        }
                        else
                        {
                            // Invalid choice
                            return false;
                        }
                    }
                    else
                    {
                        // Not in the correct format
                        return false;
                    }
                }
                return true;
            }
            if (Enum.TryParse<PaladinTalents>(s, out result)) return true;
            return false;
        }
        /// <summary>
        /// Returns true if the given talent set contains the given talent
        /// </summary>
        /// <param name="talents">Talent set to check</param>
        /// <param name="talent">Talent (set) to check for</param>
        /// <returns>True if the talent is taken, false otherwise.</returns>
        public static bool Includes(this PaladinTalents talents, PaladinTalents talent)
        {
            return (talents & talent) != PaladinTalents.None;
        }
        public static string ToLongString(this PaladinTalents t)
        {
            if (t == PaladinTalents.None) return "None";
            string s = "";
            for (int i = 1; i <= (int)t; i <<= 1)
            {
                PaladinTalents it = (PaladinTalents)i;
                if (t.Includes(it))
                {
                    s += it.ToString() + ';';
                }
            }
            return s.Trim(';');
        }
    }
}
