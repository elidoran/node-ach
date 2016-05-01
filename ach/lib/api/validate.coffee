formats = require '../transforms/formats'

validate = (object, format) ->

# TODO: really write this...
module.exports = (object) ->

  # object:
  #   file:
  #     footer
  #   batches[]:
  #     entries[]:
  #       entry
  #       'addenda' | addendas[]
  #     footer

  validate object?.file, formats.fileHeader
  validate object?.file?.footer, formats.fileFooter
  if object?.batches?.length > 0
    for batch in object.batches
      validate batch, formats.batchHeader
      # do we do a calculate before validating? or, are we validating calculations?
      # or, just validating the patterns of entries
      # we could run the calculation and then compare the result with what's in
      # the object... and conditionally replace it?
      validate batch?.footer, formats.batchFooter

# replace these with function which accept the value and validate them.
# that way, we can properly validate the date. this regex does it all except
# whether days 29-31 are correct.
# and, the routing stuff requires a special algorithm
validate.date = (value) -> false # /\d{6}/ # /(\d\d)(?:(0\d)|(1[012]))(?:(0[1-9])|([12]\d)|(3[01]))/
validate.time = (value) -> false # /\d{4}/
validate.aba         = (value) ->  false # /((\d{4})(\d{4}))/
validate.abaFull     = (value) -> false # /((\d{4})(\d{4}))(\d)/
validate.abaFullPlus = (value) -> false # /(\w)((\d{4})(\d{4}))(\d)/
validate.alphanumeric= /.*/
