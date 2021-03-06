function clusterHandle = condorCreateCluster(description)

% create data structure and subdirectory to represent an HTCondor cluster
%
% clusterHandle = condorCreateCluster(description)
%
% description:    string describing cluster
% clusterHandle:  handle of created cluster (string)
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


% generate description
if nargin == 0
    [ST, I] = dbstack;
    if numel(ST) >= I + 1
        description = ST(I + 1).name;
    else
        description = '';
    end
end
description = strtrim([description ' ' datestr(now, '(yyyy-mm-dd HH:MM:SS)')]);

% get htcondor-matlab cluster directory from configuration
conDir = condor_get_config('conDir');

% find last existing cluster index (subdirectory of htcondor-matlab cluster directory)
listing = dir([conDir 'cluster*']);
listing = listing([listing.isdir]);
number = cellfun(@(x)(str2double(x(numel('cluster') + 1 : end))), ...
    {listing(:).name}, 'UniformOutput', false);
number = max([number{:}]);
if isempty(number), number = 0; end

% generate new cluster handle
clusterHandle = sprintf('cluster%ld', number + 1);      % do we need "l"??
clusterDir = [conDir clusterHandle filesep];

% initialize cluster data structure
cluster = struct;
cluster.description = description;
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
if now - min([listing(:).datenum]) > condor_get_config('oldTime')
    fprintf(2, '\nconsider removing old cluster subdirectories\n');
    fprintf(2, 'for an overview, call `condorClusters`\n');
end


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
