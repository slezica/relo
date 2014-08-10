# redo

`redo` automatically reruns or reloads programs when file-system events occur.


# Basic usage

Start `redo` with a file to watch, followed by a command to run when it changes:

    $ redo --watch file echo hello

When `file` is modified, you'll see `hello` printed.

You can set multiple watches by repeating the `--watch` (`-w`) argument.
Directories are watched recursively.

Note that near-simultaneous events will be grouped. `redo` won't trigger more
than once a second.


# Reloading a server

By default, `redo` waits for the command to finish before running it again. You
can instead terminate the running instance with `--kill` (`-k`):

    $ redo --watch dir/ --kill runserver

The `--Kill` (`-K`) flag uses `SIGKILL` instead of `SIGTERM`.


# Rerunning in parallel

With the `--parallel` (`-p`) flag, redo will neither kill nor wait for previous
commands to finish.

    $ redo --watch dir/ --parallel curl ...