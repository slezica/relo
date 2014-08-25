# redo

`redo` automatically reruns or reloads programs when file-system events occur.


# Basic usage

Start `redo` with a file to watch, followed by a command to run when it changes.
To avoid confusion between `redo` flags and the given command, a `--` separates
them:

    $ redo file -- echo hello

When `file` is modified, you'll see `hello` printed.

You can set multiple watches by passing multiple paths before the `--`.
Directories are watched recursively.

Note that near-simultaneous events will be grouped. `redo` won't trigger more
than once a second.


# Reloading a server

By default, `redo` waits for the command to finish before running it again. You
can instead terminate the running instance with `--kill` (`-k`):

    $ redo --kill file -- runserver

The `--Kill` (`-K`) flag uses `SIGKILL` instead of `SIGTERM`.


# Rerunning in parallel

With the `--parallel` (`-p`) flag, redo will neither kill nor wait for previous
commands to finish.

    $ redo --parallel file -- curl http://example.com

In this example, `curl` instances spawned by `redo` are completely independent,
and may run at the same time.