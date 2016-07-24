
class BaseError {
  constructor() {
    this.message = this.constructor.name
    this.name = this.constructor.name
    Error.captureStackTrace(this, this.constructor)
  }

  toString() {
    return this.message
  }
}


export class NoCommandGiven extends BaseError {}

export class NoWatchesGiven extends BaseError {}

export class InvalidSignalGiven extends BaseError {
  constructor(signal) {
    super()
    this.signal = signal
    this.message = `InvalidSignalGiven: ${signal}`
  }
}