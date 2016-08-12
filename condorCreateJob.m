function jobHandle = condorCreateJob

% jobHandle = condorCreateJob

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
