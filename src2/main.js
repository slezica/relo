import cli from './cli'
import watcher from './watcher'
import { Runner } from './runner'


export function main(argv) {
  const options = parseCli(argv)
  const runner = new Runner(options)

  process.name = 'relo'

  process.on('exit', (code, signal) => {
    runner.kill()
  })

  process.on('SIGINT', () => {
    runner.kill()
    process.exit()
  })

  watcher.start(options.watches, () => runner.respawn())
  runner.spawn()
}


function parseCli(argv) {
  try {
    return cli.parse(argv)

  } catch (ex) {
    console.error(ex.toString())
    cli.showHelp()
    process.exit(1)
  }
}