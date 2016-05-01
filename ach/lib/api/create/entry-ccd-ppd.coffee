validate = require '../validate'

getTransactionCode = (transactionType, accountType, isPrenote) ->
  # first character is based on account type
  code = if accountType is 'S' then '3' else '2' # C - checking, S - savings
  # next character is based on transaction type
  nextCode = if transactionType is 'D' then 7 else 2 # D - Debit, C - Credit
  # if it's a prenote, then the second character is one higher
  code += if isPrenote then (nextCode + 1) else nextCode

# ach.create(data).ccd(batchData).entry(entryData)
createEntry = (whichKind, entryData) ->

  # alias the object
  ach = @object
  batch = ach.batches[ach.batches.length - 1]

  # the 'to' may be in entryData or, it may reference it in @data.to
  toCompany =
    # if we have a string, it's the key to reference it in @data.to
    if 'string' is typeof entryData.to then @data.to[entryData.to]
    # it should be the actual `to` object instead
    else entryData.to

  entry =
    # defaults
    recordType: '6'

    # values from data
    receivingDFIIdentification: toCompany.dfi
    checkDigit: toCompany.routing[8] # 9th digit
    dfiAccount: toCompany.account.num
    amount: entryData.amount
    receivingCompanyName: toCompany.name
    addendaIndicator: if entryData.addenda? then '1' else '0'
    traceNumber: @data.for.dfi + ('000000' + @data.entryCount)[-7..]

  entry.discretionaryData = entryData.note if entryData.note?

  # create addenda, if available
  if entryData.addenda?
    entry.addenda =
      # defaults
      recordType: '7'
      type: '05'
      num: 0
      entryNum: @data.entryCount
      # only one value from data
      info: entryData.addenda

  # increment the entry count
  @data.entryCount++

  # use the trio of info to get the two digit transaction code
  accountType = toCompany.account.type
  entry.transactionCode = getTransactionCode whichKind, accountType, entryData.prenote

  # set/alter the batch's serviceClassCode now that we know a transaction code
  # TODO: possible to clean this up??
  # it basically sets the code based on the current entry type
  # if it's already been set from a previous entry, then it'll change to 'both'
  # if this new entry is the opposite kind from a previous entry
  if whichKind is 'C' # credit
    switch batch.serviceClassCode
      when '200' then ; # do nothing, it's good
      when '225'
        batch.serviceClassCode = batch.footer.serviceClassCode = '200' # it's now both
      else
        batch.serviceClassCode = batch.footer.serviceClassCode = '220' # credits only
  else # if whichKind is 'D' # debit
    switch batch.serviceClassCode
      when '200' then ; # do nothing, it's good
      when '220'
        batch.serviceClassCode = batch.footer.serviceClassCode = '200' # it's now both
      else
        batch.serviceClassCode = batch.footer.serviceClassCode = '225' # debits only

  # update batch/file footers

  batch.footer.entryHash    += entry.receivingDFIIdentification
  ach.file.footer.entryHash += entry.receivingDFIIdentification

  if whichKind is 'C'
    batch.footer.totalCredit    += entry.amount
    ach.file.footer.totalCredit += entry.amount
  else
    batch.footer.totalDebit    += entry.amount
    ach.file.footer.totalDebit += entry.amount

  if entry.addenda?
    batch.footer.entryAndAddendaCount += 2
    ach.file.footer.entryAndAddendaCount += 2
    ach.file.footer.blockCount += 2
  else
    batch.footer.entryAndAddendaCount += 1
    ach.file.footer.entryAndAddendaCount += 1
    ach.file.footer.blockCount += 1

  # store the entry/addenda in the batch
  batch.entries.push entry

  # after a credit/debit entry, provide functions to start a new batch:
  {ccd, ppd} = require './batch-ccd-ppd' # mutual dependency, so, do this here
  # ctx = require './batch-ctx'
  @ccd = ccd
  @ppd = ppd
  # @ctx = ctx

  return this

module.exports =
  credit: (entryData) -> createEntry.call this, 'C', entryData
  debit : (entryData) -> createEntry.call this, 'D', entryData
