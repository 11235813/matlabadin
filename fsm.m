%    Prot Pal Rotation state machine
%    Copyright (C) 2011 Daniel Cameron
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.


% graphParameters is a struct containing the following fields:
% spmiss = 0.08;
% miss = 0.08;
% dodge = 0.065;
% parry = 0.14;
% egProcRate = 0.30;
% sdProcRate = 0.50;
% gcProcRate = 0.20;
% priorityQueue = {'SotR', 'CS', 'J', 'AS'};

% [action, pr] = fsm(struct('priorityQueue', {'SotR', 'CS', 'J', 'AS', 'HW'}, 'spmiss', 0.08, 'miss', 0.08, 'dodge', 0.065, 'parry', 0.14, 'egProcRate', 0.3, 'sdProcRate', 0.5, 'gcProcRate', 0.2))
function  [action, pr] = fsm(graphParameters, printTransitions)
global fsmInternal;
if nargin<3
    printTransitions = 0;
end
% unit testing hack
if nargin == 0
    warning('Executing fsm unit tests');
    tic();
    fsm_rununitests();
    toc()
    warning('fsm unit tests complete');
    return
end
fsm_init();
% start with no HP and everything off CD
initialState = zeros(1, fsmInternal.StateVectorSize);
% calculate the state transition matrix
[M, stateVector] = fsm_generateStateTransitionMatrix(graphParameters, initialState, printTransitions);
% solve Mx=[0,...,0,1]
% note that M appears overdetermined but one of the equations is not linearly independant so we're ok
B = [zeros(1, length(stateVector)) 1]';
% x = M\B; % Octave does not like QR factorization for 20000+
x = fsm_iterative_solve(M);
% and it appears we're not positive definite
%x = pcg(M(2:end,:), [zeros(1, length(stateVector)-1) 1]', 1e-8);
%x = pcg(M(2:end,:), [zeros(1, length(stateVector)-1) 1]', 1e-8, length(stateVector), [], ones(length(stateVector)) / length(stateVector));
x = x';
if printTransitions
    for i = 1:length(x)
        printf('%s [%s] %f\n', fsm_getStateKey(stateVector(i).state), stateVector(i).actionString, x(i));
    end
    %full(M)
    %B
    %fsmlinsolve(M, B)
    %M*(x')
end
action = sort(unique({stateVector.actionString}));
pr = zeros(1, length(action));
for i = 1:length(action)
    currentAction = action{i};
    pr(i) = sum(x.*arrayfun(@(sv) strcmp(currentAction, sv.actionString), stateVector));
end
return
end
function fsm_init (stepSize, usingConsGlyph)
global fsmInternal;
if nargin<1
    stepSize = 0.5;
end
if nargin<2
    usingConsGlyph = 0;
end
fsmInternal.StepSize = stepSize;
fsmInternal.GcdSteps = 1.5 / fsmInternal.StepSize;
fsmInternal.AbilityCoolDownName = {'AS', 'CS', 'Cons', 'HW', 'J', 'WoG'};
fsmInternal.AbilityCoolDown = [15, 3, 30 * (1 + 0.2 * usingConsGlyph), 15, 8, 20] / fsmInternal.StepSize;
fsmInternal.BuffDurationName = {'EGICD', 'GC', 'GCICD', 'Inq', 'SD'};
fsmInternal.BuffDuration = [15, 6, 3.5, 12, 10] / fsmInternal.StepSize; % (Inq buff duration is for 3HoPo)
fsmInternal.StateVectorSize = 1 + length(fsmInternal.AbilityCoolDown) + length(fsmInternal.BuffDuration);
fsmInternal.StateSpaceSize = ceil([3 ([fsmInternal.AbilityCoolDown fsmInternal.BuffDuration ] - fsmInternal.GcdSteps)]) + 1;
fsmInternal.StateEncodingProducts = cumprod([ 1 fsmInternal.StateSpaceSize(1:end-1)]);
fsmInternal.StateKeyFormatString = 'S%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d';
fsmInternal.BuffIndex.EGICD = 1;
fsmInternal.BuffIndex.GC = 2;
fsmInternal.BuffIndex.GCICD = 3;
fsmInternal.BuffIndex.Inq = 4;
fsmInternal.BuffIndex.SD = 5;
% Offsets in the state
fsmInternal.HoPoOffset = 1;
fsmInternal.AbilityStateOffset = 1;
fsmInternal.BuffStateOffset = fsmInternal.AbilityStateOffset + length(fsmInternal.AbilityCoolDown);
end

% state vector nodes contain the vector [hp, ability CoolDowns, buff durations]
% Info that is implicit in state definition:
%	state number (vector index)
%	state key
%	ability to use
%	wait time
%	pr of state transitions
function [M, stateVector] = fsm_generateStateTransitionMatrix(graphParameters, initialState, printTransitions)
global fsmInternal;
if nargin<3
    printTransitions = 0;
end
statesToPreallocate = 100000;
transitionsToPreallocate = statesToPreallocate * 4;
% preallocate array space for states
stateVector(statesToPreallocate).state = zeros(1, fsmInternal.StateVectorSize);
mi = zeros(1, transitionsToPreallocate);
mj = zeros(1, transitionsToPreallocate);
ms = zeros(1, transitionsToPreallocate);
% set up initial state
stateVector(1).state = initialState;
stateLookup = []; % using struct as a hashmap. Run perftest.m to ensure this is reasonable for matlab as well as Octave
stateLookup.(fsm_getStateKey(stateVector(1).state)) = 1;
tupleIndex = 1;
stateIndex = 1;
totalStateSpaceSize = 1;
while stateIndex <= totalStateSpaceSize
    stateVector(stateIndex).abilityToUse = fsm_chooseAbilityFromPriorityQueue(graphParameters.priorityQueue, stateVector(stateIndex).state);
    stateVector(stateIndex).actionString = fsm_abilityDamageContext(stateVector(stateIndex).abilityToUse, stateVector(stateIndex).state);
    [next, nextPr] = fsm_calculatePossibleNextStates(stateVector(stateIndex).state, stateVector(stateIndex).abilityToUse, graphParameters);
    prSelfTransition = 0;
    for i=1:length(next),
        nextState = next{i};
        nextStateKey = fsm_getStateKey(nextState);
        try
            nextIndex = stateLookup.(nextStateKey);
        catch
            nextIndex = 0;
        end
        if nextIndex <= 0
            % new state: add it
            totalStateSpaceSize = totalStateSpaceSize + 1;
            nextIndex = totalStateSpaceSize;
            stateVector(nextIndex).state = nextState;
            stateLookup.(nextStateKey) = nextIndex;
        end
        if nextIndex == stateIndex
            % self transition
            prSelfTransition = prSelfTransition+ nextPr(i);
        else
            mi(tupleIndex) = nextIndex;
            mj(tupleIndex) = stateIndex;
            ms(tupleIndex) = -nextPr(i);
            tupleIndex = tupleIndex + 1;
        end
        if printTransitions
            disp(sprintf('%s [%s]-> %s (%f)\n', fsm_getStateKey(stateVector(stateIndex).state), stateVector(stateIndex).abilityToUse, nextStateKey, nextPr(i)));
        end
    end
    mi(tupleIndex) = stateIndex;
    mj(tupleIndex) = stateIndex;
    ms(tupleIndex) = 1 - prSelfTransition;
    tupleIndex = tupleIndex + 1;
    % process next state
    stateIndex = stateIndex + 1;
    if mod(stateIndex, 1000) == 0
        warning('Generated "%d" states so far',stateIndex);
    end
end
% add a final row of ones since sum(pr(s)) = 1 and turn the tuples into a sparse matrix
M = sparse([mi(1:tupleIndex-1) ones(1,totalStateSpaceSize)*(totalStateSpaceSize+1)], [mj(1:tupleIndex-1) 1:totalStateSpaceSize], [ms(1:tupleIndex-1) ones(1, totalStateSpaceSize)]);
stateVector = stateVector(1:totalStateSpaceSize);
if totalStateSpaceSize > 1000
    warning('State size is "%d" states', totalStateSpaceSize);
end
end

function ability = fsm_chooseAbilityFromPriorityQueue(priorityQueue, state)
global fsmInternal;
hopo = state(fsmInternal.HoPoOffset);
for i = 1:length(priorityQueue)
    abilityName = priorityQueue{i};
    if fsm_getRemainingCoolDown(abilityName, state) <= 0
        switch abilityName
            case {'SotR', 'WoG', 'Inq'}
                if hopo == 3
                    ability = abilityName;
                    return
                end
            otherwise
                ability = abilityName;
                return
        end

    end
end
ability = 'Nothing';
end

function actionString = fsm_abilityDamageContext(abilityName, state)
global fsmInternal
str = abilityName;
% add (SD) to SOTR
if strcmp(abilityName, 'SotR') && state(fsmInternal.BuffStateOffset + fsmInternal.BuffIndex.SD) > 0
    str = [str '(SD)'];
end
% add (Inq) if it is up
% Inq affects both SoT procs from white damage
% and SoT procs from melee abilities which are affected in Inq
% so the damage from casting CS(Inq)>CS (assuming SoT)
if state(fsmInternal.BuffStateOffset + fsmInternal.BuffIndex.Inq) > 0
    str = [str '(Inq)'];
end
actionString = str;
end

% graph paramater struct contains: miss, dodge, parry, spmiss, egProcRate, sdProcRate, gcProcRate
function [next, nextPr] = fsm_calculatePossibleNextStates(state, abilityName, graphParameters)
global fsmInternal
waitSteps = fsm_getRemainingCoolDown(abilityName, state);
m = min([1 graphParameters.miss]);
mdp = min([1 (graphParameters.miss + graphParameters.dodge + graphParameters.parry)]);
switch abilityName
    case {'J'}
        % hit and miss transition to the same state
        next{2} = fsm_calculateNextState(state, waitSteps, abilityName, 0, 0, 1, 0);
        next{1} = fsm_calculateNextState(state, waitSteps, abilityName, 1);
        nextPr(2) = (1 - m) * graphParameters.sdProcRate;
        nextPr(1) = 1 - nextPr(2);
    case {'AS'}
        hitState = fsm_calculateNextState(state, waitSteps, abilityName, 0);
        missState = fsm_calculateNextState(state, waitSteps, abilityName, 1);
        procState = fsm_calculateNextState(state, waitSteps, abilityName, 0, 0, 1, 0);
        % hit and miss might transition to the same state (depends if GrCr is up)
        if all(hitState == missState)
            next{2} = procState;
            next{1} = hitState;
            nextPr(2) = (1 - m) * graphParameters.sdProcRate;
            nextPr(1) = 1 - nextPr(2);
        else
            next{3} = procState;
            next{2} = hitState;
            next{1} = missState;
            nextPr(3) = (1 - m) * graphParameters.sdProcRate;
            nextPr(2) = (1 - m) * (1 - graphParameters.sdProcRate);
            nextPr(1) = m;
        end
    case {'CS'}
        hitState = fsm_calculateNextState(state, waitSteps, abilityName, 0);
        missState = fsm_calculateNextState(state, waitSteps, abilityName, 1);
        procState = fsm_calculateNextState(state, waitSteps, abilityName, 0, 0, 0, 1);
        if all(hitState == missState)
            next{2} = procState;
            next{1} = hitState;
            nextPr(2) = (1 - mdp) * graphParameters.gcProcRate;
            nextPr(1) = 1 - nextPr(2);
        else
            next{3} = procState;
            next{2} = hitState;
            next{1} = missState;
            nextPr(3) = (1 - mdp) * graphParameters.gcProcRate;
            nextPr(2) = (1 - mdp) * (1 - graphParameters.gcProcRate);
            nextPr(1) = mdp;
        end
    case {'SotR'}
        next{2} = fsm_calculateNextState(state, waitSteps, abilityName, 0);
        next{1} = fsm_calculateNextState(state, waitSteps, abilityName, 1);
        nextPr(2) = 1 - mdp;
        nextPr(1) = mdp;
    case {'WoG'}
        next{1} = fsm_calculateNextState(state, waitSteps, abilityName);
        nextPr(1) = 1;
        % chance to proc EG iff EGICD = 0
        if state(fsmInternal.BuffStateOffset + fsmInternal.BuffIndex.EGICD) - waitSteps <= 0
            next{2} = fsm_calculateNextState(state, waitSteps, abilityName, 1, 1);
            nextPr(2) = graphParameters.egProcRate;
            nextPr(1) = 1 - graphParameters.egProcRate;
        end
    otherwise %{'HW', 'Cons', 'Inq', 'Nothing'}
        next{1} = fsm_calculateNextState(state, waitSteps, abilityName);
        nextPr(1) = 1;
end
end

function nextState = fsm_calculateNextState(state, waitSteps, abilityName, miss, egProc, sdProc, gcProc)
if nargin<4; miss = 0; end
if nargin<5; egProc = 0; end
if nargin<6; sdProc = 0; end
if nargin<7; gcProc = 0; end

global fsmInternal
hopo = state(fsmInternal.HoPoOffset);
% Advance the wait time
nextState = uint16(state) - waitSteps; % cast to uint so negative CoolDowns clip to 0
% Reset CD on ability
offset = fsm_getAbilityOffset(abilityName);
if offset > 0
    nextState(offset) = fsm_getAbilityCoolDown(abilityName);
end
% Process HoPo explicitly (we trashed it advancing the wait time)
switch abilityName
    case {'SotR', 'WoG'}
        if not(miss)
            hopo = 0;
        end
    case {'Inq'}
        % buff duration is for 3HoPo Inq
        nextState(fsmInternal.BuffStateOffset + fsmInternal.BuffIndex.Inq) = fsmInternal.BuffDuration(fsmInternal.BuffIndex.Inq) * hopo / 3;
        hopo = 0;
    case {'CS'}
        if not(miss)
            hopo = hopo + 1;
        end
    case {'AS'}
        if nextState(fsmInternal.BuffStateOffset + fsmInternal.BuffIndex.GC) > 0
            if not(miss) && nextState(fsmInternal.BuffStateOffset + fsmInternal.BuffIndex.GCICD) == 0
                hopo = hopo + 1;
                % TODO: Is GCICD trigger even when AS misses? need a CS(GrCr proc)->AS(miss)->CS(GrCr proc)->AS(hit) sequence
                % probably doesn't matter much: especially since it'll take an average of 500 attempts to get the above sequence
                nextState(fsmInternal.BuffStateOffset + fsmInternal.BuffIndex.GCICD) = fsmInternal.BuffDuration(fsmInternal.BuffIndex.GCICD);
            end
            % consume GC even on misses
            nextState(fsmInternal.BuffStateOffset + fsmInternal.BuffIndex.GC) = 0;
        end
    otherwise
        nextState(fsmInternal.HoPoOffset) = state(fsmInternal.HoPoOffset);
end
% Process procs
if egProc
    hopo = state(fsmInternal.HoPoOffset);
    nextState(fsmInternal.BuffStateOffset + fsmInternal.BuffIndex.EGICD) = fsmInternal.BuffDuration(fsmInternal.BuffIndex.EGICD);
end
if gcProc
    nextState(fsmInternal.BuffStateOffset + fsmInternal.BuffIndex.GC) = fsmInternal.BuffDuration(fsmInternal.BuffIndex.GC);
    nextState(fsm_getAbilityOffset('AS')) = 0;
end
if sdProc
    nextState(fsmInternal.BuffStateOffset + fsmInternal.BuffIndex.SD) = fsmInternal.BuffDuration(fsmInternal.BuffIndex.SD);
end
% Advance a GCD, HoPo capped at 3
nextState = [min([3 hopo]) (nextState(2:end) - fsmInternal.GcdSteps)];
if nextState >= fsmInternal.StateSpaceSize
    error('Sanity check failed: we have state element that''s larger than the largest possible value');
end
end
function offset = fsm_getAbilityOffset(abilityName)
global fsmInternal
offset = fsm_getAbilityIndex(abilityName);
if offset > 0
    offset = offset + fsmInternal.AbilityStateOffset;
end
end
function index = fsm_getAbilityIndex(abilityName)
global fsmInternal
index = 0;
switch abilityName
    case {'HotR'}
        index = fsm_getAbilityIndex('CS');
    otherwise
        for i = 1:length(fsmInternal.AbilityCoolDownName)
            if strcmp(fsmInternal.AbilityCoolDownName(i), abilityName)
                index = i;
                return
            end
        end
end
end
function cd = fsm_getAbilityCoolDown(abilityName)
global fsmInternal
index = fsm_getAbilityIndex(abilityName);
if index > 0
    cd = fsmInternal.AbilityCoolDown(index);
else
    cd = 0;
end
end
function cd = fsm_getRemainingCoolDown(abilityName, state)
global fsmInternal
index = fsm_getAbilityIndex(abilityName);
if index > 0
    cd = state(fsmInternal.AbilityStateOffset + index);
else
    cd = 0;
end
end
function key = fsm_getStateKey(state)
global fsmInternal
%encoded = sum(fsmInternal.StateEncodingProducts .* uint64(state)); % uint64 encoding
key = sprintf(fsmInternal.StateKeyFormatString, state);
end

function fsm_rununitests()
% initialisation
global fsmInternal;
fsm_init();
testPara.spmiss = 0.08;
testPara.miss = 0.08;
testPara.dodge = 0.065;
testPara.parry = 0.14;
testPara.egProcRate = 0.30;
testPara.sdProcRate = 0.50;
testPara.gcProcRate = 0.20;

% fsm_getStateKey
AssertAreEqual('S1_1_1_1_1_1_1_1_1_1_1_1', fsm_getStateKey(ones(1, 12)));
AssertAreEqual('S0_0_0_0_0_0_0_0_0_0_0_0', fsm_getStateKey(zeros(1, 12)));

% fsm_getAbilityIndex
AssertAreEqual(2, fsm_getAbilityIndex('CS'));
AssertAreEqual(2, fsm_getAbilityIndex('HotR'));
AssertAreEqual(0, fsm_getAbilityIndex('ASDF'));

% fsm_getAbilityCoolDown
AssertAreEqual(3 / 0.5, fsm_getAbilityCoolDown('CS'));
AssertAreEqual(20 / 0.5, fsm_getAbilityCoolDown('WoG'));
AssertAreEqual(8 / 0.5, fsm_getAbilityCoolDown('J'));
AssertAreEqual(0, fsm_getAbilityCoolDown('Nothing'));
AssertAreEqual(0, fsm_getAbilityCoolDown('SotR'));

% fsm_getAbilityOffset
AssertAreEqual(2, fsm_getAbilityOffset('AS'));
AssertAreEqual(0, fsm_getAbilityOffset('Nothing'));

% fsm_abilityDamageContext
AssertAreEqual('Nothing', fsm_abilityDamageContext('Nothing', [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('CS', fsm_abilityDamageContext('CS', [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('CS(Inq)', fsm_abilityDamageContext('CS', [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]));
AssertAreEqual('SotR', fsm_abilityDamageContext('SotR', [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('SotR(SD)', fsm_abilityDamageContext('SotR', [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]));
AssertAreEqual('SotR(SD)(Inq)', fsm_abilityDamageContext('SotR', [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1]));
AssertAreEqual('SotR(Inq)', fsm_abilityDamageContext('SotR', [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]));

% fsm_chooseAbilityFromPriorityQueue

AssertAreEqual('SotR', fsm_chooseAbilityFromPriorityQueue({'SotR'}, [3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('Nothing', fsm_chooseAbilityFromPriorityQueue({'SotR'}, [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('Nothing', fsm_chooseAbilityFromPriorityQueue({'SotR'}, [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('Nothing', fsm_chooseAbilityFromPriorityQueue({'SotR'}, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('CS', fsm_chooseAbilityFromPriorityQueue({'SotR', 'CS'}, [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('Nothing', fsm_chooseAbilityFromPriorityQueue({'SotR', 'CS'}, [2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('AS', fsm_chooseAbilityFromPriorityQueue({'SotR', 'CS', 'AS'}, [2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('Nothing', fsm_chooseAbilityFromPriorityQueue({'SotR', 'CS', 'AS'}, [2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('SotR', fsm_chooseAbilityFromPriorityQueue({'SotR', 'CS', 'AS'}, [3, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('WoG', fsm_chooseAbilityFromPriorityQueue({'WoG'}, [3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('Nothing', fsm_chooseAbilityFromPriorityQueue({'WoG'}, [3, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]));
AssertAreEqual('Nothing', fsm_chooseAbilityFromPriorityQueue({'WoG'}, [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('Nothing', fsm_chooseAbilityFromPriorityQueue({'WoG'}, [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('Nothing', fsm_chooseAbilityFromPriorityQueue({'WoG'}, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('Inq', fsm_chooseAbilityFromPriorityQueue({'Inq'}, [3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('Nothing', fsm_chooseAbilityFromPriorityQueue({'Inq'}, [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('Nothing', fsm_chooseAbilityFromPriorityQueue({'Inq'}, [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
AssertAreEqual('Nothing', fsm_chooseAbilityFromPriorityQueue({'Inq'}, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));

% fsm_calculateNextState
% (state, waitSteps, abilityName, miss = 0, egProc = 0, sdProc = 0, gcProc = 0)
%[HP,AS,CS,Cons,HW,J,WoG,EGICD,GC,GCICD,Inq,SD
AssertAreEqual([1, 3, 0,27, 0, 0, 0, 0, 0, 0, 0, 1], fsm_calculateNextState([1, 6, 0, 30, 1, 2, 3, 0, 0, 0, 2, 4], 0, 'Nothing'));
AssertAreEqual([1, 2, 0,26, 0, 0, 0, 0, 0, 0, 0, 0], fsm_calculateNextState([1, 6, 0, 30, 1, 2, 3, 0, 0, 0, 2, 4], 1, 'Nothing'));
AssertAreEqual([1, 3, 0, 0, 0, 8/0.5-3, 0, 0, 0, 0, 0, 0], fsm_calculateNextState([1, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0, 'J'));
AssertAreEqual([1, 3, 0, 0, 15/0.5-3, 0, 0, 0, 0, 0, 0, 0], fsm_calculateNextState([1, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0, 'HW'));
AssertAreEqual([1, 3, 0, 0, 0, 8/0.5-3, 0, 0, 0, 0, 0, 0], fsm_calculateNextState([1, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0, 'J', 1)); % J miss is same state as hit
AssertAreEqual([1, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0], fsm_calculateNextState([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0, 'CS')); %CS hit
AssertAreEqual([1, 0, 3,26, 0, 0, 0, 0, 0, 0, 0, 0], fsm_calculateNextState([0, 0, 1,30, 0, 0, 0, 0, 0, 0, 0, 0], 1, 'CS')); %CS hit with delay
AssertAreEqual([3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0], fsm_calculateNextState([3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0, 'CS')); %CS at max HP
AssertAreEqual([0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0], fsm_calculateNextState([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0, 'CS', 1)); % CS miss
AssertAreEqual([1, 0, 3, 0, 0, 0, 0, 0,6/0.5-3, 0, 0, 0], fsm_calculateNextState([0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0, 'CS', 0, 0, 0, 1)); % CS GC proc
AssertAreEqual([1, 3, 0, 0, 0, 8/0.5-3, 0, 0, 0, 0, 0, 10/0.5-3], fsm_calculateNextState([1, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0, 'J', 1, 0, 1)); % J SD
AssertAreEqual([1, 3, 0, 0, 0, 8/0.5-3, 0, 0, 0, 0, 0, 10/0.5-3], fsm_calculateNextState([1, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5], 0, 'J', 1, 0, 1)); % J SD refreshes proc duration
AssertAreEqual([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], fsm_calculateNextState([3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0, 'SotR')); % SotR hit
AssertAreEqual([3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], fsm_calculateNextState([3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0, 'SotR', 1)); % SotR miss
AssertAreEqual([0, 0, 0, 0, 0, 0, 20/0.5-3, 0, 0, 0, 0, 0], fsm_calculateNextState([2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0, 'WoG')); % WoG
AssertAreEqual([2, 0, 0, 0, 0, 0, 20/0.5-3, 15/0.5-3, 0, 0, 0, 0], fsm_calculateNextState([2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0, 'WoG', 0, 1)); % WoG EG proc
AssertAreEqual([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8/0.5-3, 0], fsm_calculateNextState([2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0, 'Inq')); % Inq
AssertAreEqual([0, 15/0.5-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], fsm_calculateNextState([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0, 'AS')); % AS hit without GC
AssertAreEqual([1, 15/0.5-3, 0, 0, 0, 0, 0, 0, 0, 3.5/0.5-3, 0, 0], fsm_calculateNextState([0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0], 0, 'AS')); % AS miss without GC
AssertAreEqual([1, 15/0.5-3, 0, 0, 0, 0, 0, 0, 0, 3.5/0.5-3, 0, 0], fsm_calculateNextState([0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0], 0, 'AS')); % AS consume GC
AssertAreEqual([0, 15/0.5-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], fsm_calculateNextState([0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0], 0, 'AS', 1)); % AS consume GC even if missed; ICD not triggered (is this correct?)
AssertAreEqual([0, 15/0.5-3, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], fsm_calculateNextState([0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 0, 0], 0, 'AS')); % AS consume GC; no HP due to ICD

% states are returned in the order miss->no proc->proc
m = testPara.miss;
mdp = testPara.miss + testPara.dodge + testPara.parry;

% 3 * CS transitions for hit, miss and GrCr proc
[next, nextPr] = fsm_calculatePossibleNextStates([0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 'CS', testPara);
AssertAreEqual(3, length(next)); % miss, hit,  proc
AssertAreEqual(1, sum(nextPr));
AssertAreEqual([0, 6, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0], next{1}); % miss
AssertAreEqual([1, 6, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0], next{2}); % hit
AssertAreEqual([1, 0, 3, 0, 0, 0, 0, 0, 9, 0, 0, 0], next{3}); % GrCr
AssertAreEqual(mdp, nextPr(1));
AssertAreEqual((1-mdp)*testPara.gcProcRate, nextPr(3)); % proc chance only on hit

% 2 * CS transitions when at max HP (hit, miss) and GrCr proc
[next, nextPr] = fsm_calculatePossibleNextStates([3, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 'CS', testPara);
AssertAreEqual(2, length(next)); % miss, hit,  proc
AssertAreEqual(1, sum(nextPr));
AssertAreEqual([3, 6, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0], next{1}); % miss/hit
AssertAreEqual([3, 0, 3, 0, 0, 0, 0, 0, 9, 0, 0, 0], next{2}); % GrCr
AssertAreEqual((1-mdp)*testPara.gcProcRate, nextPr(2));

% 2 * J transition for SD proc
[next, nextPr] = fsm_calculatePossibleNextStates([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 'J', testPara);
AssertAreEqual(2, length(next)); % (miss, hit), proc
AssertAreEqual(1, sum(nextPr));
AssertAreEqual([0, 0, 0, 0, 0, 8/0.5-3, 0, 0, 0, 0, 0, 0], next{1}); % miss & hit transition to the same state
AssertAreEqual([0, 0, 0, 0, 0, 8/0.5-3, 0, 0, 0, 0, 0, 10/0.5-3], next{2}); % SD proc
AssertAreEqual((1-m)*testPara.sdProcRate, nextPr(2)); % can't dodge/parry J

% 2 * AS transition when no GrCr
[next, nextPr] = fsm_calculatePossibleNextStates([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 'AS', testPara);
AssertAreEqual(2, length(next)); % (miss, hit), proc
AssertAreEqual(1, sum(nextPr));
AssertAreEqual([0, 15/0.5-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], next{1}); % miss & hit transition to the same state
AssertAreEqual([0, 15/0.5-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10/0.5-3], next{2}); % SD proc
AssertAreEqual((1-m)*testPara.sdProcRate, nextPr(2)); % can't dodge/parry AS

% 3 * AS transition when GrCr is up
[next, nextPr] = fsm_calculatePossibleNextStates([0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0], 'AS', testPara);
AssertAreEqual(3, length(next)); % miss, hit, proc
AssertAreEqual(1, sum(nextPr));
AssertAreEqual([0, 15/0.5-3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], next{1}); % miss
AssertAreEqual([1, 15/0.5-3, 0, 0, 0, 0, 0, 0, 0, 3.5/0.5-3, 0, 0], next{2}); % hit
AssertAreEqual([1, 15/0.5-3, 0, 0, 0, 0, 0, 0, 0, 3.5/0.5-3, 0, 10/0.5-3], next{3}); % SD proc
AssertAreEqual(m, nextPr(1)); % can't dodge/parry AS
AssertAreEqual((1-m)*testPara.sdProcRate, nextPr(3)); % can't dodge/parry AS

% SotR miss transition
[next, nextPr] = fsm_calculatePossibleNextStates([3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 'SotR', testPara);
AssertAreEqual(2, length(next)); % miss, hit
AssertAreEqual(1, sum(nextPr));
AssertAreEqual([3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], next{1}); % miss
AssertAreEqual([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], next{2}); % hit
AssertAreEqual(mdp, nextPr(1));
AssertAreEqual((1-mdp), nextPr(2));

% WoG EG transition
[next, nextPr] = fsm_calculatePossibleNextStates([3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 'WoG', testPara);
AssertAreEqual(2, length(next)); % miss, hit
AssertAreEqual(1, sum(nextPr));
AssertAreEqual([0, 0, 0, 0, 0, 0, 20/0.5-3, 0, 0, 0, 0, 0], next{1});
AssertAreEqual([3, 0, 0, 0, 0, 0, 20/0.5-3, 15/0.5-3, 0, 0, 0, 0], next{2}); % EG proc
AssertAreEqual(1-testPara.egProcRate, nextPr(1));
AssertAreEqual(testPara.egProcRate, nextPr(2));

% No WoG EG transition when EGICD
[next, nextPr] = fsm_calculatePossibleNextStates([3, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], 'WoG', testPara);
AssertAreEqual(1, length(next)); % miss, hit
AssertAreEqual(1, sum(nextPr));

% Single transitions
[next, nextPr] = fsm_calculatePossibleNextStates([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 'Nothing', testPara);
AssertAreEqual(1, length(next));
AssertAreEqual([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], next{1});
AssertAreEqual(1, nextPr(1));
[next, nextPr] = fsm_calculatePossibleNextStates([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 'Cons', testPara);
AssertAreEqual(1, length(next));
AssertAreEqual([0, 0, 0, 30/0.5-3, 0, 0, 0, 0, 0, 0, 0, 0], next{1});
AssertAreEqual(1, nextPr(1));

% simple rotations
testPara.priorityQueue = {'HW'};
[M, stateVector] = fsm_generateStateTransitionMatrix(testPara, zeros(1, fsmInternal.StateVectorSize));
AssertAreEqual((15/0.5)/3, length(stateVector));

testPara.priorityQueue = {'Cons'};
[M, stateVector] = fsm_generateStateTransitionMatrix(testPara, zeros(1, fsmInternal.StateVectorSize));
AssertAreEqual((30/0.5)/3, length(stateVector));

testPara.priorityQueue = {'HW', 'Cons'};
[M, stateVector] = fsm_generateStateTransitionMatrix(testPara, zeros(1, fsmInternal.StateVectorSize));
AssertAreEqual((30/0.5)/3 + 1, length(stateVector)); % +1 since initial state is unreachable from the rotation

testPara.priorityQueue = {'SotR', 'HW', 'Cons'};
[M, stateVector] = fsm_generateStateTransitionMatrix(testPara, zeros(1, fsmInternal.StateVectorSize));
AssertAreEqual((30/0.5)/3 + 1, length(stateVector)); % +1 since initial state is unreachable from the rotation

% fsm tests
% basic test: HW 1 in 10 GCDs
testPara.priorityQueue = {'HW'};
[action, pr] = fsm(testPara);
AssertAreEqual(1, sum(pr));
AssertAreEqual('HW', action{1});
AssertAreEqual('Nothing', action{2});
AssertAreEqual(0.1, pr(1));
AssertAreEqual(0.9, pr(2));

% try slightly more complicated rotation
testPara.miss = 0;
testPara.dodge = 0;
testPara.parry = 0;
testPara.priorityQueue = {'SotR', 'CS'};
[action, pr] = fsm(testPara);
AssertAreEqual(1, sum(pr));
AssertAreEqual('CS', action{1});
AssertAreEqual('Nothing', action{2});
AssertAreEqual('SotR', action{3});
AssertAreEqual(0.5, pr(1));
AssertAreEqual(1/6, pr(3));

% Should never get the HoPo to use SotR
testPara.miss = 1;
testPara.dodge = 0;
testPara.parry = 0;
testPara.priorityQueue = {'SotR', 'CS'};
[action, pr] = fsm(testPara);
AssertAreEqual(1, sum(pr));
AssertAreEqual('CS', action{1});
AssertAreEqual('Nothing', action{2});
AssertAreEqual(0.5, pr(1));
AssertAreEqual(0.5, pr(2));

testPara.miss = 0;
testPara.dodge = 0;
testPara.parry = 0;
testPara.sdProcRate = 0.50;
testPara.priorityQueue = {'SotR', 'CS', 'J'}; % rotation = -J-_-SotR
[action, pr] = fsm(testPara);
AssertAreEqual(1, sum(pr));
AssertAreEqual('CS', action{1});
AssertAreEqual('J', action{2});
AssertAreEqual('Nothing', action{3});
AssertAreEqual('SotR', action{4});
AssertAreEqual('SotR(SD)', action{5});
AssertAreEqual(0.5, pr(1));
AssertAreEqual(1/6, pr(2));
AssertAreEqual(1/6, pr(4) + pr(5));
AssertAreEqual(1/6*0.5, pr(5));
end

function [n,ierr,iind]=fsm_iterative_solve(trans_matrix,varargin)
    %containers for # iter and error
    iind=0;
    ierr=1;
    %input handling
    itol=[];max_iter=[];
    if nargin>1
        for i=1:2:length(varargin)
            name=varargin{i};
            value=varargin{i+1};
            switch name
                case 'tol'
                    itol=value;
                case 'iter'
                    max_iter=value;
            end
        end
    end
    if isempty(itol); itol=1e-3; end
    if isempty(max_iter); max_iter=1e4; end
    
    %start with an equal probability to be in each state
    n=ones(size(trans_matrix,2),1)./size(trans_matrix,2);
    %solve iteravely
    while (ierr>itol && iind<max_iter)
       iind=iind+1;
       dn=-trans_matrix(1:size(trans_matrix,1)-1,:)*n;
       n=n+dn; 
       ierr=max(abs(dn./n)); %relative tolerance
%        ierr=max(abs(dn));    %absolute tolerance
    end
    
end