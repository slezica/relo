import fs from 'fs'
import yargs from 'yargs'

import { NoCommandGiven, NoWatchesGiven, InvalidSignalGiven } from './errors'

const SIGNALS = ['SIGHUP', 'SIGINT', 'SIGTERM', 'SIGKILL']


const cli = yargs
  .usage(`
    relo [file|dir]+ [-k|K] [-g] [-p] -- <command>+
    Rerun or reload program on file-system events
  `)

  .example("relo file1 file2 -- make all", "Rerun make")
  .example("relo -g dir/ -- runserver", "Kill and restart server")

  .help('help')
  .alias('help', 'h')
  .wrap(80)

  .options('signal', {
    alias   : 's',
    describe: "Signal to send on reload (default SIGINT)",
    default : 'SIGINT',
    nargs   : 1
  })

  .options('group', {
    alias   : 'g',
    describe: "Send signal to subprocess group",
    boolean : true
  })

  .options('wait', {
    alias   : 'w',
    describe: "Do not signal on reload, wait for subprocess to finish normally",
    boolean : true
  })

  .options('parallel', {
    alias   : 'p',
    describe: "Rerun command immediately, in parallel (with our without signal)",
    boolean : true
  })

  .strict() // no unknown flags accepted


// Little trick to show invocation errors *before* the help message:
cli.showHelp(help => cli.showHelpOnFail(false, help))


function parse(argv) {
  // Remove ['node', 'relo.js']
  argv = argv.slice(2)

  // A -- separates our arguments from the command. Find it:
  const separatorIndex = argv.indexOf('--')
  if (separatorIndex === -1) throw new NoCommandGiven()

  // Cut args from command:
  const args    = argv.slice(0, separatorIndex)
  const command = argv.slice(separatorIndex + 1)

  // Parse args and produce options:
  const options = cli.parse(args)
  
  options.command = command
  options.watches = options._
  options.signal  = options.signal.toUpperCase()

  if (options.command.length === 0) throw new NoCommandGiven()
  if (options.watches.length === 0) throw new NoWatchesGiven()
  if (! SIGNALS.includes(options.signal)) throw new InvalidSignalGiven(options.signal)

  return options
}


function showHelp() {
  cli.showHelp()
}


export default { parse, showHelp }