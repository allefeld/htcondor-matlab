function results = condorGetResults(clusterHandle)

% retrieve results of an HTCondor cluster
%
% results = condorGetResults(clusterHandle)
%
% clusterHandle:  handle of cluster
% results:        cell array of jobs' return values
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


% load cluster data structure
cluster = condor_get_cluster(clusterHandle);

% already submitted?
if isempty(cluster.clusterIds)
    error('%s has not yet been submitted to HTCondor!', ...
        clusterHandle)
end

% initialize cell array of results
results = cell(cluster.numJobs, 1);
% for each job
for i = 1 : cluster.numJobs
    % if results are ready
    if exist(cluster.job(i).res, 'file')
        % load them and save them in job's cell
        load(cluster.job(i).res, 'condorResult')
        results{i} = condorResult;
    else
        fprintf(2, 'no results for "job%03d" / HTCondor job %d.%d\n', ...
            i - 1, cluster.job(i).clusterId, cluster.job(i).procId);
    end
end


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
