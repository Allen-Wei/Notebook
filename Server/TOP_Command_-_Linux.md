# TOP Command - Linux 

## What Information Is Shown

The following information is displayed when you run the Linux top command:

Line 1:

* The time
* How long the computer has been running
* Number of users
* Load average

The load average shows the system load time for the last 1, 5 and 15 minutes.

Line 2:

* Total number of tasks
* Number of running tasks
* Number of sleeping tasks
* Number of stopped tasks
* Number of zombie tasks 

Line 3:

* CPU usage as a percentage by the user
* CPU usage as a percentage by system
* CPU usage as a percentage by low priority processes
* CPU usage as a percentage by idle processes
* CPU usage as a percentage by io wait
* CPU usage as a percentage by hardware interrupts
* CPU usage as a percentage by software interrupts
* CPU usage as a percentage by steal time 

This guide gives a definition of what CPU usage means.

Line 3:

* Total system memory
* Free memory
* Memory used
* Buffer cache

Line 4:

* Total swap available
* Total swap free
* Total swap used
* available memory

This guide gives a description of swap partitions and whether you need them.

Main table:

* Process ID
* User
* Priority
* Nice level
* Virtual memory used by process
* Resident memory used by a process
* Shareable memory
* CPU used by process as a percentage
* Memory used by process as a percentage
* Time process has been running
* Command

## Samples

### Startup

* `top -d <number of seconds>` to specify a delay between the screen refreshes whilst using top type the following, e.g.: `top -d 5`.
* `top -o <columnname>` sort the columns in the top command by a column name, e.g.: 'top -o %CPU'.

### Runing

* `q`: Exit
* `i`: Don't show idle process
* `c`: Show process(bin) path
* `e`: 'E'/'e' summary/task memory scale
* `P`: Sort by %CPU
* `M`: Sort by %MEM
* Toggle Summary: `l` load avg; `t` task/cpu stats; `m` memory info.
* Toggle: `c` Cmd name/line; `i` Idle; `S` Time; `j` String justify
* `d` or `s`: Set update interval.
* `W`: save the running top command results under `/root/.toprc` or `/home/$LOGNAME/.toprc`.