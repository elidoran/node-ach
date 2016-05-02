{ccd, ppd} = require './batch-ccd-ppd'
ctx = require './batch-ctx'
batch = require './batch'
validate = require '../validate'
calculate = require '../calculate'

# this accepts an object in the same format produced by the parser and by the
# gen api functions.
module.exports = wrap = (object) ->

  # first, the gen functions *expect* a `data` object in the context to pull
  # values from.
  # so, we have to create it from the supplied data...
  data =
    from:
      name: object.file.originName
      fein: object.file.origin

    for:
      name: object.file.destinationName
      routing: object.file.destination[1..]
      dfi: object.file.destination[1...-1]

  # run calculate() on the object to ensure its stuff is up to date
  calculate ach:object, set:true

  if object?.batches?.length > 0
    # get the last entry from the last batch
    entries = object.batches[object.batches.length - 1].entries

    if entries?.length > 0
      lastEntry = entries[entries.length - 1]

      # convert to a string so we can remove the front 8 characters
      traceString = ('' + lastEntry.traceNumber)[-7..]

      # convert to a number and add one. that's our 'entryCount'
      data.entryCount = (Number traceString) + 1

    else
      data.entryCount = 0

  else # set values for zero batches
    data.entryCount = 0

  next =
    data: data
    object: object
    ccd: ccd
    ppd: ppd
    ctx: ctx
    batch: batch

  next.validate = validate.bind next, object # only validates the storage object

  return next
