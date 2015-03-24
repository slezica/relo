fs = require 'fs'

SIGNALS = ['SIGHUP', 'SIGINT', 'SIGTERM', 'SIGKILL']


yargs = require 'yargs'
  .usage "
    relo [file|dir]+ [-k|K] [-g] [-p] -- <command>+\n
    Rerun or reload program on file-system events
  "

  .example "relo file1 file2 -- make all", "Rerun make"
  .example "relo -k dir/ -- runserver", "Kill and restart server"

  .help  'help'
  .alias 'help', 'h'
  .wrap 80

  .options 'signal',
    alias   : 's'
    describe: "Signal to send on reload (default: SIGINT)"
    default : 'SIGINT'
    nargs   : 1

  .options 'group',
    alias   : 'g'
    describe: "Send signal to subprocess group"
    boolean : true

  .options 'wait',
    alias   : 'w'
    describe: "Do not signal on reload, wait for subprocess to finish normally"
    boolean : true

  .options 'parallel',
    alias   : 'p'
    describe: "Rerun command immediately, in parallel (with our without signal)"
    boolean : true

  .strict() # no unknown flags accepted

  .check (argv) ->
    "No files watched" if argv._.length is 0

  .check (argv) ->
    if argv.signal.toUpperCase() not in SIGNALS
      "'#{argv.signal}' is not a valid signal"


# Little trick to show invocation errors *before* the help message:
yargs.showHelp (help) ->
  yargs.showHelpOnFail false, help


ensureArray = (obj_or_array) ->
  if Array.isArray obj_or_array then obj_or_array else [obj_or_array]
  


@parse = (argv) ->
  # Remove ['node', 'relo.js']
  argv = argv[2..]

  # A -- separates our arguments from the command. Find it:
  separator = argv.indexOf '--'

  if separator is -1
    yargs.showHelp()
    process.exit 1

  # Cut args from command:
  args    = argv[..separator - 1]
  command = argv[separator + 1..]

  # Parse args and produce options:
  options = yargs.parse args

  options.command = command
  options.watches = options._
  options.signal  = options.signal.toUpperCase()

  return options