function condorMonitorJob(jobHandle)

% condorMonitorJob(jobHandle)

jobDir = [condorStorage jobHandle '/'];
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
                if ~isempty(l)
                    if isspace(l(1))
                        osl{i} = l(2 : end);
                    else
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
            l = fgetl(efid(i));
            if ischar(l)
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
                        ls{i} = l(20 : end);
                    end
                end
            end
        end
    end
    
    clc
    fprintf('\n    *** monitoring condor job "%s" on cluster %d  ***\n\n', ...
        jobHandle, job.cluster)
    disp([char(err), ids, char(osh), sep, char(osl), sep, char(ls), sep])
    pause(1)
end
