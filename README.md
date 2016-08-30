# Submit Matlab jobs to HTCondor from Matlab

*htcondor-matlab* is a set of Matlab functions to interface with the
[HTCondor](http://research.cs.wisc.edu/htcondor/) high-throughput computing
software framework, to submit Matlab functions as jobs.

It is assumed that the HTCondor machines share a filesystem and that all
machines have access to the resources necessary to run the jobs, including an
installation of Matlab. The functions use HTCondor commands and have therefore
to be run on one of the HTCondor machines.


## Installation

Put the *htcondor-matlab* functions into a directory on the Matlab path. Then
copy `condorConfig_template.m` to `condorConfig.m` in the same directory and
edit the copy. At a minimum, adjust the value of `conDir` to point to an
existing and writable directory, the *htcondor-matlab* cluster directory,
which has to be accessible from all HTCondor machines.


## Usage

The code for creating and submitting a cluster of jobs has the following form:

    clusterHandle = condorCreateCluster;
    for i = 1 : 10
       condorAddJob(clusterHandle, @exampleJob, {i}, 1)
    end
    condorSubmitCluster(clusterHandle)

In this example, the resulting cluster consists of 10 jobs, where each job
runs `exampleJob(i)` with values of `i` from 1 to 10. The job function used
here is included as `exampleJob.m` with *htcondor-matlab*. It takes a number
as argument and returns its square; unless the number is a prime, in which
case an error is thrown.

`clusterHandle` is a string of the form `cluster#` where `#` is a sequential
number starting from 0. The handle is assigned when the __cluster is created__:

    clusterHandle = condorCreateCluster

It is used to identify the cluster to all other functions.

A __job is defined__ and added to a cluster by:

    condorAddJob(clusterHandle, jobFun, argIn, numArgOut)

`jobFun` is the function handle of the job function; it can reference an
m-file (including private) as well as an anonymous, local, or nested function.
`argIn` is a cell array containing the arguments to be passed to the job
function, and `numArgOut` is the number of its output arguments.

A cluster of jobs is __submitted__ to HTCondor using:

    condorSubmitCluster(clusterHandle)

After submission, the progress of its jobs can be __monitored__ using:

    condorMonitorCluster(clusterHandle)

This function scans output, error and HTCondor log files of all jobs and
prints overview information at regular intervals. It assumes a specific form
of the output generated by the job function:

    primary message 1
      secondary message 1
      secondary message 2
    primary message 2
      secondary message 3
      secondary message 4

That is, a line with no leading whitespace is considered a ‘primary message’,
a line with leading whitespace a ‘secondary message’. This way, information
about larger processing units in the job can be separated from information
that tracks progress within these units, giving a more fine-grained overview.

The output of `condorMonitorCluster` has tabular form with the following
structure:  
– The 1st column shows the job number `###`, starting from 000.  
– The 2nd column shows the last primary message.  
– The 3rd column shows the last secondary message since the last primary
message.  
– In the 4th column, jobs that have Matlab error messages are marked with ‘∗’.
Jobs which exited successfully are marked with ‘+’, which exited with an error
are marked with ‘-’, and which crashed are marked with ‘~’. Additionally the
HTCondor job status is indicated by one of the letters ‘I’ = idle, ‘R’ =
running, ‘X’ = removed, ‘C’ = completed, or ‘H’ = on hold.  
– The 5th column shows the HTCondor job identifier in the form
ClusterId.ProcId.  
– The 6th column shows the last event from the HTCondor log (excluding ‘image
size updated’)

The information is presented as text in the Command Window, or the terminal
window if Matlab is used without GUI. This has the advantage that
`condorMonitorCluster` can also be used under an `ssh` login.

The __return values__ of the jobs in a cluster can be retrieved by:

    results = condorGetResults(clusterHandle);

`results` is a cell array with one element per job. If a job exited
successfully, the corresponding element is a cell array containing the return
value(s) of that job. If a job is not (yet) completed, the element is an empty
array. Instead of or in addition to returning values, job functions can of
course also write their results directly to files.


## Clusters, jobs, handles, and IDs

*htcondor-matlab* adopts the terminology of HTCondor: A single computation
unit is called a ‘job’, and a group of jobs belonging together is called a
‘cluster’. In HTCondor, a job is also called a ‘process’ after submission.
Cluster IDs are integers assigned by HTCondor sequentially on submission, and
process IDs are integers assigned to jobs in the order of the submit
description file, starting from 0 within a cluster.

For technical reasons, the `clusterHandle` assigned by *htcondor-matlab* is
not identical to HTCondor’s ClusterId, and the job number assigned by
*htcondor-matlab* can differ from HTCondor’s ProcId. However,
`condorMonitorCluster` lists for each job the corresponding identifier of the
form ClusterId.ProcId used by HTCondor, so that its tools including
[`condor_q`](http://research.cs.wisc.edu/htcondor/manual/v8.2.3/condor_q.html)
and
[`condor_rm`](http://research.cs.wisc.edu/htcondor/manual/v8.2.3/condor_rm.html)
can be easily used in conjunction.


## Internal data structure

In the *htcondor-matlab* cluster directory, for each cluster a subdirectory is
created with a name identical to its handle, `cluster#`, which contains data
to manage and run the cluster as well as the return values of completed jobs.
To save disk space, it is advisable to delete a subdirectory after the
corresponding cluster is finished and its return values are no longer needed.

Within each cluster subdirectory, general cluster and job management data are
kept in `cluster.mat`. After submission, the cluster’s HTcondor submit
description file is `submit`. Job-specific data are in files whose name begins
with `job###`, where `###` is the job number. On submission, the file
`job###_in.m` containing the job’s Matlab input script and the file
`job###_inf.mat` with job information used by that script are created. The
job’s *standard output* is redirected to the file `job###_out` and its
*standard error* to `job###_err`. HTCondor *log messages* are written to
`job###_log`. When finished, the return values of the job are written to
`job###_res.mat`.


------------------------------------------------------------------------------


This software was developed with Matlab R2013a and [HTCondor
8.2.3](http://research.cs.wisc.edu/htcondor/manual/v8.2.3/index.html) on
Debian 7.8, but may work with other versions and OSs, too. It is copyrighted ©
2016 by Carsten Allefeld and released under the terms of the GNU General
Public License, version 3 or later.
