Matlabadin C# Finite State Machine Calculator

See http://maintankadin.failsafedesign.com/forum/viewtopic.php?f=6&t=29317 for outline 

Project Structure:
	Matlabadin: FSM algorithm implementation compiling to fsm.exe command-line tool
	Matlabadin.RotationUI: partially implemented interface for graph traversal
	Matlabadin.Tests: test suite for algorithm code

Matlabadin project structure:
	Ability.cs: enum definition of all possible abilities
	ArrayStateManager.cs: StateManager implementation using arrays. This is slower than the Int64 implementation but can model more steps per GCD. Currently not used.
	Buff.cs: enum definition of all possible rotation-dependent self-buffs
	Choice.cs: this class contains the metadata (excluding source & destination states) such as transition duration and ability used associated with a state transition.
	GraphParameters.cs: contains input parameters such as talents, hit, expertise & steps per GCD
	IStateManager.cs: interface required for StateManager classes which expose state information. Ideally, these methods would be part of the state class itself but for performance reasons (would need a reference to GraphParameters on every state) they are not. Note that the state class itself is opaque and all access to it is through a StateManager.
	Int64GraphParameters.cs: Implementation of both GraphParameters & IStateManager using a 64-bit integers as states.
	MatlabadinGraph.cs: Algorithm implementation. This class traverses the reachable state space, calculates each state probability & outputs aggregated choice information
	Program.cs: command-line entry-point. Performs command-line parsing and processing
	RotationPriorityQueue.cs: Ability choice parser. This class parses the ability 'rotation' string and coverts that to an ability choice for any given state.
	StateHelper.cs: implementation-independent state transition & ability usage logic.

TLDR summary for maintenance & code review:
	StateHelper.NextStates(): next state transition logic
	RotationPriorityQueue: ability choice logic

	MatlabadinGraph.GenerateGraph(): graph generation
	MatlabadinGraph.CalculateResults(): state probability and aggregated ability usage calculations
	Program: command-line processing