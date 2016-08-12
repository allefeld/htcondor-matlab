function condorCreateTask(jobHandle, fun, argIn, numArgOut)

% condorCreateTask(jobHandle, fun, argIn, numArgOut = 0)

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
