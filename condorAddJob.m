function condorCreateTask(clusterHandle, taskFun, argIn, numArgOut)

% define a task and add it to an HTCondor cluster
%
% condorCreateTask(clusterHandle, taskFun, argIn, numArgOut = 0)
%
% clusterHandle:  handle of cluster the task should be added to
% taskFun:        function handle of the task function
% argIn:          cell array of parameters to pass to taskFun
% numArgOut:      number of outputs of taskFun that should be saved
%
% See also condorCreateCluster, condorSubmitCluster, condorMonitorCluster,
% condorGetResults 
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


if nargin < 4
    numArgOut = 0;
end

% load cluster data structure
clusterDir = [condorGetConfig('conDir') clusterHandle filesep];
load([clusterDir 'cluster.mat'], 'cluster')

% generate task data structure
task = struct;
task.id = cluster.numTasks;                                                     %#ok<NODEF>
task.name = sprintf('%stask%03d', cluster.dir, task.id);
task.in = [task.name '_in.m'];      % Matlab input script
task.out = [task.name '_out'];      % filename for Matlab standard output
task.err = [task.name '_err'];      % filename for Matlab standard error
task.inf = [task.name '_inf.mat'];  % Matlab task information
task.res = [task.name '_res.mat'];  % filename for Matlab results
task.log = [task.name '_log'];      % filename for HTCondor log file

% create task information; used in input script
condorTask = struct;
condorTask.id = cluster.numTasks;
condorTask.fun = taskFun;
condorTask.argIn = argIn;
condorTask.numArgOut = numArgOut;
condorTask.path = path;
condorTask.wd = pwd;
save(task.inf, 'condorTask');

% create input script for Matlab process
fid = fopen(task.in, 'w');
%  -> print marker for condorMonitorCluster to stderr
fprintf(fid, 'fprintf(2, ''\\ninput script started\\n'');\n');
%  -> report HTCondor slot and machine, uses `condor_config_val`
fprintf(fid, 'slot = getenv(''_CONDOR_SLOT'');\n');
fprintf(fid, 'setenv(''LD_LIBRARY_PATH'')\n');
fprintf(fid, '[~, hostname] = system(''condor_config_val -raw HOSTNAME'');\n');
fprintf(fid, 'fprintf([''HTCondor task executing on '' slot ''@'' hostname])\n');
%  -> prepare to run task
fprintf(fid, 'clear\n');
fprintf(fid, 'load(''%s'')\n', task.inf);
fprintf(fid, 'path(condorTask.path)\n');
fprintf(fid, 'cd(condorTask.wd)\n');
%  -> run task and capture results
fprintf(fid, 'condorResult = cell(1, condorTask.numArgOut);\n');
fprintf(fid, '[condorResult{:}] = condorTask.fun(condorTask.argIn{:});\n');
%  -> save results
fprintf(fid, 'save(''%s'', ''condorResult'')\n', task.res);
fclose(fid);

% add task to cluster data structure and save
cluster.numTasks = cluster.numTasks + 1;
cluster.task(cluster.numTasks) = task;
save([clusterDir 'cluster.mat'], 'cluster')


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
