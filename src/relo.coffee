require('source-map-support').install()

fs    = require 'fs'
cp    = require 'child_process'
debug = require('debug') 'relo'
cli   = require './cli'
watch = require './watch'


options = null # will hold a command-line options object
subproc = null # will hold a ChildProcess object
program = null # will hold the name of the child program

spawn = ->
  program = options.command[0]
  argv    = options.command[1..]

  subproc = cp.spawn program, argv,
    cwd  : process.cwd()
    stdio: 'inherit'

  debug "Started #{program}"

  subproc.on 'exit', (status, signal) ->
    debug "#{program} exited"
    subproc = null


respawn = ->
  if not subproc?
    spawn()

  else
    if options.kill
      debug "Terminating #{program}"
      subproc.kill 'SIGTERM'

    if options.Kill
      debug "Killing #{program}"
      subproc.kill 'SIGKILL'

    if options.parallel
      spawn()
    else
      subproc.on 'exit', spawn


@main = (argv) ->
  process.name = 'relo'

  options = cli.parse argv

  for path in options.watches
    watch.watch path, respawn

  spawn()
