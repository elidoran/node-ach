
transforms = require './transforms'

# no options we care about yet...
module.exports = ach = (mainOptions) ->

  hasParser: (format) -> transforms.hasParser format
  hasFormatter: (format) -> transforms.hasFormatter format
  getParser: (format) -> transforms.getParser format
  getFormatter: (format) -> transforms.getFormatter format

  # accept a source stream/string/object providing ACH file info
  # return an object ready to accept a target stream/string to output the object
  from: require './api/from'
  # don't provide the 'to' here, have from() return an object with it

  # create a new object representing an ACH file and build it programmatically
  create: require './api/create'

  # wrap an existing object so we can apply API functions to edit it
  wrap: require './api/create/wrap'
