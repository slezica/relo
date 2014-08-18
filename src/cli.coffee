fs = require 'fs'


yargs = require 'yargs'
  .usage "
    redo [-w file|dir]+ [-k] [-p] -- <command>+\n
    Rerun command on file-system events
  "

  .example "$0 -w file -- make all", "Rerun make"
  .example "$0 -w dir/ -k -- runserver", "Kill and restart server"
  .example "$0 -w file -w dir/ -- cmd", "Multiple watches"

  .help  'help'
  .alias 'help', 'h'
  .wrap 80

  .options 'watch',
    alias      : 'w'
    describe   : "Watch given file or directory"
    requiresArg: true
    string     : true
    demand     : true

  .options 'kill',
    alias   : 'k'
    describe: "Terminate previous process before redoing (waits by default)"
    boolean : true

  .options 'Kill',
    alias   : 'K'
    describe: "Like -k, but use SIGKILL"
    boolean : true

  .options 'parallel',
    alias   : 'p'
    describe: "Redo command immediately, in parallel (waits by default)"
    boolean : true

  .strict() # no unknown flags accepted
  .check (argv) ->
    "Place command arguments after a --" if argv._.length isnt 0


# Little trick to show invocation errors *before* the help message:
yargs.showHelp (help) ->
  yargs.showHelpOnFail false, help


ensureArray = (obj_or_array) ->
  if Array.isArray obj_or_array then obj_or_array else [obj_or_array]
  


@parse = (argv) ->
  # Remove ['node', 'redo.js']
  argv = argv[2..]

  # A -- separates our flags from the command. Find it:
  separator = argv.indexOf '--'

  if separator is -1
    yargs.showHelp()
    process.exit 1

  # Cut flags from command:
  flags   = argv[..separator - 1]
  command = argv[separator + 1..]

  # Parse flags and produce options:
  options = yargs.parse flags

  options.command = command
  options.watches = ensureArray options.watch

  options