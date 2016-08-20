# Matlab interface to HTCondor

A set of Matlab functions to interface with the
[HTCondor](http://research.cs.wisc.edu/htcondor/) high-throughput computing
software framework.

Run matlab jobs

Assumes that HTCondor machines share a filesystem.
See ['Submitting Jobs Using a Shared File System'](http://research.cs.wisc.edu/htcondor/manual/v8.2.3/2_5Submitting_Job.html#SECTION00353000000000000000)

Has to be run on one of the HTCondor machines, calls `condor_submit`.

calls `condor_config_val`

condorMonitorJob assumed stdout format

Example:

    jobHandle = condorCreateJob;
    for i = 1 : 10
       condorCreateTask(jobHandle, @condorTestTask, {i}, 1)
    end
    condorSubmitJob(jobHandle)

    condorMonitorJob(jobHandle)

    results = condorGetResults(jobHandle);
    results{:} 


***

This software was developed with Matlab R2013a and HTCondor 8.2.3 on Debian 7.8, but may work with other versions, too.
It is copyrighted © 2016 by Carsten Allefeld and released under the terms of the
GNU General Public License, version 3 or later.
