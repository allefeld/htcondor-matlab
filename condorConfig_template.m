% TEMPLATE for htcondor-matlab configuration parameters
%
% Copy this file to condorConfig.m in the same folder
% and edit it to adapt htcondor-matlab to your local system.
%
% At a minimum, the pathname of the htcondor-matlab cluster directory
% needs to be set, but review of other parameters is also recommended.
%
%
% This file is part of the development version of htcondor-matlab, see
% https://github.com/allefeld/htcondor-matlab
% Copyright (C) 2016 Carsten Allefeld


%% htcondor-matlab cluster directory
%   point to an existing writable directory that is accessible from all machines
conDir = ['/store02_analysis/' getenv('USER') '/condor/'];


%% time after which clusters are considered "old", in days
oldTime = 30;


%% general entries for the HTCondor submit description file 
% for possible entries, see
%   http://research.cs.wisc.edu/htcondor/manual/v8.2.3/condor_submit.html
submit = {
    % do not change!
    'Universe              = vanilla'           % necessary for Matlab
    'Transfer_Executable   = False'             % local/shared installation is assumed
    'Want_Graceful_Removal = False'             % make removal immediate
    % notification; it may be necessary to set Notify_User to your email address
    'Notification          = Complete'          % get email when the job terminates
    % location and parameters of Matlab executable
   ['Executable            = ' fullfile(matlabroot, 'bin', 'matlab')]
    'Arguments             = -nodisplay -nojvm' % enable Java if necessary
    };
% Apart from this submit configuration, policy configuration is also
% important. Since Matlab jobs cannot be checkpointed, preemption of a job
% (eviction, vacating, killing) means that it has to start over from the
% beginning. Since HTCondor 8.1.5, preemption is disabled by the default
% configuration, but for earlier versions or if a previous configuration
% was kept, ask your HTCondor administrator to use the configuration at
% http://research.cs.wisc.edu/htcondor/manual/v8.1.4/3_5Policy_Configuration.html#SECTION00459500000000000000
