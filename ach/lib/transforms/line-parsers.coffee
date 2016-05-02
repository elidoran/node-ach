formats = require './formats'

# grabs fields from a line based on the format and sets them into the target
extractFields = (line, format, target) ->

  i = 0
  for field in format.fields

    end = i + field.length
    value = line[i...end]
    value = value.trim() unless field.trim is false
    i = end
    if field.numeric then value = Number value
    target[field.name] = value

noop = ->

module.exports =

  1: (line, ach) -> # file header

    ach.file = {}
    ach.batches = []
    extractFields line, formats.fileHeader, ach.file
    return

  5: (line, ach) -> # batch header

    batch = entries:[]
    ach.batches ?= []
    ach.batches.push batch
    extractFields line, formats.batchHeader, batch
    return

  6: (line, ach) -> # batch entry

    batch = ach.batches[ach.batches.length - 1]
    entry = {}
    batch.entries ?= []
    batch.entries.push entry
    extractFields line, formats[batch.entryClassCode].entry, entry
    return

  7: (line, ach) -> # entry addenda

    batch = ach.batches[ach.batches.length - 1]
    entry = batch.entries[batch.entries.length - 1]
    addenda = {}
    if batch.entryClassCode is 'CTX'
      # if CTX addendas have 2 lines per info, then, we'd need to check
      # if this is the second line, and then read that format instead...
      entry.addendas ?= []
      entry.addendas.push addenda
    else
      entry.addenda = addenda
    extractFields line, formats[batch.entryClassCode].addenda, addenda
    return

  8: (line, ach) -> # batch footer/trailer/control

    batch = ach.batches[ach.batches.length - 1]
    batch.footer = {}
    extractFields line, formats.batchFooter, batch.footer
    return

  9: (line, ach) -> # file footer/trailer/control

    if line?[1] is '9' then return

    ach.file.footer = {}
    extractFields line, formats.fileFooter, ach.file.footer
    return

  # do nothing and return
  ' ' : noop
  '\n': noop
