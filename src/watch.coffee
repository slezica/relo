debug    = require('debug') 'relo:watcher'
chokidar = require 'chokidar'


CALLBACK_INTERVAL = 1000 # milliseconds


@watch = (path, callback) ->
  debug "Watching #{path}"

  events  = [] # accumulated events since last callback
  watcher = chokidar.watch path, ignoreInitial: true

  watcher.on 'all', (event, filename) ->
    events.push {event, filename}

  watcher.on 'error', (err) ->
    console.error "Error watching #{path}:", err
    process.exit 1

  setInterval (->
    if events.length > 0
      callback events
      events = []

  ), CALLBACK_INTERVAL
