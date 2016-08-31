function j = exampleJob(i)

% example job function
%
% y = exampleJob(x)
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


fprintf('exampleJob\n')                         % print primary message

fprintf(' processing %d\n', i)                  % print secondary message
pause(5)    % act as if it's taking a while
j = i ^ 2;
rng('shuffle')
if rand < 0.5
    error('exampleJob: an error occurred!')                 % generate error
end
pause(5)    % act as if it's taking a while
fprintf(' returning %d\n', j)                   % print secondary message


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
