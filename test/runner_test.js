import chai, { expect } from 'chai'

import sinon from 'sinon'
import sinonChai from 'sinon-chai'
chai.use(sinonChai)

import { mockRunnerClass } from './utils'


describe("The process Runner", function() {

  describe("#spawn", function() {
    const MockRunner = mockRunnerClass()

    it("should correctly call createProcess", function() {
      const runner = new MockRunner({ command: ['echo', 'foo bar', 'baz'] })
      runner.spawn()

      expect(runner.createProcess).calledWith('echo', ['foo bar', 'baz'], process.cwd())
    })

    it("should subscribe to EXIT, stdout and stderr", function() {
      const runner = new MockRunner()
      runner.spawn()

      expect(runner.process.on).calledWith('exit')
      expect(runner.process.stdout.on).calledWith('data')
      expect(runner.process.stderr.on).calledWith('data')
    })
  })


  describe("#respawn", function() {
    const MockRunner = mockRunnerClass('spawn', 'kill')
    
    it("should call spawn() if no process is running", function() {
      const runner = new MockRunner()
      runner.respawn()
      expect(runner.spawn).called
    })

    it("should call kill() depending on options.wait", function() {
      let runner

      runner = new MockRunner({ wait: true })
      runner.spawn()
      runner.respawn()
      expect(runner.kill).notCalled
      
      runner = new MockRunner({ wait: false })
      runner.spawn()
      runner.respawn()
      expect(runner.kill).called
    })

    it("should call or delay spawn() depending on options.parallel", function() {
      let runner

      runner = new MockRunner({ parallel: true })
      runner.spawn.resetHistory()
      runner.spawn()
      runner.respawn()
      expect(runner.spawn).calledTwice

      runner.spawn.resetHistory()
      
      runner = new MockRunner({ parallel: false })
      runner.spawn()
      runner.respawn()

      expect(runner.spawn).calledOnce
      expect(runner.process.on).calledTwice
      expect(runner.process.on.alwaysCalledWith('exit')).to.be.true
    })
  })


  describe("#kill", function() {
    const MockRunner = mockRunnerClass()

    it("should signal group or process depending on options.group", function() {
      let runner

      runner = new MockRunner({ group: true })
      runner.spawn()
      runner.kill()
      expect(runner.killGroup).called
      expect(runner.killSingle).notCalled

      runner.killGroup.resetHistory()
      runner.killSingle.resetHistory()

      runner = new MockRunner({ group: false })
      runner.spawn()
      runner.kill()
      expect(runner.killGroup).notCalled
      expect(runner.killSingle).called
    })
  })

})

