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

graphParameters = struct('spmiss', 0.08, 'miss', 0.08, 'dodge', 0.065, 'parry', 0.14, 'egProcRate', 0.3, 'sdProcRate', 0.5, 'gcProcRate', 0.2);
graphParameters.priorityQueue = {"SotR", "CS", "J", "AS", "Cons"};
tic();
[action, pr] = fsm(graphParameters)
toc()
