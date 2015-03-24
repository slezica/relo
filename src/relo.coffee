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
    cwd     : process.cwd()
    stdio   : 'inherit'
    detached: true

  debug "Started #{program}"

  subproc.on 'exit', (status, signal) ->
    debug "#{program} exited"
    subproc = null


kill = (signal = options.signal) ->
  if options.group
    debug "Sending #{signal} to group #{-subproc.pid}"
    process.kill -subproc.pid, signal

  else
    debug "Sending #{signal} to #{program}"
    subproc.kill signal


respawn = ->
  if not subproc?
    spawn()

  else
    kill() unless options.wait

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

  process.on 'exit', (code, signal) ->
    if subproc then kill()

  process.on 'SIGINT', ->
    if subproc then kill()
    process.exit()