function condorSubmitCluster(clusterHandle, mode)

% submit a cluster to the HTCondor system
%
% condorSubmitCluster(clusterHandle)
% condorSubmitCluster(clusterHandle, 'debug')
%
% clusterHandle:  handle of cluster to be submitted
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


% determine mode
if nargin < 2
    mode = 'submit';
end
if strcmp(mode, 'debug')
    fprintf('   *** DEBUG MODE ***\n\n')
end

% load cluster data structure
cluster = condor_get_cluster(clusterHandle);

% which jobs to submit?
if isempty(cluster.clusterIds)
    % first submission
    tosubmit = 1 : cluster.numJobs;
else
    % submitted before -> prepare resubmission
    fprintf('%s has already been submitted to HTCondor\n', clusterHandle)
    [jobStatus, exitCode, exitSignal] = condor_job_status(clusterHandle);
    tosubmit = ...
        ((jobStatus == 4) & (exitCode > 0)) ... % terminated normally with error
        | ~isnan(exitSignal);                   % terminated abnormally
    tosubmit = find(tosubmit(:))';
    if isempty(tosubmit)
        fprintf('  no jobs that can be resubmitted\n')
        return
    end
    fprintf('  jobs that can be resubmitted:')
    fprintf(' %03d', tosubmit - 1)
    fprintf('\n')
    if ~strcmp(input('resubmit? y/n  ', 's'), 'y')
        return
    end
end

% are there any jobs?
if isempty(tosubmit)
    fprintf(2, 'no jobs to submit!\n');
    return
end

% generate HTCondor submit description file
sdfName = [cluster.dir 'submit'];
sdf = fopen(sdfName, 'w');
% write general entries from configuration
submit = condor_get_config('submit');
fprintf(sdf, '%s\n', submit{:});
% write job-specific entries
for jn = tosubmit
    fprintf(sdf, '\n');
    fprintf(sdf, 'Input  = %s\n', cluster.job(jn).in);
    fprintf(sdf, 'Output = %s\n', cluster.job(jn).out);
    fprintf(sdf, 'Error  = %s\n', cluster.job(jn).err);
    fprintf(sdf, 'Log    = %s\n', cluster.job(jn).log);
    fprintf(sdf, 'Queue\n');
end
fclose(sdf);

switch mode
    case 'submit'
        % delete old log files, because HTCondor appends,
        % confusing `condor_q -userlog`
        for jn = tosubmit
            if exist(cluster.job(jn).log, 'file')
                delete(cluster.job(jn).log)
            end
        end
        % submit cluster via `condor_submit`
        %         setenv('LD_LIBRARY_PATH')  % avoid shared library problems for `system`
        [status, result] = system(['condor_submit ' sdfName]);
        if status ~= 0
            fprintf(2, 'condorSubmitCluster has to be run on an HTCondor machine!\n');
            error('error calling `condor_submit`:\n  %s\n', result)
        end
        clusterId = str2double(result(find(result == ' ', 1, 'last') + 1 : end - 2));
        fprintf('submitted %s to HTCondor as %d\n', ...
            clusterHandle, clusterId)
        % add ClusterId and ProcId to cluster data structure and save
        cluster.clusterIds = [cluster.clusterIds clusterId];
        for i = 1 : numel(tosubmit)
            cluster.job(tosubmit(i)).clusterId = clusterId;
            cluster.job(tosubmit(i)).procId = i - 1;   % infer HTCondor's assignment
        end
        save([condor_get_config('conDir') clusterHandle filesep ...
            'cluster.mat'], 'cluster')
    case 'debug'
        % executing jobs locally and sequentially
        setenv('_CONDOR_SLOT', 'debug')     % needed by input script
        for jn = tosubmit
            runContained(cluster.job(jn).in) % execute input script
        end
        setenv('_CONDOR_SLOT')
    otherwise
        fprintf(2, 'unknown mode "%s"!\n', mode);
end


function runContained(scriptname)
% wrapper around `run`, to contain script execution in separate workspace
% and catch errors (for debug mode)
try
    run(scriptname)
catch ME
    fprintf('*** job aborted with error:\n')
    fprintf(2, '%s\n', getReport(ME));
end


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
