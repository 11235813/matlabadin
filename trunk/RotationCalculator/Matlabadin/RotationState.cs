/* Prot Pal Rotation state machine
    Copyright (C) 2011 Daniel Cameron

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
// TODO: Holy Shield Uptime
// TODO: visualisation using http://www.cise.ufl.edu/research/sparse/matrices/
/// <summary>
/// Ability that can be used
/// </summary>
public enum Ability
{
    Nothing = -1,
    HOTR = 0,
    CS = 0, // HOTR & CS do exactly the same thing: just change the dps calculation
    J = 1,
    AS = 2,
    CONS = 3,
    HW = 4,
    SOTR = 5,
    WOG = 6,
    INQ = 7,
    //HoW not modelled yet
}
/// <summary>
/// Buffs that can be active
/// </summary>
public enum Buff
{
    GC = 7,
    SD = 8,
    INQ = 9,
    EGICD = 10,
    GCICD = 11,
    //HS uptime not modelled yet
}
public class State
{
    /// <summary>
    /// Creates an initial state with all abilities off CD.
    /// </summary>
    public State()
    {
    }
    /// <summary>
    /// Creates the state after using the given ability is used and GCD complete
    /// </summary>
    /// <param name="s">Initial state</param>
    /// <param name="ability">Ability to use</param>
    /// <param name="abilityCd">Cooldown of ability that is being used in ms.</param>
    /// <param name="hit">True to transition to a state where the ability has hit, false otherwise.</param>
    /// <param name="abilityDuration">Steps to advance the state so that the GCD is complete. (should be =GCD unless we are delaying before casting such as J every 8s)</param>
    /// <param name="waitTime">Time (in ms) to wait before using ability.</param>
    /// <param name="proc">Cause a proc</param>
    /// <returns>New state after ability has been used and GCD complete (usually 1.5s later).</returns>
    public State(State s, Ability ability, int abilityCd, bool hit, int abilityDuration = 1500, int waitTime = 0,
        bool sdProc = false,
        bool gcProc = false,
        bool egProc = false)
    {
        if (waitTime - s.CooldownRemaining(ability) > 0) throw new InvalidOperationException("Using ability before CD"); // sanity check
        // Advance time till we use the ability
        for (int i = 0; i < s.cd.Length; i++)
        {
            cd[i] = Math.Max(0, s.cd[i] - waitTime);
        }
        // Use ability
        if (ability != Ability.Nothing)
        {
            cd[(int)ability] = abilityCd;
        }
        // Update HP
        if ((ability == Ability.CS && hit))
        {
            hp = Math.Min(3, s.hp + 1);
        }
        else if (ability == Ability.AS && s.GcWillProcHP() && hit)
        {
            // GC proc use
            hp = Math.Min(3, s.hp + 1);
            cd[(int)Buff.GCICD] = StateManager.Cooldown[(int)Buff.GCICD];
        }
        else if ((ability == Ability.SOTR && hit) || ability == Ability.WOG)
        {
            if (s.hp == 0) throw new InvalidOperationException(String.Format("{0} use with 0 HP", ability));
            hp = 0;
        }
        else if (ability == Ability.INQ)
        {
            if (s.hp == 0) throw new InvalidOperationException("INQ use with 0 HP");
            hp = 0;
            cd[(int)Buff.INQ] = StateManager.Cooldown[(int)Buff.INQ] / 3 * s.hp;
        }
        else
        {
            hp = s.hp;
        }
        // Clear consumed buffs
        if (ability == Ability.AS)
        {
            // GC gets cleared
            cd[(int)Buff.GC] = 0;
        }
        if (ability == Ability.SOTR)
        {
            // SD gets cleared
            cd[(int)Buff.SD] = 0;
        }
        // process procs
        if (gcProc)
        {
            if (ability != Ability.CS) throw new InvalidOperationException("GC proc only from CS");
            // GC
            cd[(int)Buff.GC] = StateManager.Cooldown[(int)Buff.GC];
            cd[(int)Ability.AS] = 0;
        }
        if (sdProc)
        {
            if (ability != Ability.J && ability != Ability.AS) throw new InvalidOperationException("SD proc only from J or AS");
            // SD
            cd[(int)Buff.SD] = StateManager.Cooldown[(int)Buff.SD];
        }
        if (egProc)
        {
            if (s.TimeRemaining(Buff.EGICD) > 0) throw new InvalidOperationException("EG ICD prevents EG proc");
            if (ability != Ability.WOG) throw new InvalidOperationException("EG proc only from WoG");
            hp = s.hp;
            cd[(int)Buff.EGICD] = StateManager.Cooldown[(int)Buff.EGICD];
        }
        // Advance time by abilityDuration
        for (int i = 0; i < s.cd.Length; i++)
        {
            cd[i] = Math.Max(0, cd[i] - abilityDuration);
        }
        packedForm = CalculatePackedForm();
    }
    /// <summary>
    /// Determines if GrCr will proc in the given state.
    /// </summary>
    /// <returns>True if GrCr will proc, false otherwise.</returns>
    public bool GcWillProcHP()
    {
        return TimeRemaining(Buff.GC) > 0 && TimeRemaining(Buff.GCICD) == 0;
    }
    /// <summary>
    /// Cooldown remaining on the given ability
    /// </summary>
    /// <param name="ability">Ability</param>
    /// <returns>Cooldown remaining in ms.</returns>
    public int CooldownRemaining(Ability ability)
    {
        if (ability == Ability.Nothing) return 0;
        return cd[(int)ability];
    }
    /// <summary>
    /// Time remaining on the given buff.
    /// </summary>
    /// <param name="buff">Buff to check</param>
    /// <returns>Time remaining in ms.</returns>
    public int TimeRemaining(Buff buff)
    {
        return cd[(int)buff];
    }
    public int HP()
    {
        return hp;
    }
    /// <summary>
    /// Compares states
    /// </summary>
    /// <param name="obj">Object to compare</param>
    /// <returns>True if the object is a state and matches the current state, false otherwise.</returns>
    public override bool Equals(object obj)
    {
        State s = obj as State;
        if (s == null) return false;
        //if (FieldEquals(s) != FastEquals(s)) throw new Exception("encoded Form is invalid"); // Sanity check
        return FastEquals(s);
    }
    private bool FieldEquals(State s)
    {
        if (hp != s.hp) return false;
        for (int i = 0; i < cd.Length; i++) if (cd[i] != s.cd[i]) return false;
        return true;
    }
    private bool FastEquals(State s)
    {
        return packedForm == s.packedForm;
    }
    /// <summary>
    /// Hash function implementation so two instances of <see cref="State"/> objects which are equal hash to the same value.
    /// </summary>
    /// <remarks>Required so State can be used as the key in an <see cref="IDictionary"/>.</remarks>
    /// <returns>State hash</returns>
    public override int GetHashCode()
    {
        return (int)packedForm ^ ((int)(packedForm >> 32));
        //return cd.Aggregate(hp, (hash, value) => hash ^ value); // terrible hash function - we only use 6 bits
    }
    public override string ToString()
    {
        return cd.Aggregate("HP" + hp.ToString(), (str, value) => str + ", " + value / 1000.0);
    }
    private long CalculatePackedForm()
    {
        long value = 0;
        long multiplier = 1;
        value += hp * multiplier;
        multiplier *= 4;
        for (int i = 0; i < cd.Length; i++)
        {
            if (StateManager.Cooldown[i] != 0)
            {
                value += cd[i] / 500 * multiplier;
                multiplier *= StateManager.Cooldown[i] / 500;
            }
        }
        return value;
    }
    private long packedForm = 0;
    /// <summary>
    /// HP in the current state
    /// </summary>
    private int hp = 0;
    /// <summary>
    /// CD of all abilities and buffs. Abilities with nonzero CD are not able the be used immediately and buffs with nonzero CD
    /// are active and will expire when the CD reaches zero (or they are consumed by an ability).
    /// </summary>
    /// <remarks>Using a single array is a slight hack but works since I have explicity set the enum values of all abilities and buffs.</remarks>
    private int[] cd = new int[(int)Buff.GCICD + 1];
}
public class Node
{
    public State state;
    public double probability;
    public Outcome[] outcomes;
}
public class Outcome
{
    public Outcome(Ability ability, bool hit, double probability, State nextState)
    {
        this.ability = ability;
        this.hit = hit;
        this.probability = probability;
        this.nextState = nextState;
        nextStateIndex = -1;
        transitionDuration = 1500; // default to 1.5s
    }
    public Ability ability;
    public bool hit;
    public double probability;
    public State nextState;
    public int nextStateIndex;
    public int transitionDuration;
    public string ActionString(State s)
    {
        string modifiers = "";
        if (ability == Ability.WOG || ability == Ability.SOTR) modifiers += String.Format("({0}HP)", s.HP());
        if (ability == Ability.SOTR && s.TimeRemaining(Buff.SD) > 0) modifiers += "(SD)";
        if (transitionDuration != 1500)
        {
            modifiers += String.Format("({0}ms delay)", transitionDuration - 1500);
        }
        return String.Format("{0}{1}",
            ability,
            // hit ? "" : "(miss)",
            modifiers);
    }
    public string ToString(State s)
    {
        string modifiers = "";
        if (ability == Ability.WOG || ability == Ability.SOTR) modifiers += String.Format("({0}HP)", s.HP());
        if (ability == Ability.SOTR && s.TimeRemaining(Buff.SD) > 0) modifiers += "(SD)";
        return String.Format("{0}->S{1}({2})",
            ActionString(s),
            nextStateIndex,
            probability);
    }
}
public class StateManager
{
    /// <summary>
    /// Cooldown of abilities defined in the <see cref="Ability"/> enum as well as buffs defined in the <see cref="Buff"/> enum.
    /// </summary>
    public static int[] Cooldown = new double[] {
        3, 8, 15, 30, 15, 0, 20, 0, // Abilities
        6, 15, 12, 15, 3.5 // Buffs
    }.Select(cd => (int)(cd * 1000)).ToArray(); // 1ms steps
    /// <summary>
    /// Creates a function that uses whichever ability highest in priority 
    /// </summary>
    /// <param name="abilities">Priority of abilities</param>
    /// <param name="subGcdDelay">All and ability to be used if it has less than 1500ms remaining on CD and no other ability can be used.</param>
    /// <returns>Function that chooses an ability to use for each state.</returns>
    public static Func<State, Ability> CreatePriority(Ability[] abilities, bool subGcdDelay = false)
    {
        return s =>
        {
            // Use ability if it's up
            for (int i = 0; i < abilities.Length; i++)
            {
                switch (abilities[i])
                {
                    case Ability.SOTR:
                        if (s.HP() >= 3) return Ability.SOTR; // only use SOTR on 3HP
                        break;
                    default:
                        if (s.CooldownRemaining(abilities[i]) == 0) return abilities[i];
                        break;
                }
            }
            // Use ability if it'll be up before we spend a GCD doing nothing
            if (subGcdDelay)
            {
                for (int i = 0; i < abilities.Length; i++)
                {
                    switch (abilities[i])
                    {
                        case Ability.SOTR:
                            break;
                        default:
                            if (s.CooldownRemaining(abilities[i]) < 1500) return abilities[i];
                            break;
                    }
                }
            }
            return Ability.Nothing;
        };
    }
    static void Main(string[] args)
    {
        StateManager sm = new StateManager();
        //sm.CalculateSearchSpaceCoverage(true);
        //Node[] n = sm.CalculateGraph(CreatePriority(new Ability[] { Ability.SOTR, Ability.CS }));
        //sm.DumpGraph(n);
        Console.WriteLine("Press any key to continue.");
        Console.ReadLine();
        Process(new Ability[] { Ability.SOTR, Ability.CS });
        Console.WriteLine();
        Process(new Ability[] { Ability.SOTR, Ability.CS, Ability.J });
        Console.WriteLine();
        Process(new Ability[] { Ability.SOTR, Ability.CS, Ability.J }, true);
        Console.WriteLine();
        Process(new Ability[] { Ability.SOTR, Ability.CS, Ability.J, Ability.AS, Ability.CONS, Ability.HW });
        Console.WriteLine();
        Process(new Ability[] { Ability.SOTR, Ability.CS, Ability.J, Ability.AS, Ability.HW, Ability.CONS });
        Console.WriteLine();
        Process(new Ability[] { Ability.SOTR, Ability.CS, Ability.AS, Ability.J, Ability.CONS, Ability.HW });
        Console.WriteLine();
        Process(new Ability[] { Ability.SOTR, Ability.CS, Ability.AS, Ability.J, Ability.HW, Ability.CONS });
        Console.WriteLine();
        //new StateManager().CalculateSearchSpaceCoverage(true);
        //new StateManager().CalculateSearchSpaceCoverage(false);
        Console.WriteLine("Press any key to exit program.");
        Console.ReadLine();
    }
    static void Process(Ability[] priority, bool subGcdDelay = false)
    {
        string name = priority.Aggregate("", (str, a) => (str == "" ? str : str + ">") + a.ToString()) + (subGcdDelay ? "_delay" : "");
        var choice = CreatePriority(priority, subGcdDelay);
        Console.WriteLine("Processing " + name);
        StateManager sm = new StateManager();
        Node[] graph = sm.CalculateGraph(choice);
        sm.PrintAbilityProbabilities(graph);
        sm.SaveAsLibSea(graph, name + ".graph");
        
    }
    /// <summary>
    /// Converts a State-Outcome graph into a node list.
    /// </summary>
    /// <param name="graph"></param>
    /// <returns></returns>
    public Node[] CreateNodeList(IDictionary<State, Outcome[]> graph)
    {
        int nodeCount = graph.Count;
        Node[] states = new Node[nodeCount];
        Dictionary<State, int> stateIndex = new Dictionary<State, int>();
        int i = 0;
        foreach (var kvp in graph)
        {
            stateIndex.Add(kvp.Key, i);
            states[i++] = new Node()
            {
                state = kvp.Key,
                outcomes = kvp.Value,
                // Initially sssume equal probability
                probability =  1d / graph.Count,
            };
        }
        // populate remaining node information
        foreach (Node n in states)
        {
            for (int j = 0; j < n.outcomes.Length; j++)
            {
                n.outcomes[j].nextStateIndex =  stateIndex[n.outcomes[j].nextState];
                n.outcomes[j].transitionDuration = 1500 + n.state.CooldownRemaining(n.outcomes[j].ability);
            }
        }
        return states;
    }
    public void PrintAbilityProbabilities(Node[] graph)
    {
        Dictionary<string, double> actions = new Dictionary<string, double>();
        double transitionDuration = 0;
        foreach (Node n in graph.OrderBy(node => node.probability)) // Add the small numbers first to reduce error
        {
            foreach (Outcome o in n.outcomes)
            {
                double p = n.probability * o.probability;
                string action = o.ActionString(n.state);
                if (actions.ContainsKey(action)) actions[action] += p;
                else actions[action] = p;

                transitionDuration += p * o.transitionDuration;
            }
        }
        foreach (var kvp in actions.OrderByDescending(kvp => kvp.Value))
        {
            Console.WriteLine("{0}\t{1}", kvp.Value, kvp.Key);
        }
        Console.WriteLine("{0}ms average transition time", transitionDuration);
    }
    /// <summary>
    /// Calculates the dps ability weightings for a given rotation
    /// </summary>
    /// <param name="choice">Function to determine which ability to use when in a given state.</param>
    /// <returns>Node list with probabilities calculated.</returns>
    public Node[] CalculateGraph(Func<State, Ability> choice)
    {
        DateTime graphStart = DateTime.Now;
        var s = GenerateGraphForRotation(choice);
        var n = CreateNodeList(s);
        int iterations;
        DateTime prStart = DateTime.Now;
        double error = CalculateStateProbabilityIterative(n, 2048, out iterations);
        Console.WriteLine("State probability iteration stopped after {0} iterations with error {1}. ({2}ms generating graph, {3}ms converging)",
            iterations,
            error,
            (prStart - graphStart).TotalMilliseconds,
            (DateTime.Now - prStart).TotalMilliseconds);
        return n;
    }
    /// <summary>
    /// Iteratively calculate probabilities for each state
    /// </summary>
    /// <param name="nodes">Graph in Node list form to use.</param>
    /// <param name="maxInterations">Maximum number of iterations to perform</param>
    /// <param name="iterations">Returns the number of iterations performed</param>
    /// <returns>Percentage error margin remaining after iteration</returns>
    public double CalculateStateProbabilityIterative(Node[] nodes, int maxInterations, out int iterations)
    {
        iterations = 0;
        double error = 1;
        while (error > 0.000000000001 && ++iterations <= maxInterations)
        {
            error = IterateStateProbability(nodes);
        }
        return error;
    }
    /// <summary>
    /// Performs a single iteration updating the node probabilities
    /// </summary>
    /// <param name="nodes">Graph in Node list form to use.</param>
    /// <returns>Maximum percentage change in the probability of a node.</returns>
    public double IterateStateProbability(Node[] nodes)
    {
        // calculate probability
        double[] p = new double[nodes.Length]; // (C# auto-initialises arrays to zeros)
        for (int i = 0; i < nodes.Length; i++)
        {
            Node n = nodes[i];
            foreach (Outcome o in n.outcomes)
            {
                p[o.nextStateIndex] += n.probability * o.probability;
            }
        }
        // update probability
        double maxChange = 0;
        for (int i = 0; i < nodes.Length; i++)
        {
            double oldValue = nodes[i].probability;
            double newValue = p[i];
            nodes[i].probability = newValue;

            double absChange = Math.Abs(newValue - oldValue);
            if (absChange != 0)
            {
                maxChange = Math.Max(maxChange, absChange / Math.Max(newValue, oldValue));
            }
        }
        // Console.WriteLine("Max change: {0}", maxChange);
        return maxChange;
    }
    public Dictionary<State, Outcome[]> GenerateGraphForRotation(Func<State, Ability> choice)
    {
        Dictionary<State, Outcome[]> stateSpace = new Dictionary<State, Outcome[]>();
        Stack<State> frontier = new Stack<State>();
        State root = new State();
        frontier.Push(root);
        while (frontier.Count > 0)
        {
            State s = frontier.Pop();
            Outcome[] outcomes = GetOutcomes(s, choice(s)).ToArray();
            stateSpace.Add(s, outcomes);
            foreach (Outcome o in outcomes)
            {
                State nextState = o.nextState;
                if (!stateSpace.ContainsKey(nextState) && !frontier.Contains(nextState))
                {
                    frontier.Push(nextState);
                }
            }
            //if (stateSpace.Count % 10000 == 0)
            //{
            //    Console.WriteLine("Current Size: {0} ({1})", stateSpace.Count, frontier.Count);
            //}
        }            
        Console.WriteLine("Total Verticies: {0}, Edges: {1}", stateSpace.Count, stateSpace.Aggregate(0, (sum, kvp) => sum + kvp.Value.Length));
        return stateSpace;
    }
    /// <summary>
    /// Returns the possible outcomes when using the given ability in the given state.
    /// </summary>
    /// <param name="s">Current state of cooldowns</param>
    /// <param name="a">Ability to use</param>
    /// <returns>Possible outcome from using the given ability.</returns>
    public IEnumerable<Outcome> GetOutcomes(State s, Ability a)
    {
        // TODO: move StateManager.Cooldown and miss/dodge/parry rates into parameters instead of hardcoding them here
        double m = 0.08; // TODO: spell miss vs melee miss
        double mdp = m + 0.065 + 0.14;
        int abilityCD = (a == Ability.Nothing) ? 0 : Cooldown[(int)a];
        int waitTime = s.CooldownRemaining(a);

        double sdProcRate = 0.5;
        double gcProcRate = 0.2;
        double egProcRate = 0.3;
        switch (a)
        {
            case Ability.AS:
            case Ability.J:
                yield return new Outcome(a, true, (1 - m) * sdProcRate, new State(s, a, abilityCD, true, waitTime: waitTime, sdProc: true));
                yield return new Outcome(a, true, (1 - m) * (1 - sdProcRate), new State(s, a, abilityCD, true, waitTime: waitTime));
                yield return new Outcome(a, false, m, new State(s, a, abilityCD, false));
                break;
            case Ability.CS:
                yield return new Outcome(a, true, (1 - mdp) * gcProcRate, new State(s, a, abilityCD, true, waitTime: waitTime, gcProc: true));
                yield return new Outcome(a, true, (1 - mdp) * (1 - gcProcRate), new State(s, a, abilityCD, true, waitTime: waitTime));
                yield return new Outcome(a, false, mdp, new State(s, a, abilityCD, false, waitTime: waitTime));
                break;
            case Ability.SOTR:
                yield return new Outcome(a, true, (1 - mdp), new State(s, a, abilityCD, true, waitTime: waitTime));
                yield return new Outcome(a, false, mdp, new State(s, a, abilityCD, false, waitTime: waitTime));
                break;
            case Ability.HW:
            case Ability.CONS:
            default:
                yield return new Outcome(a, true, (1 - m), new State(s, a, abilityCD, true, waitTime: waitTime));
                yield return new Outcome(a, false, m, new State(s, a, abilityCD, false, waitTime: waitTime));
                break;
            case Ability.WOG:
                yield return new Outcome(a, true, egProcRate, new State(s, a, abilityCD, true, waitTime: waitTime, egProc: true));
                yield return new Outcome(a, true, 1 - egProcRate, new State(s, a, abilityCD, true, waitTime: waitTime));
                break;
            case Ability.INQ:
            case Ability.Nothing:
                // Always the same next state
                State nextState = new State(s, a, abilityCD, true, waitTime: waitTime);
                yield return new Outcome(a, true, 1.0, nextState);
                break;
        }
    }
    /// <summary>
    /// Calculate the total reachable search state
    /// </summary>
    /// <param name="noWait">Allow waiting for abilities to come off CD before using.</param>
    public void CalculateSearchSpaceCoverage(bool noWait)
    {
        HashSet<State> stateSpace = new HashSet<State>();
        Stack<State> frontier = new Stack<State>();
        State root = new State();
        frontier.Push(root);
        stateSpace.Add(root);
        while (frontier.Count > 0)
        {
            State s = frontier.Pop();
            //Console.WriteLine(s);
            foreach (State nextState in GetSearchSpaceCoverageStates(s, noWait))
            {
                if (!stateSpace.Contains(nextState))
                {
                    frontier.Push(nextState);
                    stateSpace.Add(nextState);
                    if (stateSpace.Count % 100000 == 0)
                    {
                        Console.WriteLine("Current Size: {0} ({1})", stateSpace.Count, frontier.Count);
                    }
                }
            }
        }
        Console.WriteLine("Total Size: {0}", stateSpace.Count);
    }
    /// <summary>
    /// Calculates all possible outcomes from the given state.
    /// </summary>
    /// <param name="s"></param>
    /// <param name="noWait">Allow waiting for abilities to come off CD before using.</param>
    /// <returns>All possible outcomes from the given state</returns>
    public IEnumerable<State> GetSearchSpaceCoverageStates(State s, bool noWait)
    {
        foreach (Ability a in GetSearchSpaceCoverageOptions(s, noWait))
        {
            foreach (Outcome o in GetOutcomes(s, a))
            {
                yield return o.nextState;
            }
        }
    }
    /// <summary>
    /// Returns all possible ability usages for the given state.
    /// </summary>
    /// <param name="s"></param>
    /// <param name="noWait">Allow waiting for abilities to come off CD before using.</param>
    /// <returns>All possible abilities that can be used when in the given state.</returns>
    public IEnumerable<Ability> GetSearchSpaceCoverageOptions(State s, bool noWait)
    {
        if ((!noWait || s.CooldownRemaining(Ability.SOTR) == 0) && s.HP() > 0) yield return Ability.SOTR;
        if ((!noWait || s.CooldownRemaining(Ability.WOG) == 0) && s.HP() > 0) yield return Ability.WOG;
        if ((!noWait || s.CooldownRemaining(Ability.INQ) == 0) && s.HP() > 0) yield return Ability.INQ;
        if (!noWait || s.CooldownRemaining(Ability.CS) == 0) yield return Ability.CS;
        if (!noWait || s.CooldownRemaining(Ability.J) == 0) yield return Ability.J;
        if (!noWait || s.CooldownRemaining(Ability.AS) == 0) yield return Ability.AS;
        if (!noWait || s.CooldownRemaining(Ability.CONS) == 0) yield return Ability.CONS;
        if (!noWait || s.CooldownRemaining(Ability.HW) == 0) yield return Ability.HW;
        yield return Ability.Nothing;
    }
    /// <summary>
    /// Dumps the node graph to the console.
    /// </summary>
    /// <remarks>SOTR>CS is the only rotation for which this is vaguely readable.</remarks>
    /// <param name="n">Graph to dump.</param>
    public void DumpGraph(Node[] n)
    {
        for (int i = 0; i < n.Length; i++)
        {
            Console.WriteLine("S{0}\t{1}\t{2}\t{3}",
                i,
                n[i].state,
                n[i].probability,
                n[i].outcomes.Aggregate("(", (str, o) => str + o.ToString(n[i].state) + ", ") + ")"
            );
        }
    }
    /// <summary>
    /// Saves a graph in LibSea file format for visualisation with http://www.caida.org/tools/visualization/walrus/
    /// </summary>
    /// <remarks>Did not work: Walrus only display spanning trees which is not what we want.</remarks>
    /// <param name="graph">Graph to save</param>
    /// <param name="file">filename to save as</param>
    public void SaveAsLibSea(Node[] graph, string file)
    {
        int linkCount = graph.Aggregate(0, (sum, n) => sum + n.outcomes.Length);
        file = file.Replace(">", "-");
        Dictionary<Outcome, int> linkNumber = new Dictionary<Outcome, int>();        
        using (FileStream fs = File.Open(file, FileMode.Create))
        using (StreamWriter sw = new StreamWriter(fs, Encoding.ASCII))
        {
            sw.WriteLine("Graph");
            sw.WriteLine("{");
            sw.WriteLine("\t{0};  ## (opt) name", "");
            sw.WriteLine("\t{0};  ## (opt) description", "");
            sw.WriteLine("\t{0};  ## number of nodes", graph.Length);
            sw.WriteLine("\t{0};  ## number of links", linkCount);
            sw.WriteLine("\t{0};  ## number of paths", 0);
            sw.WriteLine("\t{0};  ## number of links in all paths", 0);
            
            sw.WriteLine("### structural data ###");
            sw.WriteLine("\t@links=[");
            int currentLinkNumber = 0;
            for (int i = 0; i < graph.Length; i++) {
                bool lastNode = i + 1 >= graph.Length;
                Node n = graph[i];
                for (int j = 0; j < n.outcomes.Length; j++) {
                    Outcome o = n.outcomes[j];
                    sw.Write("\t\t{ @source=" + i.ToString() +"; @destination=" + o.nextStateIndex.ToString() + "; }");
                    sw.WriteLine((lastNode && j + 1 >= n.outcomes.Length) ? "" : ",");
                    linkNumber[o] = currentLinkNumber++;
                }
            }
            sw.WriteLine("\t];");
            sw.WriteLine("\t@paths=;");

            sw.WriteLine("\t");

            // use the highest probability node as the root
            double maxPr = graph.Max(n => n.probability);
            int root = -1;
            for (int i = 0; i < graph.Length; i++) if (graph[i].probability == maxPr) { root = i; break; }
            sw.WriteLine("\t### attribute data ###");
            sw.WriteLine("\t@enumerations=;");
            sw.WriteLine("\t@attributeDefinitions=[{");
            sw.WriteLine("\t\t@name=$root;");
            sw.WriteLine("\t\t@type=bool;");
            sw.WriteLine("\t\t@default=|| false ||;");
            sw.WriteLine("\t\t@nodeValues=[ { @id=" + root.ToString() + "; @value=T; } ];");
            sw.WriteLine("\t\t@linkValues=;");
            sw.WriteLine("\t\t@pathValues=;");
            sw.WriteLine("\t},{");
            sw.WriteLine("\t\t@name=$tree_link;");
            sw.WriteLine("\t\t@type=bool;");
            sw.WriteLine("\t\t@default=|| false ||;");
            sw.WriteLine("\t\t@nodeValues=;");
            sw.WriteLine("\t\t@linkValues=[");
            // We'll use the greatest probability link N deep from the starting node as our spanning tree
            int[] spanningTree = CalculateMaxProbabilitySpanningTree(graph, root, linkNumber);
            for (int i = 0; i < spanningTree.Length; i++)
            {
                sw.Write("\t\t\t{ @id=" + spanningTree[i].ToString() + "; @value=T; }");
                sw.WriteLine(i + 1 >= spanningTree.Length ? "" : ",");
            }
            sw.WriteLine("\t\t];");
            sw.WriteLine("\t\t@pathValues=;");
            sw.WriteLine("\t}];");
            sw.WriteLine("\t@qualifiers=[");
            sw.WriteLine("\t\t{");
            sw.WriteLine("\t\t\t@type=$spanning_tree;");
            sw.WriteLine("\t\t\t@name=$sample_spanning_tree;");
            sw.WriteLine("\t\t\t@description=;");
            sw.WriteLine("\t\t\t@attributes=[");
            sw.WriteLine("\t\t\t\t{ @attribute=0; @alias=$root; },");
            sw.WriteLine("\t\t\t\t{ @attribute=1; @alias=$tree_link; }");
            sw.WriteLine("\t\t\t];");
            sw.WriteLine("\t\t}");
            sw.WriteLine("\t];");

            sw.WriteLine("\t### visualization hints ###");
            sw.WriteLine("\t@filters=;");
            sw.WriteLine("\t@selectors=;");
            sw.WriteLine("\t@displays=;");
            sw.WriteLine("\t@presentations=;");
            sw.WriteLine("\t");

            sw.WriteLine("\t### interface hints ###");
            sw.WriteLine("\t@presentationMenus=;");
            sw.WriteLine("\t@displayMenus=;");
            sw.WriteLine("\t@selectorMenus=;");
            sw.WriteLine("\t@filterMenus=;");
            sw.WriteLine("\t@attributeMenus=;");
            sw.WriteLine("}");
        }
    }
    // BFS through the nodes
    public int[] CalculateMaxProbabilitySpanningTree(Node[] graph, int root, Dictionary<Outcome, int> linkNumber)
    {
        List<int> spanningLinks = new List<int>();
        Stack<Tuple<int, double>> frontier = new Stack<Tuple<int, double>>();
        HashSet<int> visited = new HashSet<int>();
        frontier.Push(new Tuple<int, double>(root, 1.0));
        visited.Add(root);
        while (frontier.Count > 0)
        {
            Dictionary<int, Tuple<double, Outcome>> bestLinkToState = new Dictionary<int, Tuple<double, Outcome>>();
            foreach (var tuple in frontier)
            {
                int stateIndex = tuple.Item1;
                double ps = tuple.Item2;
                Node n = graph[stateIndex];
                foreach (Outcome o in n.outcomes)
                {
                    if (!visited.Contains(o.nextStateIndex))
                    {
                        double po = ps * o.probability;
                        if (!bestLinkToState.ContainsKey(o.nextStateIndex) || bestLinkToState[o.nextStateIndex].Item1 < po)
                        {
                            bestLinkToState[o.nextStateIndex] = new Tuple<double, Outcome>(po, o);
                        }
                    }
                }
            }
            // We've found out set of next best states: take another step
            frontier.Clear();
            foreach (var kvp in bestLinkToState)
            {
                int stateIndex = kvp.Key;
                double p = kvp.Value.Item1;
                Outcome o = kvp.Value.Item2;
                spanningLinks.Add(linkNumber[o]);
                frontier.Push(new Tuple<int, double>(stateIndex, p));
                visited.Add(stateIndex);
            }
        }
        return spanningLinks.ToArray();
    }
}
