require('source-map-support').install()

fs    = require 'fs'
cp    = require 'child_process'
cli   = require './cli'
watch = require './watch'


options = cli.parseArgs()
subproc = null # will hold the ChildProcess object


spawn = ->
  prog = options.command[0]
  argv = options.command[1..]

  subproc = cp.spawn prog, argv,
    cwd  : process.cwd()
    stdio: 'inherit'

  subproc.on 'exit', (status, signal) ->
    subproc = null


respawn = ->
  if not subproc?
    spawn()

  else
    if options.kill
      subproc.kill()

    if options.Kill
      subproc.kill 'SIGKILL'

    if options.parallel
      spawn()
    else
      subproc.on 'exit', spawn


@main = ->
  for path in options.watches
    try
      watch.watch path, respawn

    catch e
      console.error "Can't watch #{path}: #{e.code}"
      process.exit 1