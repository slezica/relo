import sinon from 'sinon'

import { Runner } from '../src/runner'


export function mockRunnerClass(...spyList) {
  class MockRunner extends Runner {
    constructor(options) {
      options = Object.assign({ command: [] }, options)
      super(options)
    }
  }

  Object.assign(MockRunner.prototype, {
    // Spy and stub interaction with the OS process:
    killSingle   : sinon.spy(),
    killGroup    : sinon.spy(),
    createProcess: sinon.spy(() => new MockProcess())
  })

  for (let spyName of spyList) {
    // Spy these functions too, but preserve their functionality:
    sinon.spy(MockRunner.prototype, spyName)
  }
  
  return MockRunner
}


class MockProcess {
  constructor() {
    this.on = sinon.spy()
    this.stdout = { on: sinon.spy() }
    this.stderr = { on: sinon.spy() }
  }
} 


