import cp from 'child_process'


export class Runner {
  constructor(options) {
    this.options = options
    this.process = null
  }

  spawn() {
    const program = this.options.command[0]
    const argv    = this.options.command.slice(1)
    const workdir = process.cwd()

    // if (! argv.length && program.search(' ') != -1) {
    //   [program, ...argv] = program.split(' ')
    // }

    // debug "Starting #{program}"
    this.process = this.createProcess(program, argv, workdir)

    this.process.stdout.on('data', data => process.stdout.write(data))
    this.process.stderr.on('data', data => process.stderr.write(data))

    this.process.on('exit', (status, signal) => {
      // debug "#{program} exited"
      this.process = null
    })
  }

  respawn() {
    if (! this.process) {
      this.spawn()
      return
    }

    if (! this.options.wait) {
      this.kill()
    }

    if (this.options.parallel) {
      this.spawn()
    } else {
      this.process.on('exit', () => this.spawn())
    }
  }

  kill() {
    if (! this.process) return
      
    if (this.options.group) {
      this.killGroup()
    } else {
      this.killSingle()
    }
  }

  killGroup() {
    // debug "Sending #{signal} to group #{-subproc.pid}"
    process.kill(-this.process.pid, this.options.signal)
  }

  killSingle() {
    // debug "Sending #{signal} to #{program}"
    this.process.kill(this.options.signal)
  }

  createProcess(program, argv, workdir) {
    return cp.spawn(program, argv, { cwd: workdir, detached: true })
  }
}
