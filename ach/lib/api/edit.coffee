{Transform} = require 'stream'
path = require 'path'
to  = require './to'
ach = require '../../lib'

# array may contain:
#  1. file paths to scripts which export a Transform class
#  2. a Transform class
#  3. an instance of a Transform (or Transform compatible interface)
#  4. an object with implementation functions for Transform constructor
module.exports = edit = (editorsArray) ->

  for editorTransform in editorsArray
    try # try cuz require may fail

      # if it's a string, try to load the transform from the ref'd file
      if 'string' is typeof editorTransform

        # if it's a coffee file, try to load coffee-script
        if editorTransform.length > 7 and editorTransform[-7..] is '.coffee'
          require 'coffee-script'

        # unless it's an absolute path, use PWD/CWD
        if editorTransform[0] isnt '/' and editorTransform[0] isnt '\\'
          editorTransform = path.resolve editorTransform

        # load file, which is a transform class, create new one
        transform = new (require editorTransform) ach:ach

      # if it's a Transform class then create an instace of it
      else if editorTransform instaceof Transform
        transform = new editorTransform ach:ach

      # if it's a function for the new simplified constructor
      else if editorTransform.transform? and
        'function' is typeof editorTransform.transform
          # may have the flush() function as well, and other options
          transform = new Transform editorTransform

      # add to front of streams Q (it's in reverse order)
      # either the transform we created or the one provided
      @streams.unshift transform ? editorTransform

    catch error
      return errorProvider =
        error:'Unable to load edit transform:' + editorTransform
        Error: error # provide the Error object...
        to   : -> return errorProvider

  # bind to the same 'this' which has the streams array
  return to: to.bind this
