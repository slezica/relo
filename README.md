# relo

`relo` automatically reruns or reloads programs when file-system events occur.

    $ npm install -g relo
    $ relo --help


## Basic usage

Start `relo` with a set of paths to watch, followed by a command to run:

    $ relo dir1 file1 -- echo hello

When file-system changes are detected in `file1` or below `dir1/`, you'll see
`hello` printed.

The `--` syntax is somewhat unusual, but it separates clearly any flags passed
to `relo` from those intended for the sub-command.


## Reloading a server

If file-system events occur while the command is still running, `relo` will (by
default) send `SIGINT` to the subprocess, wait for it to finish and restart it.

    $ relo src -- bin/runserver

Depending on the server program, you may want to change how `relo` manages the
process. See **Options**, below.


## Options

#### `-w`, `--wait`

Do not send an interrupt signal to the running process. Let it finish on its
own. Unless `--parallel` is also given, `relo` will wait before re-running the command.


#### `-p`, `--parallel`

Start the new instance of the process immediately, without waiting for the
previous process to finish. This is independent of `--wait`.


#### `-g`, `--group`

Send the interrupt signal to the whole process group, instead of just the
subprocess created by `relo`.

This is useful to reload servers launched from bash scripts, for example.


#### `-s [SIGNAL]`, `--signal [SIGNAL]` (default `SIGINT`)

Change the signal used to stop a running process. Can be `SIGHUP`, `SIGINT`, 
`SIGTERM` or `SIGKILL`. If you don't want any signal sent, use `--wait`.

