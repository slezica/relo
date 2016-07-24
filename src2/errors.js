
class BaseError {
  constructor(...args) {
    this.message = this.fmtMessage(...args)
    this.name = this.constructor.name
    Error.captureStackTrace(this, this.constructor)
  }

  toString() {
    return this.message
  }
}


export class NoCommandGiven extends BaseError {
  fmtMessage() {
    return "No command was given to run"
  }
}


export class NoWatchesGiven extends BaseError {
  fmtMessage() {
    return "No files were given to watch"
  }
}


export class InvalidSignalGiven extends BaseError {
  fmtMessage(signal) {
    return `Invalid signal: ${signal} (must be SIGHUP, SIGINT, SIGTERM or SIGKILL)`
  }
}