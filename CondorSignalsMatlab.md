# Impact of Unix Signals on HTCondor Matlab jobs


## hard kill signals

not caught by Matlab, recorded only in HTCondor log

    1 HUP, 4 ILL, 9 KILL, 10 USR1, 12 USR2, 14 ALRM, 15 TERM,
    16 STKFLT, 24 XCPU, 25 XFSZ, 26 VTALRM, 27 PROF, 29 POLL,
    30 PWR, 31 SYS 

all signals logged as 'Abnormal termination (signal #)', except signal 4 logged as 11


## soft kill signals

caught by Matlab, recorded both in output and HTCondor log

    3 QUIT, 6 ABRT, 7 BUS, 8 FPE, 11 SEGV

all signals logged as 'Abnormal termination (signal 9)'


## ignored signals

Matlab finishes normally

    13 PIPE, 17 CHLD, 18 CONT, 21 TTIN, 22 TTOU, 23 URG, 28 WINCH

logged as 'Normal termination (return value 0)'


## stop signals

Matlab process is stopped but can be continued normally (`SIGCONT`)

    19 STOP, 20 TSTP

this is not noticed by HTCondor (job remains 'running')


## interruption

Matlab acts as if interrupted by Ctrl-C

    2 INT

for HTCondor, the job terminates normally; job saves 'results', but they are
empty


## ???

    5 TRAP
    
apparently the Matlab process is killed, but this is not noticed by HTCondor
(job remains 'running' forever)

