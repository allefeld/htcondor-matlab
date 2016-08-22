# Submit Matlab jobs to HTCondor from Matlab

A set of Matlab functions to interface with the
[HTCondor](http://research.cs.wisc.edu/htcondor/) high-throughput computing
software framework, to submit Matlab functions as jobs.

It is assumed that the HTCondor machines share a filesystem and that all machines have access to the resources necessary to run the jobs, including an installation of Matlab. The functions use the HTCondor commands `condor_submit` and `condor_config_val`, and have to be run on one of the HTCondor machines.

## Installation

Put the htcondor-matlab functions into a directory on the Matlab path. Then edit `condorConfig.m` and adjust the value of `conDir` to point to an existing and writable directory, the htcondor-matlab cluster directory, which has to be accessible from all HTCondor machines. Alternatively, copy `condorConfig.m` to a directory with higher preference on the path (or the current directory), and edit this copy.

## Usage

The code for creating and submitting a cluster has the following form:

    clusterHandle = condorCreateCluster;
    for i = 1 : 10
       condorAddJob(clusterHandle, @condorTestJob, {i}, 1)
    end
    condorSubmitCluster(clusterHandle)

The resulting cluster consists of 10 jobs, where each job runs `condorTestJob(i)` with values of `i` from 1 to 10. The function `condorTestJob` used here is an example job included with htcondor-matlab. It takes a number as argument and returns its square; unless the number is a prime, in which case an error is thrown.

`clusterHandle` is a string of the form `cluster#` where `#` is a sequential number starting from 1. The handle is assigned to a cluster by `condorCreateCluster` and is used to identify the cluster to all other functions.

A job is defined and added to a cluster by:

    condorAddJob(clusterHandle, jobFun, argIn, numArgOut)

`jobFun` is the function handle of the job function; it can reference an m-file (including private) as well as an anonymous, local, or nested function. `argIn` is a cell array containing the arguments to be passed to the job function, and `numArgOut` is the number of its output arguments.

After submitting a cluster, its progress can be monitored using:

    condorMonitorCluster(clusterHandle)

This function scans standard output, standard error and HTCondor log files of all jobs and prints overview information at regular intervals. It assumes a specific form of the standard output: A line with no leading whitespace is considered a 'primary message', a line with leading whitespace a 'secondary message'. This way, information about larger processing units in the job can be separated from information that tracks progress within these units. The output has tabular form with the following structure:  
– The first column shows the job ID (corresponding to HTCondor's ProcId). Jobs with error messages are marked with an asterisk, '`*`'.  
– The second column shows the last primary message.  
– The third column shows the last secondary message since the last primary message.  
– The fourth column shows the last entry from the HTCondor log.

After all jobs in a cluster have finished, their return values can be retrieved by:

    results = condorGetResults(clusterHandle);

`results` is a cell array with one element per job. For each job, the corresponding element is a cell array containing the return value(s) of that job.

Instead of or in addition to returning values, job functions can also write their results to files.

See also the Matlab `help` of `condorCreateCluster`, `condorAddJob`, `condorSubmitCluster`, `condorMonitorCluster`, and `condorGetResults`.

## Data structure

In the htcondor-matlab cluster directory, for each cluster a subdirectory is created with a name identical to its handle, which contains data to manage and run the cluster as well as the return values of completed jobs. To save disk space, it is advisable to delete a subdirectory after the corresponding cluster is finished and its return values are no longer needed.

Within each cluster directory, the cluster's HTcondor submit description file is `submit`. Job-specific data are in files beginning with `job###`, where `###` is the job ID, a three-digit number starting from 000. In particular, `job###_out` contains the standard output of the job, `job###_err` the standard error, and `job###_log` the HTCondor log.

***

This software was developed with Matlab R2013a and HTCondor 8.2.3 on Debian 7.8, but may work with other versions, too.
It is copyrighted © 2016 by Carsten Allefeld and released under the terms of the
GNU General Public License, version 3 or later.

