function condorClusters(mode)

% list all existing clusters and their job properties
%
% condorClusters
% condorClusters('clean')
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


% determine mode
if nargin == 0
    mode = '';
end

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

% get symbols for job status and exit status
[statusSymbols, exitSymbols] = condor_job_status;

% are there any clusters?
nClusters = numel(listing);
if nClusters == 0
    fprintf('there are no clusters\n')
    return
end

% iterate through clusters
fprintf('cluster  ')
fprintf('%4c', statusSymbols)
fprintf('   ?')
fprintf('%4c', exitSymbols)
fprintf('   description\n')
deletable = false(nClusters, 1);
for i = 1 : nClusters
    fprintf('%7d  ', number(i))
    try
        % load cluster data structure
        clusterHandle = listing(i).name;
        cluster = condor_get_cluster(clusterHandle);
        % get job's status
        [jobStatus, exitCode, exitSignal] = condor_job_status(clusterHandle);
        % statistics
        nStatus = hist(jobStatus, 1 : numel(statusSymbols) + 1);
        nUndefinedStatus = sum(isnan(jobStatus));   % never submitted
        nExitSuccess = sum(exitCode == 0);          % terminated normally & successfully
        nExitError = sum(exitCode > 0);             % terminated normally but with error
        nExitSignal = sum(~isnan(exitSignal));      % terminated abnormally
        % output
        fprintf('%4d', nStatus)
        fprintf('%4d', nUndefinedStatus)
        fprintf('%4d', nExitSuccess, nExitError, nExitSignal)
        fprintf('   %s\n', cluster.description)
        % deletable: if all jobs are either never submitted, removed, completed,
        % or held (because these are periodically removed)
        deletable(i) = all(isnan(jobStatus) | ismember(jobStatus, [3, 4, 5]));
    catch
        fprintf('– data corrupted –\n')
        % deletable: corrupted clusters always
        deletable(i) = true;
    end
end
fprintf('\n')

% cleaning
old = (now - [listing(:).datenum]' > condor_get_config('oldTime'));
todelete = (old & deletable);
if strcmp(mode, 'clean')
    fprintf('of %d old cluster subdirectories, %d can be deleted\n\n', ...
        sum(old), sum(todelete))
    if sum(todelete) > 0
        fprintf('deleting cluster subdirectories in\n  %s\n', conDir)
        for i = find(todelete)'
            [status, message] = rmdir([conDir listing(i).name], 's');
            if status == 1
                fprintf('%s\n', listing(i).name)
            else
                fprintf(2, '%s: %s\n', listing(i).name, message);
            end
        end
    end
else
    if sum(todelete) > 0
        fprintf('of %d old cluster subdirectories, %d can be deleted:\n', ...
            sum(old), sum(todelete))
        fprintf(' %d', number(todelete))
        fprintf('\n')
        fprintf(2, 'consider calling `condorClusters clean`\n');
    end
end


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
