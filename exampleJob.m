function y = exampleJob(x)

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
fprintf(' processing\n')

% simulate error
if isprime(x)
    % print secondary message
    fprintf(' %g is a prime, throwing error\n', x)
    % generate error
    error('argument is a prime number!')
end

% compute result
y = x ^ 2;
pause(10)   % act as if it's taking a while

% print secondary message
fprintf(' finished\n')


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
