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


## Example

The code for creating and submitting a cluster of jobs has the following form:

    clusterHandle = condorCreateCluster;
    for i = 1 : 16
        condorAddJob(clusterHandle, @exampleJob, {i}, 1)
    end
    condorSubmitCluster(clusterHandle)

In this example, the resulting cluster consists of 16 jobs, where each job runs
`exampleJob(i)` with values of `i` from 1 to 16. The job function used here is
included as `exampleJob.m` with *htcondor-matlab*; it takes a number as
argument and returns its square.


## Usage

A __cluster is created__ by

    clusterHandle = condorCreateCluster(description);

The cluster is assigned a handle, which is a string of the form `cluster#`
where `#` is a sequential number starting from 0. It is used to identify the
cluster to all other functions. The cluster can be given a descriptive label,
but one is automatically generated if the argument is omitted.

A __job is added__ to a cluster by

    condorAddJob(clusterHandle, jobFun, argIn, numArgOut)

`jobFun` is the function handle of the Matlab job function; it can reference an
m-file (including private) as well as an anonymous, local, or nested function.
`argIn` is a cell array containing the arguments to be passed to the job
function, and `numArgOut` is the number of its output arguments.

A cluster of jobs is __submitted__ to HTCondor by

    condorSubmitCluster(clusterHandle)

A cluster can be __resubmitted__ with the same syntax, in case one or more of
its jobs failed. Suitable jobs (neither still running nor completed
successfully) are automatically identified and only they are resubmitted. If
`'debug'` is given as a second argument to `condorSubmitCluster`, jobs are not
submitted to HTCondor but executed locally and sequentially, to facilitate
finding programming errors.

After submission, the progress of a cluster's jobs can be __monitored__ using

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
Jobs that exited successfully are marked with ‘+’, that exited with an error
are marked with ‘-’, and that crashed are marked with ‘~’. The HTCondor job
status is indicated by one of the letters ‘I’ = idle, ‘R’ = running, ‘X’ =
removed, ‘C’ = completed, or ‘H’ = on hold.  
– The 5th column shows the HTCondor job identifier in the form
ClusterId.ProcId.  
– The 6th column shows the last event from the HTCondor log (excluding ‘image
size updated’)

The information is presented as text in the Command Window, or the terminal
window if Matlab is used without GUI. This has the advantage that
`condorMonitorCluster` can also be used under an `ssh` login.

An error during job execution can be diagnosed by __inspecting__ the output,
error, and HTCondor log of a job using

    condorInspect(clusterHandle, jobNumber)

The __return values__ of the jobs in a cluster can be retrieved by

    results = condorGetResults(clusterHandle);

`results` is a cell array with one element per job. If a job exited
successfully, the corresponding element is a cell array containing the return
value(s) of that job. If a job did not (yet) exit successfully, the element is
an empty array. Instead of or in addition to returning values, job functions
can of course also write their results directly to files.

A __list__ of all existing clusters, including summary statistics about their
jobs’ status, can be obtained by

    condorClusters

It uses the same symbols as `condorMonitorCluster`, see above. Old clusters can
be removed using `condorClusters clean`.


## Example continued

With a probability of 50%, the job function `exampleJob` does not complete
successfully, but throws an error. This is to simulate the fragility of job
execution in real applications.

Monitor the submitted cluster until all the jobs have completed (symbol ‘C’).
Most likely, some of them will have failed (symbol ‘-’). In that case, resubmit
the cluster and monitor it again. Repeat this procedure until all jobs have
completed successfully (symbol ‘+’). After that, the retrieved `results` should
be a cell array of cell arrays containing the square numbers from 1 to 256.


## Clusters, jobs, handles, and IDs

*htcondor-matlab* adopts the terminology of HTCondor: A single computation unit
is called a ‘job’, and a group of jobs belonging together is called a
‘cluster’. In HTCondor, a job is also called a ‘process’ after submission.
Cluster IDs are integers assigned by HTCondor in the order of submission, and
process IDs are integers assigned to jobs in the order of the submit
description file, starting from 0 within a cluster.

For technical reasons, the `clusterHandle` assigned by *htcondor-matlab* is not
identical to HTCondor’s ClusterId. On first submission, the job number assigned
by *htcondor-matlab* is identical to HTCondor’s ProcId, but resubmitted jobs
belong to a new HTCondor cluster, with ProcIds starting from 0 again.
However, `condorMonitorCluster` lists for each job the corresponding identifier
of the form ClusterId.ProcId used by HTCondor, so that its tools including
[`condor_rm`](http://research.cs.wisc.edu/htcondor/manual/v8.2.3/condor_rm.html)
can be easily used in conjunction.


## Internal data structure

In the *htcondor-matlab* cluster directory, for each cluster a subdirectory is
created with a name identical to its handle, `cluster#`, which contains data to
manage and run the cluster as well as the return values of completed jobs. To
save disk space, it is advisable to remove old clusters from time to time
(`condorClusters clean`).

Within each cluster subdirectory, general cluster and job management data are
kept in `cluster.mat`. After submission, the cluster’s HTCondor submit
description file is `submit`. Job-specific data are in files whose name begins
with `job###`, where `###` is the job number. On addition of a job, the file
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

