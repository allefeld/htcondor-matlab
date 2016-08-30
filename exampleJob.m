function j = exampleJob(i)

% example job function
%
% y = exampleJob(x)
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld

% print primary message
fprintf('exampleJob\n')

% print secondary message
fprintf(' processing %d\n', i)

% simulate error
if isprime(i)
    % print secondary message
    fprintf(' %g is a prime, throwing error\n', i)
    % generate error
    error('argument is a prime number!')
end

% compute result
j = i ^ 2;
pause(10)   % act as if it's taking a while

% print secondary message
fprintf(' returning %d\n', j)


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
