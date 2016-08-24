function condorMonitorCluster(clusterHandle)

% monitor job progress of a running HTCondor cluster
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
clusterDir = [condorGetConfig('conDir') clusterHandle filesep];
load([clusterDir 'cluster.mat'], 'cluster')

% already submitted?
if ~isfield(cluster, 'id')
    error('Cluster with handle "%s" has not yet been submitted to HTCondor!', ...
        clusterHandle)
end

% for all jobs
%   initialize file ids to handle
outFID = -1 * ones(cluster.numJobs, 1);  % Matlab standard output
errFID = -1 * ones(cluster.numJobs, 1);  % Matlab standard error
logFID = -1 * ones(cluster.numJobs, 1);  % HTCondor log
%   initialize current primary and secondary message for monitor
priMsg = cell(cluster.numJobs, 1);
priMsg(:) = {'–'};
secMsg = cell(cluster.numJobs, 1);
secMsg(:) = {'–'};
%   initialize error indicator for monitor
errInd = repmat(' ', cluster.numJobs, 1);
%   initialize last log message for monitor
logMsg = cell(cluster.numJobs, 1);
logMsg(:) = {'–'};
% prepare job id for monitor (corresponds to HTCondor's ProcId)
jobId = reshape(sprintf(' %03d | ', cluster.job.id), 7, [])';
% prepare column separator for monitor
sep = repmat(' | ', cluster.numJobs, 1);

% display loop
while true
    fprintf('\nscanning files')
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
                if strcmp(line, 'input script started')
                    % marker written by input script, see condorAddJob
                    errInd(i) = ' ';
                end
            end
        end
        
        % scan HTCondor log
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
                    if code ~= 6            % ignore image resize
                        logMsg{i} = line(21 : end);
                    end
                end
            end
        end
    end
    
    % display monitor and pause
    clc
    fprintf('\n    *** monitoring cluster with handle "%s" / HTCondor ClusterId %d  ***\n\n', ...
        clusterHandle, cluster.id)
    disp([char(errInd) jobId char(priMsg) sep char(secMsg) sep char(logMsg) sep])
    fprintf('\nabort with ctrl-c\n\n')
    pause(1)
end


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
