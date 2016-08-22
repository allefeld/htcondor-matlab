function results = condorGetResults(clusterHandle)

% retrieve results of a finished HTCondor cluster
%
% results = condorGetResults(clusterHandle)
%
% clusterHandle:  handle of cluster
% results:        cell array of tasks' return values
%
% `results` is a cell array with one element per task. If a task is not yet
% finished, the corresponding element of `results` is an empty array. If a
% task finished successfully, the corresponding element is a cell array
% containing the return value(s) of that task. If a task exited with an
% error, the corresponding element is a cell array that contains an empty
% array.
%
% See also condorCreateCluster, condorCreateTask, condorSubmitCluster,
% condorMonitorCluster
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


% load cluster data structure
clusterDir = [condorGetConfig('conDir') clusterHandle filesep];
load([clusterDir 'cluster.mat'], 'cluster')

% initialize cell array of results
results = cell(cluster.numTasks, 1);
% for each task
for i = 1 : cluster.numTasks
    % if results are ready
    if exist(cluster.task(i).res, 'file')
        % load them and save them in task's cell
        load(cluster.task(i).res, 'condorResult')
        results{i} = condorResult;
    else
        fprintf('no results for task%03d / HTCondor JobId %d.%d\n', ...
            clusterHandle, cluster.id, cluster.task(i).id)
    end
end


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
