### Scenario
The monitoring system has triggered an alert for a high number of "zombie" processes on this server. While zombie processes don't consume CPU or memory, they do consume slots in the process table. If too many accumulate, the system won't be able to start new processes. 

### Objective
Identify the parent process that is failing to reap its children, and terminate it to clear the zombies from the process table.

### Useful Commands
- `top`
- `ps aux`
- `ps -ef`
- `pstree -p`
