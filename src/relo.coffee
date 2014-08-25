require('source-map-support').install()

fs    = require 'fs'
cp    = require 'child_process'
cli   = require './cli'
watch = require './watch'


options = null # will hold a command-line options object
subproc = null # will hold a ChildProcess object


debug = (message) ->
  # These messages are picked up by the test suite
  console.log message if process.env.DEBUG is 'true'


spawn = ->
  prog = options.command[0]
  argv = options.command[1..]

  subproc = cp.spawn prog, argv,
    cwd  : process.cwd()
    stdio: 'inherit'

  debug "SPAWN #{prog}"

  subproc.on 'exit', (status, signal) ->
    debug "EXIT"
    subproc = null


respawn = ->
  if not subproc?
    spawn()

  else
    if options.kill
      debug "TERM"
      subproc.kill 'SIGTERM'

    if options.Kill
      debug "KILL"
      subproc.kill 'SIGKILL'

    if options.parallel
      spawn()
    else
      debug "WAIT"
      subproc.on 'exit', spawn


@main = (argv) ->
  process.name = 'relo'

  options = cli.parse argv
  
  for path in options.watches
    try
      debug "WATCH #{path}"
      watch.watch path, respawn

    catch e
      console.error "Can't watch #{path}: #{e.code}"
      process.exit 1

  spawn()
