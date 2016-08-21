# Submit Matlab jobs to HTCondor from Matlab

A set of Matlab functions to interface with the
[HTCondor](http://research.cs.wisc.edu/htcondor/) high-throughput computing
software framework, to submit Matlab functions as tasks.

It is assumed that the HTCondor machines [share a filesystem](http://research.cs.wisc.edu/htcondor/manual/v8.2.3/2_5Submitting_Job.html#SECTION00353000000000000000) and that all machines have access to the resources necessary to run the tasks. The functions use the HTCondor commands `condor_submit` and `condor_config_val`.

## Installation

Put the htcondor-matlab functions into a directory on the Matlab path. Then edit `condorConfig.m` and adjust the value of `conDir` to point to an existing and writable directory, the htcondor-matlab job directory, which has to be accessible from all HTCondor machines.

## Usage

The code for creating and submitting a job has the following form:

    jobHandle = condorCreateJob;
    for i = 1 : 10
       condorCreateTask(jobHandle, @condorTestTask, {i}, 1)
    end
    condorSubmitJob(jobHandle)

The resulting job consists of 10 tasks, where each task runs `condorTestTask(i)` with values of `i` from 1 to 10. The function `condorTestTask` used here is an example task included with htcondor-matlab. It takes a number as argument and returns its square; unless the number is a prime, in which case an error is thrown.

`jobhandle` is a string of the form `job#` where `#` is a sequential number starting from 1. The handle is assigned to a job by `condorCreateJob` and is used to identify the job to all other functions.

A task is defined and added to a job by:

    condorCreateTask(jobHandle, taskFun, argIn, numArgOut)

`taskFun` is the function handle of the task function; it can reference an m-file, a nested function, or an anonymous function. `argIn` is a cell array containing the arguments to be passed to the task function, and `numArgOut` is the number of its output arguments.

After submitting a job, its progress can be monitored using:

    condorMonitorJob(jobHandle)

This function scans standard output, standard error and HTCondor log files of all tasks and prints overview information at regular intervals. It assumes a specific form of the standard output: A line with no leading whitespace is considered a 'primary message', a line with leading whitespace a 'secondary message'. This way, information about larger processing units in the task can be separated from information that tracks progress within these units. The output has tabular form with the following structure:  
– The first column shows the task ID. Tasks with error messages are marked with an asterisk, '`*`'.  
– The second column shows the last primary message.  
– The third column shows the last secondary message since the last primary message.  
– The fourth column shows the last entry from the HTCondor log.

The return values of the tasks in a job are retrieved by:

    results = condorGetResults(jobHandle);

`results` is a cell array with one element per task. If a task is not yet finished, the corresponding element of `results` is an empty array. If a task finished successfully, the corresponding element is a cell array containing the return value(s) of that task. If a task exited with an error, the corresponding element is a cell array that contains an empty array.

Instead of or in addition to returning values, task functions can also write their results to files.

## Data structure

In the htcondor-matlab job directory, for each job a subdirectory is created with a name identical to its handle, which contains data to manage and run the job as well as the return values of completed tasks. To save disk space, it is advisable to delete a subdirectory after the corresponding job is finished and its return values are no longer needed.

Within each job directory, the job's HTcondor submit description file is `submit`. Task-specific data are in files beginning with `task###`, where `###` is the task ID, a three-digit number starting from 000. In particular, `task###_out` contains the standard output of the task, `task###_err` the standard error, and `task###_log` the HTCondor log.

***

This software was developed with Matlab R2013a and HTCondor 8.2.3 on Debian 7.8, but may work with other versions, too.
It is copyrighted © 2016 by Carsten Allefeld and released under the terms of the
GNU General Public License, version 3 or later.
