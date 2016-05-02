{credit, debit} = require './entry-ccd-ppd'
validate = require '../validate'
{toYYMMDD} = require '../../dates'

tomorrowDate = ->
  today = new Date
  tomorrow = today.setDate today.getDate() + 1
  return tomorrow

toDate = (dateOrString) ->
  if 'string' is typeof dateOrString then return dateOrString
  return toYYMMDD dateOrString

# ach.create(data).ccd(batchData)
createBatch = (whichKind, batchData) ->

  # add to @data for later use
  @data.batchData = batchData

  # alias the object
  ach = @object

  batch =
    # defaults
    recordType: '5'
    originatorStatusCode: '1' # 'originator status code'
    num: ach.batches.length + 1
    entryClassCode: whichKind

    # values from `data`
    companyName   : @data.from.name
    companyId     : @data.from.fein
    originatingDFIIdentification: @data.for.dfi
    effectiveDate: toDate batchData.effectiveDate ? tomorrowDate()
    description: batchData.description

    # serviceClassCode: leave null until we add an entry...
    # settlementDate is left blank

    entries: []

    footer:
      recordType: '8'
      # serviceClassCode: leave null until we add an entry...
      companyId: @data.from.fein
      originatingDFIIdentification: @data.for.dfi
      num: ach.batches.length + 1

      # starter values
      entryAndAddendaCount: 0
      entryHash: 0
      totalDebit: 0
      totalCredit: 0

  batch.date = batchData.date if batchData.date?
  note = batchData.discretionaryData ? batchData.note
  batch.discretionaryData = note if note?

  ach.batches.push batch

  # update file footer
  ach.file.footer.batchCount++
  ach.file.footer.lineCount += 2 # 1 for batch header, 1 for batch footer
  ach.file.footer.blockCount = Math.ceil ach.file.footer.lineCount / 10

  return next = # next step is to add entries
    credit: credit
    debit : debit
    data  : @data
    object: ach
    validate: validate.bind ach, ach

module.exports =
  ccd: (batchData) -> createBatch.call this, 'CCD', batchData
  ppd: (batchData) -> createBatch.call this, 'PPD', batchData
