function condorCreateTask(jobHandle, fun, argIn, numArgOut)

% define a task and add it to an HTCondor job
%
% condorCreateTask(jobHandle, fun, argIn, numArgOut = 0)
%
% jobHandle:    handle of job the task should be added to
% fun:          handle of function that should be run
% argIn:        cell array of parameters to pass to fun
% numArgOut:    number of outputs of fun that should be saved
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


jobDir = [condorConfig('condir') jobHandle filesep];
load([jobDir 'job'], 'job')

if nargin < 4
    numArgOut = 0;
end

% generate task data structure
task = struct;
task.id = job.numTasks;                                                     %#ok<NODEF>
task.name = sprintf('%stask%03d', job.dir, task.id);
task.in = [task.name '_in.m'];  % Matlab input script
task.out = [task.name '_out'];  % filename for Matlab std out
task.err = [task.name '_err'];  % filename for Matlab std err
task.inf = [task.name '_inf'];  % Matlab task information
task.res = [task.name '_res'];  % filename for Matlab results
task.log = [task.name '_log'];  % filename for HTCondor log file

% create task information for Matlab process
condorTask = struct;
condorTask.id = job.numTasks;
condorTask.fun = fun;
condorTask.argIn = argIn;
condorTask.numArgOut = numArgOut;
condorTask.path = path;
condorTask.wd = pwd;
save(task.inf, 'condorTask');

% create input script for Matlab process
fid = fopen(task.in, 'w');
fprintf(fid, 'fseek(2, 0, ''bof'')\n');
fprintf(fid, 'slot = getenv(''_CONDOR_SLOT'');\n');
fprintf(fid, 'setenv(''LD_LIBRARY_PATH'')\n');
fprintf(fid, '[~, hostname] = system(''condor_config_val -raw HOSTNAME'');\n');
fprintf(fid, 'fprintf([''HTCondor job executing on '' slot ''@'' hostname])\n');
fprintf(fid, 'clear\n');
fprintf(fid, 'load(''%s'')\n', task.inf);
fprintf(fid, 'path(condorTask.path)\n');
fprintf(fid, 'cd(condorTask.wd)\n');
fprintf(fid, 'condorResult = cell(1, condorTask.numArgOut);\n');
fprintf(fid, '[condorResult{:}] = condorTask.fun(condorTask.argIn{:});\n');
fprintf(fid, 'save(''%s'', ''condorResult'')\n', task.res);
fclose(fid);

% add task to job data structure
job.numTasks = job.numTasks + 1;
job.task(job.numTasks) = task;

% save updated job data structure
save([jobDir 'job'], 'job')


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
