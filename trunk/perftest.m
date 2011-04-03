%    struct as hashmap performance test
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
function perftest ()
benchmark(1).hardware = 'i5-2500K @ 4.7Ghz 8Gb';
benchmark(1).version = 'Octave-3.2.4';
benchmark(1).results = [10, 8, 12, 120, -1];
benchmark(2).hardware = 'Core 2 Duo T5750 @ 2.0Ghz 3Gb';
benchmark(2).version = 'Matlab 2008a';
benchmark(2).results = [25, 0, 5, 57, -1];
benchmark(3).hardware = 'i7-2600K @ 4.0Ghz 16Gb';
benchmark(3).version = 'Matlab 2008a';
benchmark(3).results = [9, 0, 2, 17, -1];
showBenchmark = 1;
disp('Running performance tests for proxying a struct as a hashmap.');
sprintf('Struct hashmap performance testing')
disp(sprintf('Benchmarked on %s %s in %0.0f s', benchmark(showBenchmark).version, benchmark(showBenchmark).hardware, benchmark(showBenchmark).results(1)));
tic();
for j = [1000, 10000, 100000]
    %printf('Inserting %d\n', j)
    test_struct = [];
    for i = 1:j
        test_struct.(sprintf('S%lu', i)) = i;
    end
    %printf('Lookup %d\n', j);
    for i = 1:j
        value = test_struct.(sprintf('S%lu', i));
        AssertAreEqual(i, value);
    end
    %printf('Lookup misses %d\n', j);
    for i = 1:j
        try
            value = test_struct.(sprintf('S%lu', i));
        catch
            value = 0;
        end
    end
end
toc()

% isfield() cannot be used due to terrible performance in Octave
isFieldLookups = 10;
sprintf('Performing %d isfield() hit/misses on %d element struct', isFieldLookups, length(fieldnames(test_struct)))
disp(sprintf('Benchmarked on %s %s in %0.0f s', benchmark(showBenchmark).version, benchmark(showBenchmark).hardware, benchmark(showBenchmark).results(2)));
tic();
for i = 1:isFieldLookups
    AssertAreEqual(1, isfield(test_struct, sprintf('S%lu', i)));
end
for i = 1:isFieldLookups
    AssertAreEqual(0, isfield(test_struct, 's123123123123123'));
end
toc()


sprintf('Evaulating SotR-CS-J-AS-HW')
warning('Benchmarked on %s %s in %0.0f s', benchmark(showBenchmark).version, benchmark(showBenchmark).hardware, benchmark(showBenchmark).results(3));
graphParameters = struct('spmiss', 0.08, 'miss', 0.08, 'dodge', 0.065, 'parry', 0.14, 'egProcRate', 0.3, 'sdProcRate', 0.5, 'gcProcRate', 0.2);
graphParameters.priorityQueue = {'SotR', 'CS', 'J', 'AS', 'HW'};
tic();
[action, pr] = fsm(graphParameters);
toc()


sprintf('Evaulating SotR-CS-J-AS-Cons')
warning('Benchmarked on %s %s in %0.0f s', benchmark(showBenchmark).version, benchmark(showBenchmark).hardware, benchmark(showBenchmark).results(4));
graphParameters = struct('spmiss', 0.08, 'miss', 0.08, 'dodge', 0.065, 'parry', 0.14, 'egProcRate', 0.3, 'sdProcRate', 0.5, 'gcProcRate', 0.2);
graphParameters.priorityQueue = {'SotR', 'CS', 'J', 'AS', 'Cons'};
tic();
[action, pr] = fsm(graphParameters);
toc()


sprintf('Evaulating SotR-CS-J-AS-Cons-HW')
warning('Benchmarked on %s %s in %0.0f s', benchmark(showBenchmark).version, benchmark(showBenchmark).hardware, benchmark(showBenchmark).results(5));
graphParameters = struct('spmiss', 0.08, 'miss', 0.08, 'dodge', 0.065, 'parry', 0.14, 'egProcRate', 0.3, 'sdProcRate', 0.5, 'gcProcRate', 0.2);
graphParameters.priorityQueue = {'SotR', 'CS', 'J', 'AS', 'Cons', 'HW'};
tic();
[action, pr] = fsm(graphParameters);
toc()
