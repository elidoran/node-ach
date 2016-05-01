strung      = require 'strung'
isStream    = require './is-stream'
isEftObject = require './is-eft-object'
transforms  = require '../transforms'
edit        = require './edit'
to          = require './to'

# setup a stream to transform from a source to an object
# default source is process.stdin
# default source format is 'ach'
module.exports = from = (options = {}) ->

  # shortcut: allow them to specify only the format as an option
  if 'string' is typeof options and transforms.getParser options
    options = format: options, source: process.stdin

  # shortcut: allow them to specify only the source stream as an option
  else if isStream options then options = format: 'ach', source: options

  # store all streams in an array in *reverse* order so the streams[0] stream is
  # the topmost stream, the *last* one to run, the one any listeners are added to.
  from = streams: []

  # inspect the source because it can be:
  #  1. string - so use a `strung` to create a Readable for the string
  #  2. stream - then use it as-is
  #  3. object - then create a Readable for the object. when it pipes, we write it...
  #  4. otherwise, use process.stdin

  if options?.source?

    from.streams.unshift source =

      if isStream options.source then options.source

      else if 'string' is typeof options.source then strung options.source

      else if isEftObject options.source then objectable options.source

      else process.stdin

  else from.streams.unshift process.stdin

  options.format ?= 'ach'

  transform = transforms.getParser options.format

  # if we didn't find the transform for the format then error
  unless transform?
    return errorProvider =
      error: 'invalid \'from\' format: ' + options.format
      # provide these so chained calls return this original error
      edit : -> return this
      to   : -> return this

  else from.streams.unshift transform

  return From =
    # bind them to the shared 'from' object which has the streams so far
    # (Note: we created `from` way up at the top)
    edit: edit.bind from
    to  : to.bind from
