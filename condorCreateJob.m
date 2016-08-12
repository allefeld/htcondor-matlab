function jobHandle = condorCreateJob

% create data structure to represent a Condor job
%
% jobHandle = condorCreateJob
%
% jobHandle:    handle of job (string)
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab

% Copyright (C) 2016 Carsten Allefeld
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.


condir = condorStorage;

j = dir([condir 'job*']);
j = j([j.isdir]);
j = cellfun(@(x)(str2double(x(4 : end))), {j.name}, 'UniformOutput', false);
j = max([j{:}]);
if isempty(j), j = 0; end

jobHandle = sprintf('job%ld', j + 1);
jobDir = [condir jobHandle '/'];

job = struct;
job.handle = jobHandle;
job.dir = jobDir;
job.numTasks = 0;

[s, m] = mkdir(job.dir);
if s == 0
    error(m)
end

save([jobDir 'job'], 'job')
