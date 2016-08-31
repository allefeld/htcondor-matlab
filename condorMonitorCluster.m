function condorMonitorCluster(clusterHandle)

% monitor job progress of an HTCondor cluster
%
% condorMonitorCluster(clusterHandle)
%
% clusterHandle:  handle of cluster to be monitored
%
% See also condorCreateCluster, condorAddJob, condorSubmitCluster,
% condorGetResults
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


% load cluster data structure
clusterDir = [condor_get_config('conDir') clusterHandle filesep];
load([clusterDir 'cluster.mat'], 'cluster')

% initialize file identifiers
outFID = -1 * ones(cluster.numJobs, 1);     % Matlab standard output
errFID = -1 * ones(cluster.numJobs, 1);     % Matlab standard error
logFID = -1 * ones(cluster.numJobs, 1);     % HTCondor log
% because we never get around to closing these files properly
cleanupObj = onCleanup(@() fclose('all'));

% prepare job number
jobNumber = strsplit(sprintf('job%03d\n', 0 : cluster.numJobs - 1));
jobNumber = jobNumber(1 : end - 1)';
% initialize error indicator
errInd = repmat(' ', cluster.numJobs, 1);
% initialize current primary and secondary message
priMsg = cell(cluster.numJobs, 1);
priMsg(:) = {'–'};
secMsg = cell(cluster.numJobs, 1);
secMsg(:) = {'–'};
% prepare HTCondor's ClusterId.ProcId
jobId = cell(cluster.numJobs, 1);
for i = 1 : cluster.numJobs
    if isfield(cluster.job(i), 'clusterId')
        jobId{i} = sprintf('%d.%d', ...
            cluster.job(i).clusterId, cluster.job(i).procId);
    else
        jobId{i} = '–';
    end
end
% initialize last log message
logMsg = cell(cluster.numJobs, 1);
logMsg(:) = {'–'};
% prepare column separator
sep = repmat(' | ', cluster.numJobs, 1);
% prepare symbols for job status
statusSymbols = 'IRXCH>S';


% display loop
while true
    fprintf('\nscanning files, please wait')
    % for each job
    for i = 1 : cluster.numJobs
        fprintf('.')
        
        % scan Matlab standard output
        % make sure file is opened as soon as it exists
        if outFID(i) == -1
            outFID(i) = fopen(cluster.job(i).out, 'r');
        end
        if outFID(i) ~= -1
            % read lines ...
            while true
                line = fgetl(outFID(i));
                % ... until current end of file
                if ~ischar(line)    
                    break
                end
                % ignore MATLAB prompt(s) at beginning of line
                while strncmp(line, '>> ', 3)  
                    line = line(4 : end);
                end
                % if there are backspace characters,
                % ignore everything up to the last one in the line
                % (because SPM uses backspaces to clear the current line)
                % would be better to interpret the character properly
                ind = find(line == char(08), 1, 'last');
                if ~isempty(ind)
                    line = line(ind + 1 : end);
                end
                % determine current primary and secondary message
                if ~isempty(line)
                    if ~isspace(line(1))
                        % not indented -> primary message, clear secondary
                        priMsg{i} = line;
                        secMsg{i} = ' ';
                    else
                        % indented -> secondary message
                        secMsg{i} = line(2 : end);
                    end
                end
            end
        end
        
        % scan Matlab standard error
        % make sure file is opened as soon as it exists
        if errFID(i) == -1
            errFID(i) = fopen(cluster.job(i).err, 'r');
        end
        if (errFID(i) ~= -1)
            % read lines ...
            while true
                line = fgetl(errFID(i));
                % ... until current end of file
                if ~ischar(line)
                    break
                end
                % if a line can be read, i.e. file is not empty, indicate error
                errInd(i) = '*';
                % but reset indicator when Matlab input script starts
                % (because there are irrelevant error messages during Matlab startup)
                if strcmp(line, '***********************')
                    % marker written by input script, see condorAddJob
                    errInd(i) = ' ';
                end
            end
        end
        
        % scan HTCondor log
        % see http://research.cs.wisc.edu/htcondor/manual/v8.2.3/2_6Managing_Job.html#SECTION00367000000000000000
        % make sure file is opened as soon as it exists
        if logFID(i) == -1
            logFID(i) = fopen(cluster.job(i).log, 'r');
        end
        if logFID(i) ~= -1
            % read lines ...
            while true
                line = fgetl(logFID(i));
                % ... until current end of file
                if ~ischar(line)
                    break
                end
                if (numel(line) >= 3) && (line(1) ~= '.') && (line(1) ~= char(9))
                    code = str2double(line(1 : 3));
                    if code ~= 6    % "Image size of job updated" -> ignore
                        logMsg{i} = line(21 : end);
                    end
                    if code == 5    % "Job terminated" -> append termination description
                        line = fgetl(logFID(i));
                        if ischar(line)
                            logMsg{i} = [logMsg{i} ' ' line(6 : end)];
                        end
                    end
                end
            end
        end
    end
    
    % additional information from `condor_q`
    [jobStatus, exitCode, exitSignal] = condor_job_status(clusterHandle);
    statusInd = statusSymbols(jobStatus)';
    exitInd = repmat(' ', cluster.numJobs, 1);
    exitInd(exitCode == 0) = '+';       % exited successfully
    exitInd(exitCode > 0) = '-';        % exited with error
    exitInd(~isnan(exitSignal)) = '~';  % terminated by signal (crashed)
    
    % display monitor and pause
    clc
    fprintf('\n         *** %s: %s ***\n\n', ...
        clusterHandle, cluster.description)
    disp([char(jobNumber) sep char(priMsg) sep char(secMsg) sep ...
        errInd exitInd statusInd sep char(jobId) sep char(logMsg)])
    fprintf('\nabort with ctrl-c\n\n')
    pause(3)
end


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
