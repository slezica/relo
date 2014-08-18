chokidar = require 'chokidar'


CALLBACK_INTERVAL = 1000 # milliseconds


@watch = (path, callback) ->
  events  = [] # accumulated events since last callback
  watcher = chokidar.watch path, ignoreInitial: true

  watcher.on 'all', (event, filename) ->
    events.push {event, filename}

  setInterval (->
    if events.length > 0
      callback events
      events = []

  ), CALLBACK_INTERVAL
