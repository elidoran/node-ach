{ccd, ppd} = require './batch-ccd-ppd'
ctx = require './batch-ctx'
validate = require '../validate'
{toYYMMDD, toHHMM} = require '../../dates'

# ach.create fileData
module.exports = (data) ->

  # create implied values from data:
  data.for.dfi ?= data.for.routing[...-1] # strip the check digit

  # do the same for the accounts
  account.dfi = account.routing[...-1] for key,account of data.to

  # ensure the FEIN has the weird extra character in front
  if data.from.fein.length is 9 then data.from.fein = ' ' + data.from.fein

  # start counting entries
  data.entryCount = 1

  # for the date/time we created this ACH
  now = new Date

  # create an object to hold the ACH info
  ach =
    file:
      # defaults
      recordType: '1'
      priority: data.priority ? 1       # allow them to override
      idModifier: data.idModifier ? 'A' # allow them to override
      recordSize: '094'
      blockingFactor: '10'
      formatCode: '1'
      creationDate: toYYMMDD now
      creationTime: toHHMM now

      # values from `data`
      origin         : data.from.fein # with the weird space or letter in front
      destination    : ' ' + data.for.routing # space followed by routing
      originName     : data.from.name # our name
      destinationName: data.for.name # bank's name

      footer: # starter values:
        recordType: '9'
        lineCount: 2  # one for the file header, second for file footer
        blockCount: 1 # 10 lines is one block ...
        batchCount: 0
        entryAndAddendaCount: 0
        entryHash: 0
        totalDebit: 0
        totalCredit: 0

    batches:[]

  # return the `next` context which has functions to operate on the object more
  next =
    data: data
    object: ach
    ccd: ccd
    ppd: ppd
    # ctx: ctx
    validate: validate.bind this, ach # only validates the storage object

  return next
