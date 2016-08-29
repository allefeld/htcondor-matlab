function clusterHandle = condorCreateCluster

% create data structure and subdirectory to represent an HTCondor cluster
%
% clusterHandle = condorCreateCluster
%
% clusterHandle:  handle of created cluster (string)
%
% See also condorAddJob, condorSubmitCluster, condorMonitorCluster,
% condorGetResults
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


% get htcondor-matlab cluster directory from configuration
conDir = condor_get_config('conDir');

% find last existing cluster index (subdirectory of htcondor-matlab cluster directory)
listing = dir([conDir 'cluster*']);
listing = listing([listing.isdir]);
ind = cellfun(@(x)(str2double(x(numel('cluster') + 1 : end))), {listing.name}, ...
    'UniformOutput', false);
ind = max([ind{:}]);
if isempty(ind), ind = 0; end

% generate new cluster handle
clusterHandle = sprintf('cluster%ld', ind + 1);       % do we need "l"??
clusterDir = [conDir clusterHandle filesep];

% initialize cluster data structure
cluster = struct;
cluster.dir = clusterDir;
cluster.numJobs = 0;
cluster.clusterIds = [];                                                        %#ok<STRNU>

% create new cluster subdirectory
[s, m] = mkdir(clusterDir);
if s == 0
    error(m)
end

% save cluster data structure to cluster subdirectory
save([clusterDir 'cluster.mat'], 'cluster')
fprintf('created %s\n', clusterHandle)

% check whether there are old cluster subdirectories
if now - min([listing.datenum]) > 30
    fprintf(2, 'consider deleting old cluster subdirectories in\n  %s\n', conDir);
end


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
