function condorSubmitCluster(clusterHandle, mode)

% submit a cluster to the HTCondor system
%
% condorSubmitCluster(clusterHandle)
% condorSubmitCluster(clusterHandle, 'debug')
%
% clusterHandle:  handle of cluster to be submitted
%
% If 'debug' is specified as a second argument, jobs are not submitted to
% condor but executed locally and sequentially.
%
% See also condorCreateCluster, condorAddJob, condorMonitorCluster,
% condorGetResults
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


if nargin < 2
    mode = 'submit';
end

% load cluster data structure
clusterDir = [condor_get_config('conDir') clusterHandle filesep];
load([clusterDir 'cluster.mat'], 'cluster')

% already submitted?
if ~isempty(cluster.clusterIds)                                                 %#ok<NODEF>
    error('%s has already been submitted to HTCondor!', ...
        clusterHandle)
    % --> resubmit. warning that debug and resubmit don't go together
end

% are there jobs?
if cluster.numJobs == 0
    error('cluster does not have any jobs!')
end

% generate HTCondor submit description file
sdfName = [cluster.dir 'submit'];
sdf = fopen(sdfName, 'w');
% get general entries from configuration
submit = condor_get_config('submit');
% write general entries
fprintf(sdf, '%s\n', submit{:});
fprintf(sdf, '\n');
% write job-specific entries
for i = 1 : cluster.numJobs
    fprintf(sdf, 'Input  = %s\n', cluster.job(i).in);
    fprintf(sdf, 'Output = %s\n', cluster.job(i).out);
    fprintf(sdf, 'Error  = %s\n', cluster.job(i).err);
    fprintf(sdf, 'Log    = %s\n', cluster.job(i).log);
    fprintf(sdf, 'Queue\n');
    fprintf(sdf, '\n');
end
fclose(sdf);

switch mode
    case 'submit'
        % submit cluster via `condor_submit`
        setenv('LD_LIBRARY_PATH')  % avoid shared library problems for `system`
        [status, result] = system(['condor_submit ' sdfName]);
        if status ~= 0
            error(['could not call `condor_submit`:\n  %s\n' ...
                'condorSubmitCluster has to be run on an HTCondor machine!\n'], result)
        end
        clusterId = str2double(result(find(result == ' ', 1, 'last') + 1 : end - 2));
        fprintf('submitted %s to HTCondor as %d\n', ...
            clusterHandle, clusterId)
        % add ClusterId and ProcId to cluster data structure and save
        cluster.clusterIds = [cluster.clusterIds clusterId];
        for i = 1 : cluster.numJobs
            cluster.job(i).clusterId = clusterId;
            cluster.job(i).procId = i - 1;  % analogous to HTCondor
        end
        save([clusterDir 'cluster.mat'], 'cluster')
    case 'debug'
        % executing jobs locally and sequentially
        fprintf('condorSubmitCluster DEBUG MODE\n\n')
        setenv('_CONDOR_SLOT', 'debug')     % needed by input script
        for i = 1 : cluster.numJobs
            runContained(cluster.job(i).in) % execute input script
        end
        setenv('_CONDOR_SLOT')
    otherwise
        error('unknown mode "%s"!', mode)
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
