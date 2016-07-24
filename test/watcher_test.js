import chai, { expect } from 'chai'

import sinon from 'sinon'
import sinonChai from 'sinon-chai'
chai.use(sinonChai)

import { mkdtempSync, openSync, closeSync, mkdirSync } from 'fs'
import touch from 'touch'
import rmRf from 'rimraf'

import watcher from '../src2/watcher'


describe("The file watcher", function() {
  this.timeout(5000)

  let temp

  beforeEach(function() {
    temp = mkdtempSync('./')

    mkdirSync(`${temp}/sub`)
    touch.sync(`${temp}/foo`)

    this.callback = sinon.spy()
    watcher.start(temp, this.callback)

    return sleep(100) // watcher has no 'ready' event
  })

  afterEach(function() {
    watcher.stop()
    rmRf.sync(temp)
  })

  it("should detect a changed file", function() {
    touch.sync(`${temp}/foo`)
    return wait().then(() => expect(this.callback).called)
  })

  it("should detect a new file", function() {
    touch.sync(`${temp}/newfoo`)
    return wait().then(() => expect(this.callback).called)
  })

  it("should detect a new directory", function() {
    mkdirSync(`${temp}/newsub`)
    return wait().then(() => expect(this.callback).called)
  })

  it("should detect changes inside new directories", function() {
    return this.skip() // NOT IMPLEMENTED YET

    mkdirSync(`${temp}/newsub`)
    touch.sync(`${temp}/newsub/newfoo`)
    return wait().then(() => expect(this.callback).calledTwice)
  })

  it("should detect events in subpaths", function() {
    touch.sync(`${temp}/sub/bar`)
    return wait().then(() => expect(this.callback).called)
  })

  it("should group near-simultaneous events", function() {
    touch.sync(`${temp}/foo`)
    touch.sync(`${temp}/sub/foo`)
    touch.sync(`${temp}/sub/bar`)
    return wait().then(() => expect(this.callback).calledOnce)
  })

  it("should not wait too much for events to settle", function() {
    this.timeout(2000)
    touch.sync(`${temp}/foo`)
    touch.sync(`${temp}/sub/bar`)
    
    return waitTooMuch()
      .then(() => touch.sync(`${temp}/sub/foo`))
      .then(wait)
      .then(() => expect(this.callback).calledTwice)
  })
})


function waitWatcher(watcher) {
  return sleep(200) // watcher has no ready event, but this should be enough
}

function wait() {
  return sleep(watcher.CALLBACK_WAIT_MS + 10)
}

function waitTooMuch() {
  return sleep(watcher.CALLBACK_WAIT_MAX_MS + 10)
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms))
}