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
function AssertAreEqual (expected, actual, customErrorMessage)
    %handle optional input args
    if nargin<3
        customErrorMessage= '';
    end
    %sanitize inputs - actual always seems to be uint16 class, while
    %expected tends to be double
    if ~strcmp(class(expected),class(actual))
        expected=uint16(expected);
        actual=uint16(actual);
    end
    
	if isfloat(expected)
		if expected - actual ~= 0
			% check if they're close enough
			if abs((expected - actual)/min([expected, actual])) > 1e-10 % floating point tolerance
				raiseError(expected, actual, customErrorMessage);
			end
		end
		return
	end
	if length(expected) ~= length(actual)
		raiseError(expected, actual, customErrorMessage);
    elseif not(all(expected == actual))
		raiseError(expected, actual, customErrorMessage);
	end
end
function raiseError (expected, actual, customErrorMessage)
	if strcmp(customErrorMessage, '')
		expected
		actual
		error('expected and actual are not equal');
	else
		error(customErrorMessage);
	end
end