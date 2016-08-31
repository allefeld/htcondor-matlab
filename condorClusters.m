function condorClusters

% list all existing clusters and their job properties
%
% condorClusters
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


% get htcondor-matlab cluster directory from configuration
conDir = condor_get_config('conDir');

% find all cluster subdirectories of htcondor-matlab cluster directory
listing = dir([conDir 'cluster*']);
listing = listing([listing.isdir]);
% sort by number
number = cellfun(@(x)(str2double(x(numel('cluster') + 1 : end))), ...
    {listing(:).name}, 'UniformOutput', false);
[number, ind] = sort([number{:}]);
listing = listing(ind);

% get symbols for job status and exit
[statusSymbols, exitSymbols] = condor_job_status;

% iterate through clusters
fprintf('cluster  ')
fprintf('%4c', statusSymbols)
fprintf('%4c', exitSymbols)
fprintf('   description\n')
for i = 1 : numel(listing)
    fprintf('%7d  ', number(i))
    try
        % load cluster data structure
        clusterHandle = listing(i).name;
        clusterDir = [condor_get_config('conDir') clusterHandle filesep];
        load([clusterDir 'cluster.mat'], 'cluster')
        % get job's status
        [jobStatus, exitCode, exitSignal] = condor_job_status(clusterHandle);
        % statistics
        nStatus = hist(jobStatus, 1 : numel(statusSymbols));
        nExitSuccess = sum(exitCode == 0);
        nExitError = sum(exitCode > 0);
        nExitSignal = sum(~isnan(exitSignal));
        % output
        fprintf('%4d', nStatus)
        fprintf('%4d', nExitSuccess, nExitError, nExitSignal)
        fprintf('   %s\n', cluster.description)
    catch
        fprintf('– data corrupted –\n')
    end
end

% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
