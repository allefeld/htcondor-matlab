function condorSubmitJob(jobHandle)

% condorSubmitJob(jobHandle)

jobDir = [condorStorage jobHandle '/'];
load([jobDir 'job'], 'job')

% generate submit description file
sdfName = [job.dir 'submit'];                                                   %#ok<NODEF>
sdf = fopen(sdfName, 'w');

fprintf(sdf, 'Universe            = vanilla\n');
fprintf(sdf, 'Executable          = %s/bin/matlab\n', matlabroot);
fprintf(sdf, 'Arguments           = -nodisplay -nojvm\n');
fprintf(sdf, 'Transfer_Executable = false\n');
fprintf(sdf, 'Notification        = never\n');
fprintf(sdf, 'Kill_Sig            = 2\n');

fprintf(sdf, 'Requirements        = (SlotID <= 4)\n');  % HACK to run at most two tasks on one machine
fprintf(sdf, 'Rank                = Mips\n');

fprintf(sdf, '\n');

for i = 1 : job.numTasks
    fprintf(sdf, 'Input               = %s\n', job.task(i).in);
    fprintf(sdf, 'Output              = %s\n', job.task(i).out);
    fprintf(sdf, 'Error               = %s\n', job.task(i).err);
    fprintf(sdf, 'Log                 = %s\n', job.task(i).log);
    fprintf(sdf, 'Queue\n');
    fprintf(sdf, '\n');
    
end

fclose(sdf);

% submit job
setenv('LD_LIBRARY_PATH')       % why?
[status, result] = system(['condor_submit ' sdfName]);

if status ~= 0
    error(result)
end
job.cluster = str2double(result(find(result == ' ', 1, 'last') + 1 : end - 2));
fprintf('submitted %s to cluster %d\n', jobHandle, job.cluster)

save([jobDir 'job'], 'job')

% request_disk
% request_memory