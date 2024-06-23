// debug    = require('debug') 'relo:watcher'
import chokidar from 'chokidar'
import debounce from 'lodash.debounce'


export const CALLBACK_WAIT_MS = 200
export const CALLBACK_WAIT_MAX_MS = 1000

let watcher


function start(paths, callback) {
  // debug "Watching #{paths}"
  if (watcher) stop()

  const notifyEvents = wrapCallback(callback)
  const notifyError = (error) => callback(error)

  watcher = chokidar.watch(paths, { ignoreInitial: true })

  watcher.on('all', notifyEvents)
  watcher.on('error', notifyError)
}


function stop() {
  if (watcher) {
    watcher.close()
    watcher = null
  }
}


export default { start, stop, CALLBACK_WAIT_MS, CALLBACK_WAIT_MAX_MS }


function wrapCallback(callback) {
  // `chokidar` will report every event separately, but we'd like to invoke
  // our `callback` only when file changes have "settled".

  // We'll notify our listener after `CALLBACK_WAIT_MS` have passed with no new
  // events being reported, but never wait more than `CALLBACK_WAIT_MAX_MS`: if
  // it takes too long, we'll just have to risk invoking `callback` multiple
  // times.

  // Note that we don't pass event info to `callback`. Just knowing that
  // something happened is enough for now.
  const onEvent = (event, path) => {
    callback(null)
  }

  return debounce(onEvent, CALLBACK_WAIT_MS, {
    leading : false,
    trailing: true,
    maxWait : CALLBACK_WAIT_MAX_MS
  })
}