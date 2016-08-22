function condorSubmitCluster(clusterHandle)

% submit a cluster to the HTCondor system
%
% condorSubmitCluster(clusterHandle)
%
% clusterHandle:  handle of cluster to be submitted
%
% See also condorCreateCluster, condorCreateTask, condorMonitorCluster,
% condorGetResults
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


% load cluster data structure
clusterDir = [condorGetConfig('conDir') clusterHandle filesep];
load([clusterDir 'cluster.mat'], 'cluster')

% generate HTCondor submit description file
sdfName = [cluster.dir 'submit'];                                                   %#ok<NODEF>
sdf = fopen(sdfName, 'w');
% get general entries from configuration
submit = condorGetConfig('submit');
% write general entries
fprintf(sdf, '%s\n', submit{:});
fprintf(sdf, '\n');
% write task-specific entries
for i = 1 : cluster.numTasks
    fprintf(sdf, 'Input  = %s\n', cluster.task(i).in);
    fprintf(sdf, 'Output = %s\n', cluster.task(i).out);
    fprintf(sdf, 'Error  = %s\n', cluster.task(i).err);
    fprintf(sdf, 'Log    = %s\n', cluster.task(i).log);
    fprintf(sdf, 'Queue\n');
    fprintf(sdf, '\n');
end
fclose(sdf);

% submit cluster via `condor_submit`
setenv('LD_LIBRARY_PATH')  % avoid shared library problems for `system`
[status, result] = system(['condor_submit ' sdfName]);
if status ~= 0
    error(result)
end
clusterId = str2double(result(find(result == ' ', 1, 'last') + 1 : end - 2));
fprintf('submitted cluster with handle "%s" has HTCondor ClusterId %d\n', ...
    clusterHandle, clusterId)

% add ClusterId to cluster data structure and save
cluster.id = clusterId;
save([clusterDir 'cluster.mat'], 'cluster')


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
