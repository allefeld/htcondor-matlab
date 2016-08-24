function condorAddJob(clusterHandle, jobFun, argIn, numArgOut)

% define a job and add it to an HTCondor cluster
%
% condorAddJob(clusterHandle, jobFun, argIn = {}, numArgOut)
%
% clusterHandle:  handle of cluster the job should be added to
% jobFun:         function handle of the job function
% argIn:          cell array of input arguments for jobFun, may be {}
% numArgOut:      number of output arguments of jobFun to be captured
%                 guessed if not specified
%
% See also condorCreateCluster, condorSubmitCluster, condorMonitorCluster,
% condorGetResults 
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld

if nargin < 3
    argIn = {};
end
if nargin < 4
    numArgOut = abs(nargout(jobFun));   % negative value indicates varargout
    fprintf('number of output arguments guessed to be %d\n', numArgOut)
end

% check number of input arguments
if (nargin(jobFun) >= 0) && (numel(argIn) > nargin(jobFun))
    error('too many input arguments!')
end
% check number of output arguments
if (nargout(jobFun) ~= 0) && (numArgOut == 0)
    error('jobFun has at least one output, must be captured!')
end

% load cluster data structure
clusterDir = [condorGetConfig('conDir') clusterHandle filesep];
load([clusterDir 'cluster.mat'], 'cluster')

% already submitted?
if isfield(cluster, 'id')                                                   %#ok<NODEF>
    error('cluster with handle "%s" has already been submitted to HTCondor!', ...
        clusterHandle)
end

% generate job data structure
job = struct;
% job ids are assigned here in the same way HTCondor does for processes
% within a cluster; therefore job.id corresponds to HTCondor's ProcId. In
% HTCondor, a job is uniquely identified by ClusterId.ProcId, where the
% first part is captured by condorSubmitCluster and stored as cluster.id.
job.id = cluster.numJobs;
job.basename = sprintf('%sjob%03d', cluster.dir, job.id);
job.in = [job.basename '_in.m'];      % Matlab input script
job.out = [job.basename '_out'];      % filename for Matlab standard output
job.err = [job.basename '_err'];      % filename for Matlab standard error
job.inf = [job.basename '_inf.mat'];  % Matlab job information
job.res = [job.basename '_res.mat'];  % filename for Matlab results
job.log = [job.basename '_log'];      % filename for HTCondor log file

% create job information; used in input script
jobInformation = struct;
jobInformation.fun = jobFun;
jobInformation.argIn = argIn;
jobInformation.numArgOut = numArgOut;
jobInformation.path = path;
jobInformation.wd = pwd;
save(job.inf, 'jobInformation');

% create input script for Matlab process
fid = fopen(job.in, 'w');
%  -> print marker for condorMonitorCluster to stderr
fprintf(fid, 'fprintf(2, ''\\n***********************\\n'');\n');
%  -> report HTCondor slot and machine, uses `_CONDOR_SLOT` and `condor_config_val`
fprintf(fid, 'slot = getenv(''_CONDOR_SLOT'');\n');
fprintf(fid, 'setenv(''LD_LIBRARY_PATH'')\n');
fprintf(fid, '[status, hostname] = system(''condor_config_val -raw HOSTNAME'');\n');
fprintf(fid, 'if status ~= 0, hostname = ''localhost\\n''; end\n');
fprintf(fid, 'fprintf([''job executing on '' slot ''@'' hostname])\n');
%  -> prepare to run job
fprintf(fid, 'clear\n');
fprintf(fid, 'load(''%s'')\n', job.inf);
fprintf(fid, 'path(jobInformation.path)\n');
fprintf(fid, 'cd(jobInformation.wd)\n');
%  -> run job and capture results
fprintf(fid, 'condorResult = cell(1, jobInformation.numArgOut);\n');
fprintf(fid, '[condorResult{:}] = jobInformation.fun(jobInformation.argIn{:});\n');
%  -> save results
fprintf(fid, 'save(''%s'', ''condorResult'')\n', job.res);
fclose(fid);

% add job to cluster data structure and save
cluster.numJobs = cluster.numJobs + 1;
cluster.job(cluster.numJobs) = job;
save([clusterDir 'cluster.mat'], 'cluster')


% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.
