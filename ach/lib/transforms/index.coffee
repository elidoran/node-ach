
# store transforms
transforms =
  parsers:
    ach : require './ach-parser'
    json: require './json-parser'
  formatters:
    ach : require './ach-formatter'
    json: require './json-formatter'

getTransform = (format, which) ->

  unless (format? and which?) then return

  format = format.toLowerCase()

  transform = transforms?[which]?[format]

  if transform? then new transform

  else # try to load it
    try
      otherModule = require '@ach/' + format # when globally installed, use absolute path
      transform = otherModule?[which]?[format]
      if transform?
        transforms[which][format] = transform
        return new transform
    catch error
      ; # ignore error, module doesn't exist.

setTransform = (format, transform, which) ->

  format = format?.toLowerCase?()

  if format? and transform? then transforms[which][format] = transform

  else return error =
    error: 'must specify both format and transform'
    format: format
    transform: transform

  return


# export an object with get/set functions
module.exports =

  getParser   : (format) -> getTransform format, 'parsers'
  getFormatter: (format) -> getTransform format, 'formatters'

  setParser   : (format, transform) -> setTransform format, transform, 'parsers'
  setFormatter: (format, transform) -> setTransform format, transform, 'formatters'

  parserFormats: -> Object.keys transforms.parsers
  formatterFormats: -> Object.keys transforms.formatters

  hasParser: (format) -> transforms.parsers[format]?
  hasFormatter: (format) -> transforms.formatters[format]?
