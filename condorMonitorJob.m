function condorMonitorJob(jobHandle)

% monitor progress of running Condor job
%
% condorMonitorJob(jobHandle)
%
% jobHandle:    handle of job (string)
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


jobDir = [condorConfig('condir') jobHandle '/'];
load([jobDir 'job.mat'], 'job')

ofid = -1 * ones(job.numTasks, 1);
osh = cell(job.numTasks, 1);
osh(:) = {'–'};
osl = cell(job.numTasks, 1);
osl(:) = {'–'};

efid = -1 * ones(job.numTasks, 1);
err = repmat(' ', job.numTasks, 1);

lfid = -1 * ones(job.numTasks, 1);
ls = cell(job.numTasks, 1);
ls(:) = {'–'};

ids = reshape(sprintf(' %03d | ', job.task.id), 7, [])';
sep = repmat(' | ', job.numTasks, 1);

while true
    fprintf('\nscanning files')
    for i = 1 : job.numTasks
        fprintf('.')
        
        % read out files
        if ofid(i) == -1
            ofid(i) = fopen(job.task(i).out, 'r');
        end
        if ofid(i) ~= -1
            while true
                l = fgetl(ofid(i));
                if ~ischar(l), break, end   % EOF
                % remove MATLAB prompt
                while strncmp(l, '>> ', 3)  
                    l = l(4 : end);
                end
                % deal with SPM's 08 = BS characters
                ind = find(l == char(08), 1, 'last');
                if ~isempty(ind)
                    l = l(ind + 1 : end);
                end
                % sort lines into primary and secondary outputs
                if ~isempty(l)
                    if isspace(l(1))
                        % indented -> secondary output
                        osl{i} = l(2 : end);
                    else
                        % not indented -> primary output, clear secondary
                        osh{i} = l;
                        osl{i} = ' ';
                    end
                end
            end
        end
        
        % read err files
        if efid(i) == -1
            efid(i) = fopen(job.task(i).err, 'r');
        end
        if (efid(i) ~= -1)
%             l = fgetl(efid(i));
%             if ischar(l)
%                 err(i) = '*';
%             end
            % move to end
            fseek(efid(i), 0, 1);
            % read end position
            fsize = ftell(efid(i));
            % HACK to account for strange dbus / hal error messages
            if fsize > 360
                err(i) = '*';
            end
        end
        
        % read log files
        if lfid(i) == -1
            lfid(i) = fopen(job.task(i).log, 'r');
        end
        if lfid(i) ~= -1
            while true
                l = fgetl(lfid(i));
                if ~ischar(l), break, end   % EOF
                if (numel(l) >= 3) && (l(1) ~= '.') && (l(1) ~= char(9))
                    code = str2double(l(1 : 3));
                    if code ~= 6            % ignore image resize
                        ls{i} = l(21 : end);
                    end
                end
            end
        end
    end
    
    clc
    fprintf('\n    *** monitoring "%s" on condor cluster %d  ***\n\n', ...
        jobHandle, job.cluster)
    disp([char(err), ids, char(osh), sep, char(osl), sep, char(ls), sep])
    pause(1)
end



% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
