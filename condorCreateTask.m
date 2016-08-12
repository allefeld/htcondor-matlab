function condorCreateTask(jobHandle, fun, argIn, numArgOut)

% define a Condor task and add it to a Condor job
%
% condorCreateTask(jobHandle, fun, argIn, numArgOut = 0)
%
% jobHandle:    handle of job the task should be included in
% fun:          handle of function that should be run
% argIn:        cell array of parameters to pass to fun
% numArgOut:    number of outputs of fun that should be saved
%
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


jobDir = [condorStorage jobHandle '/'];
load([jobDir 'job'], 'job')

if nargin < 4
    numArgOut = 0;
end

task = struct;
task.id = job.numTasks;
task.name = sprintf('%stask%03d', job.dir, task.id);
task.in = [task.name '_in.m'];
task.out = [task.name '_out'];
task.err = [task.name '_err'];
task.env = [task.name '_env'];
task.res = [task.name '_res'];
task.log = [task.name '_log'];

% save data for task
condorTask = struct;
condorTask.id = job.numTasks;
condorTask.fun = fun;
condorTask.argIn = argIn;
condorTask.numArgOut = numArgOut;
condorTask.path = path;
condorTask.wd = pwd;
save(task.env, 'condorTask');

% generate input script for task
fid = fopen(task.in, 'w');
fprintf(fid, 'system(''uname -snr'');');
fprintf(fid, 'clear\n');
fprintf(fid, 'load(''%s'')\n', task.env);
fprintf(fid, 'path(condorTask.path)\n');
fprintf(fid, 'cd(condorTask.wd)\n');
fprintf(fid, 'condorResult = cell(1, condorTask.numArgOut);\n');
fprintf(fid, '[condorResult{:}] = condorTask.fun(condorTask.argIn{:});\n');
fprintf(fid, 'save(''%s'', ''condorResult'')\n', task.res);
fclose(fid);

job.numTasks = job.numTasks + 1;
job.task(job.numTasks) = task;

save([jobDir 'job'], 'job')
