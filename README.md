# relo

`relo` automatically reruns or reloads programs when file-system events occur.

    $ npm install -g relo

# Basic usage

Start `relo` with a file to watch, followed by a command to run when it changes.
To avoid confusion between `relo` flags and the given command, a `--` separates
them:

    $ relo file -- echo hello

When `file` is modified, you'll see `hello` printed.

You can set multiple watches by passing multiple paths before the `--`.
Directories are watched recursively.

Note that near-simultaneous events will be grouped. `relo` won't trigger more
than once a second.


# Reloading a server

By default, `relo` waits for the command to finish before running it again. You
can instead terminate the running instance with `--kill` (`-k`):

    $ relo --kill file -- runserver

The `--Kill` (`-K`) flag uses `SIGKILL` instead of `SIGTERM`.


# Rerunning in parallel

With the `--parallel` (`-p`) flag, relo will neither kill nor wait for previous
commands to finish.

    $ relo --parallel file -- curl http://example.com

In this example, `curl` instances spawned by `relo` are completely independent,
and may run at the same time.