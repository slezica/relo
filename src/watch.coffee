# watch.coffee

# This module implements file-system watching, wrapping fs.watch() to provide
# event grouping: near-simultaneous events are reported in bulk.

# For now, the implementation is pretty basic: a 1 second timer reports events
# if there were any. The downside of this simplicity is that event groups are
# interrupted every time the timer ticks, which may be mere milliseconds after
# the first event in the chain.

fs = require 'fs'


REPORT_INTERVAL = 1000 # milliseconds


@watch = (path, callback) ->
  events_since_last_report = []

  report = ->
    if events_since_last_report.length is 0
      return

    callback events_since_last_report
    events_since_last_report = []


  fs.watch path, (event, filename) ->
    events_since_last_report.push {event, filename}


  setInterval report, REPORT_INTERVAL
