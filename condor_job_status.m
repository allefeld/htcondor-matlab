function [jobStatus, exitCode, exitSignal] = condor_job_status(clusterHandle)

% internal helper function
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld

% obtain job status and exit status of all jobs of a cluster
%
% [jobStatus, exitCode, exitSignal] = condor_job_status(clusterHandle)
% [statusSymbols, exitSymbols] = condor_job_status
%
% clusterHandle:  handle of cluster to be submitted
% jobStatus,
% exitCode,
% exitSignal:     see below, array with one element for each job
% statusSymbols,
% exitSymbols:    define characters used to indicate job status and exit
%                 status in the output of condorMonitorJob and condorClusters 
%
% Uses `condor_q -userlog` to obtain information on jobs incl. removed and
% completed ones.
%
% JobStatus according to
%   http://research.cs.wisc.edu/htcondor/manual/v8.2.3/12_Appendix_A.html#91160
% with the corresponding symbols used by `condor_q`
%   http://research.cs.wisc.edu/htcondor/manual/v8.2.3/condor_q.html
%     1: Idle                 I
%     2: Running              R
%     3: Removed              X
%     4: Completed            C
%     5: Held                 H
%     6: Transferring Output  >
%     7: Suspended            S
% An additional job status is listed under "ST" in the documentation of `condor_q`:
%        Transferring Input <
% but with no corresponding JobStatus value.
% 
% Jobs with status 1, 2, 7 are in the queue.
% Jobs with status 5 are still in the queue, but are periodically removed, so
% they may be treated as such.
% 'Transferring' states should not occur with our configuration. To be
% safe, they should be treated the same as 'Running'.
%
% ExitCode according to
%   http://research.cs.wisc.edu/htcondor/manual/v8.2.3/12_Appendix_A.html#90997
% If a job is not completed, `condor_q -userlog` returns 'undefined', which
% translates to an NaN value.
%
% ExitSignal according to
%   http://research.cs.wisc.edu/htcondor/manual/v8.2.3/12_Appendix_A.html#91001
% If a job did not terminate abnormally, `condor_q -userlog` returns
% 'undefined', which translates to an NaN value.
%
% The function returns NaN for a job in all output arguments if its
% HTCondor log file does not exist (the job has never been submitted) or is empty.


% return symbols for job statūs
if nargin == 0
    jobStatus = 'IRXCH>S';
    exitCode = '+-~';
    return
end

% load cluster data structure
cluster = condor_get_cluster(clusterHandle);

% run condor_q on jobs
jobStatus = nan(cluster.numJobs, 1);
exitCode = nan(cluster.numJobs, 1);
exitSignal = nan(cluster.numJobs, 1);
for i = 1 : cluster.numJobs
    if exist(cluster.job(i).log, 'file')
        [status, result] = system(sprintf(...
            'condor_q -userlog "%s" -autoformat JobStatus ExitCode ExitSignal', ...
            cluster.job(i).log));
        if status ~= 0
            error('error calling `condor_q`:\n  %s\n', result)
        end
        if ~isempty(result)
            result = strsplit(strtrim(result), ' ');
            jobStatus(i) = str2double(result{1});
            exitCode(i) = str2double(result{2});
            exitSignal(i) = str2double(result{3});
        end
    end
end


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
