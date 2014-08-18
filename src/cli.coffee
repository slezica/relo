fs = require 'fs'


yargs = require 'yargs'
  .usage "
    redo [-k] [-p] [-w file|dir]+ <command...>
    Rerun command on file-system events
  "

  .example "$0 -w file make", "Rerun make"
  .example "$0 -w dir/ -k runserver", "Kill and restart server"
  .example "$0 -w file -w dir/ ...", "Multiple watches"

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

  .wrap 80
  .strict() # no unknown flags accepted


# Little trick to show invocation errors *before* the help message:
yargs.showHelp (help) ->
  yargs.showHelpOnFail false, help


# Now. To have yargs support our syntax (all arguments after the first non-flag
# non-flag-parameter are part of the command) we have to do some preprocessing.
# Namely, splitting the arguments into flags and command by hand, then giving
# yargs just the flags.

# To be the first command argument, an argument has to:
# 1. Not be a flag (begin with '-')
# 2. Not be after a flag that takes a parameter (maybe with flag grouping)

is_flag_or_parameter = (argv, i) ->
  arg  = argv[i]
  prev = argv[i - 1]

  if arg[0] is '-'
    return true

  if not prev? or prev[0] isnt '-'
    return false

  return prev is '--watch' or prev[1] isnt '-' and 'w' in prev


splitArgs = (argv) ->
  # Find first non-flag, non-flag-parameter argument and split args in two

  for arg, i in argv
    if not is_flag_or_parameter argv, i
      return [ argv[...i], argv[i..] ]

  [ argv, [] ]


ensureArray = (obj_or_array) ->
  if Array.isArray obj_or_array then obj_or_array else [obj_or_array]
  

@parse = (argv) ->
  [flags, command] = splitArgs argv[2..]

  if not command.length
    console.error "No command given\n"
    yargs.showHelp()
    process.exit 1

  options = yargs.parse flags

  options.command = command
  options.watches = ensureArray options.watch

  options