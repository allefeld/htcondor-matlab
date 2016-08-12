function results = condorGetResults(jobHandle)

% results = condorGetResults(jobHandle)

jobDir = [condorStorage jobHandle '/'];
load([jobDir 'job'], 'job')

results = cell(job.numTasks, 1);

for i = 1 : job.numTasks
    if exist([job.task(i).res '.mat'], 'file')
        load(job.task(i).res, 'condorResult')
        results{i} = condorResult;
    else
        fprintf('no results for %s/task%03d\n', jobHandle, job.task(i).id)
    end
end

