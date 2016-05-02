
module.exports = calculate = (options) ->

  # store calculations to return. (in case options.set isnt true)
  results = footer:{}, batchFooters:[]

  options.seq = entry:1

  # first, do the batches
  for batch,i in options.ach.batches
    options.batch = batch
    result = calculate.batch options
    results.batchFooters.push result.footer

  # then do the overall file
  result = calculate.file options
  results.footer = result.footer

  return results

calculate.file = (options) ->

  # calculate the file's footer based on its contents
  file = options.ach.file
  footer =
    recordType: '9'
    batchCount: 0
    # lineCount: 0 # we'll calculate both these below
    # blockCount: 0
    entryAndAddendaCount: 0
    totalDebit: 0
    totalCredit: 0
    entryHash: 0

  # iterate over batches and sum up its stuff
  for batch,batchIndex in options.ach.batches
    batchFooter = batch.footer
    footer.batchCount++
    footer.entryHash            += batchFooter.entryHash
    footer.entryAndAddendaCount += batchFooter.entryAndAddendaCount
    footer.totalDebit           += batchFooter.totalDebit
    footer.totalCredit          += batchFooter.totalCredit
    if options.set
      batch.num = batchFooter.num = batchIndex + 1

  # file header/footer is 2, then header/footer for each batch, then each entry/addenda
  # length is 6, so, must not be longer than that.
  # lineCount is the number of lines we have. (10 - (lineCount % 10)) is the extra lines we need
  footer.lineCount = (2 + (footer.batchCount * 2) + footer.entryAndAddendaCount)
  # blockCount is the (lineCount / 10) rounded up
  footer.blockCount = Number "#{Math.ceil footer.lineCount / 10}"[-6..]

  # entryHash is limited to 10 characters, so, convert to string and truncate
  # by grabbing the last 10 characters
  footer.entryHash = Number "#{footer.entryHash}"[-10..]

  # if the options specify it, then set the results into file.footer
  if options.set then file.footer = footer

  # return the calculated footer
  return footer:footer

calculate.batch = (options) ->

  # calculate the batch's footer based on its entries
  batch = options.batch
  footer =
    recordType: '8'
    entryAndAddendaCount: 0
    totalDebit: 0
    totalCredit: 0
    entryHash: 0
    # from the header..
    companyId: batch.companyId
    serviceClassCode: batch.serviceClassCode
    originatingDFIIdentification: batch.originatingDFIIdentification

  # iterate over its entries and sum up its stuff
  for entry in batch.entries

    footer.entryHash += Number entry.receivingDFIIdentification

    footer.entryAndAddendaCount +=
      if entry.addenda? then 2

      else if entry.addendas? then entry.addendas.length + 1

      else 1

    switch entry.transactionCode[1]
      when '7', '8'
        footer.totalDebit  += entry.amount

        unless batch.serviceClassCode?
          batch.serviceClassCode = footer.serviceClassCode = '225'

        else if batch.serviceClassCode is '220'
          batch.serviceClassCode = footer.serviceClassCode = '200'

      when '2', '3'
        footer.totalCredit += entry.amount

        unless batch.serviceClassCode?
          batch.serviceClassCode = footer.serviceClassCode = '220'

        else if batch.serviceClassCode is '225'
          batch.serviceClassCode = footer.serviceClassCode = '200'

    # use entry count to specify the entry's trace number tail
    # could split this field into two fields so the second part will
    # automatically be padded with zeroes...
    if options.set and options.seq?.entry? and not entry.traceNumber?
      sequence = ('0000000' + options.seq.entry)[-7..]
      entry.traceNumber = batch.originatingDFIIdentification + sequence
    options?.seq?.entry++

    # if entry.addenda?
    #   if options.set then entry.addenda.sequenceNumber = 0 # default already?
    # else
    if options.set and entry.addendas?.length > 0
      addenda.sequenceNumber = i for addenda,i in entry.addendas

  # entryHash is limited to 10 characters, so, convert to string and truncate
  # by grabbing the last 10 characters
  footer.entryHash = Number "#{footer.entryHash}"[-10..]

  # if the options specify it, then set the results into batch.footer
  if options.set then batch.footer = footer

  # return the calculated footer
  return footer:footer
