formats = require './formats'

zeroes = '0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
spaces = '                                                                                              '
nines  = '9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999\n'

padNum = (num = '', size) ->
  string = num.toString()
  diff = size - string.length
  if diff > 0
    string = zeroes[...diff] + string
  else if diff < 0
    string = string[-size...]
  return string

padString = (string = '', size) ->
  diff = size - string.length
  if diff > 0
    string += spaces[...diff]
  else if diff < 0
    string = string[...size]
  return string

outputFields = (source, format, push) ->

    i = 0
    for field in format.fields
      value = source[field.name]
      pad = if field.numeric then padNum else padString
      value = pad value, field.length
      push value

    push '\n'


module.exports = class AchFormatter extends require('stream').Transform

  constructor: () ->
    super
      readableObjectMode: false
      writableObjectMode: true

    @on 'error', console.log.bind console

  _transform: (ach, _, done) ->

    # basically, calculated values should be there for a parsed file.
    # and, should already be there for an object generated with the API functions
    # and, if they wrap a object from outside our stuff via the wrap() API function
    # then we calculate it all right then to bring it up to speed, and then
    # API functions maintain that. so, basically, we assume it already has those
    # values once it reaches this formatter...

    push = @push.bind this

    outputFields ach.file, formats.fileHeader, push

    for batch in ach.batches
      outputFields batch, formats.batchHeader, push

      format = formats[batch.entryClassCode]

      for entry in batch.entries
        outputFields entry, format.entry, push

        if entry.addenda?
          outputFields entry.addenda, format.addenda, push

        else if entry.addendas?
          for addenda in entry.addendas
            outputFields addenda format.addenda, push

      outputFields batch.footer, formats.batchFooter, push

    # line count is the number of lines in the entire file.
    # block count is how many "blocks" of ten lines there are, with padding.
    outputFields ach.file.footer, formats.fileFooter, push

    # must have multiples of 10 for line count because blocking factor is always 10
    linesNeeded = 10 - (ach.file.footer.lineCount % 10)
    @push nines for i in [1..linesNeeded]

    done()
