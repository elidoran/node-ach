isStream = require './is-stream'
transforms = require '../transforms'

module.exports = to = (options = {}) ->

  # @ is the from object which has `streams`, the streams, so far, in reverse order

  # GOAL:
  #  source -> sourceTransform -> objectTransform -> target
  #
  # may be no target stream, might be a listener on the last transform
  # may be no objectTransform, so sourceTransform pipes to target, or has a listener
  # may be no sourceTransform, so, source pipes to objectTransform instead
  # may be neither transform?? then they don't need us and should just do their own thing.

  # shortcut: allow them to specify only the format as an option
  if 'string' is typeof options
    options = format: options, target: process.stdout

  # shortcut: allow them to specify only the target stream as an option
  else if isStream options then options = format: 'ach', target: options

  # A. get values based on specified options

  # default target format is 'ach'
  options.format ?= 'ach'

  # 1. Get Object Transform
  # must have a valid format because invalid format causes error.
  if options?.format?

    objectTransform = transforms.getFormatter options.format

    if objectTransform?
      @streams.unshift objectTransform

    else
      return error: 'invalid \'to\' format: ' + options.format


  # 2. Get target stream, and use target listener (if it exists)
  # either we have 1. a listener; 2. a specified target stream; 3. stdout
  # if it's a function then we have a listener to use
  if 'function' is typeof options.target
    # if we're using a target format then we need to gather the string output
    if options.format?
      @streams.unshift strung()
      event = 'finish'

    # no target stream and no objectTransform, just listen on sourceTransform
    # or an edit transform, either way, they output a whole object to 'data'
    else event = 'data'

    streams[0].on event, listener

  # if the target is a stream then use it, else use stdout
  else @streams.unshift target =
    if isStream options.target then options.target else process.stdout


  # B. setup stream pipeline (listener already used)

  # TODO: must add an on-error listener to all the streams

  nextStream = @streams.pop()
  nextStream = nextStream.pipe @streams.pop() while @streams.length isnt 0

  return success:true
