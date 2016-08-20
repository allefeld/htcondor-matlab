function jobHandle = condorCreateJob

% create data structure and subdirectory to represent an HTCondor job
%
% jobHandle = condorCreateJob
%
% jobHandle:    handle of job (string)
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


% get htcondor-matlab job directory from configuration
conDir = condorConfig('condir');

% find last existing job index (subdirectory of htcondor-matlab job directory)
j = dir([conDir 'job*']);
j = j([j.isdir]);
j = cellfun(@(x)(str2double(x(4 : end))), {j.name}, 'UniformOutput', false);
j = max([j{:}]);
if isempty(j), j = 0; end

% generate new job handle
jobHandle = sprintf('job%ld', j + 1);
jobDir = [conDir jobHandle filesep];

% initialize job data structure
job = struct;
job.handle = jobHandle;
job.dir = jobDir;
job.numTasks = 0;                                                           %#ok<STRNU>

% create new job subdirectory
[s, m] = mkdir(jobDir);
if s == 0
    error(m)
end

% save job data structure to job subdirectory
save([jobDir 'job'], 'job')


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
