assert = require 'assert'
{ccd, ppd} = require '../../../lib/api/create/batch-ccd-ppd'

baseContext = ->
  context =
    ccd: ccd
    ppd: ppd

    object: # the `ach` object
      file:
        footer:
          lineCount: 2
          blockCount: 1
          batchCount: 0
          entryAndAddendaCount: 0
          entryHash: 0
          totalDebit: 0
          totalCredit: 0

      batches: []

    data:
      from:
        name: 'Our Company'
        fein: ' 553456789' # no dash, is this the `id` with a preceeding char?
        account:
          num: '12345'
          type: 'C'
        # OR: could make an `accouts: {}` store by account number to ref diff ones...
        accounts:
          12345: # the account number as an ID
            num: '123545' # our bank account number with the bank
            type: 'C' # C - checking, S - Savings

      for:
        name: 'Our Bank' # they receive the file
        routing: '123456789' # the routing number for the bank
        # implied from `routing` by dropping the check digit
        dfi: 12345678

      to:
        'some key for a target company':
          key: 'some key for a target company'
          name: 'Target Company'
          id: ' 123456789' # 9-digit FEIN without dash, preceeded by something
          account:
            num: 'sd98d882h32hfhds' # their bank account number
            type: 'C' # C - checking, S - Savings
          routing: '987654321' # their bank routing number
          # implied from `routing` by dropping check digit
          dfi: 98765432


describe 'test creating a ccd batch', ->

  context = baseContext()

  batchData =
    date: 'Mar 30'
    effectiveDate: '991231'
    description: 'Payment'
    note: 'the discretionary data' # optional

  next = context.ccd batchData

  file  = context.object.file
  batch = context.object.batches[0]

  describe 'returns appropriate next object', ->

    it 'should have credit()', -> assert next?.credit?
    it 'should have debit()', -> assert next?.debit?
    it 'should have object', -> assert next?.object?
    it 'should have validate()', -> assert next?.validate?

  describe 'changing the file footer', ->

    it 'should change line count', -> assert.equal file.footer.lineCount, 4
    it 'should NOT change block count', -> assert.equal file.footer.blockCount, 1
    it 'should change batch count', -> assert.equal file.footer.batchCount, 1
    it 'should NOT change entry/addenda count', -> assert.equal file.footer.entryAndAddendaCount, 0
    it 'should NOT change entryHash', -> assert.equal file.footer.entryHash, 0
    it 'should NOT change totalDebit', -> assert.equal file.footer.totalDebit, 0
    it 'should NOT change totalCredit', -> assert.equal file.footer.totalCredit, 0

  describe 'creates footer', ->

    batchFooter = batch?.footer ? {}

    it 'without serviceClassCode', ->
      assert.equal batch.serviceClassCode, null


    it 'without settlement date', ->
      assert.equal batch.settlementDate, null


    it 'with company ID from header', ->
      assert.equal batchFooter.companyId, context.data.from.fein
      assert.equal batchFooter.companyId, batch.companyId,
        'batch and batchFooter should have same companyId'

    it 'with bank\'s DFI', ->
      assert.equal batchFooter.originatingDFIIdentification, context.data.for.dfi
      assert.equal batchFooter.originatingDFIIdentification, batch.originatingDFIIdentification,
        'batch and batchFooter should have same bank DFI'

    it 'with same batch number as header', ->
      assert.equal batchFooter.num, 1

    it 'should NOT change entry/addenda count', ->
      assert.equal batchFooter.entryAndAddendaCount, 0

    it 'should NOT change entryHash', ->
      assert.equal batchFooter.entryHash, 0

    it 'should NOT change totalDebit', ->
      assert.equal batchFooter.totalDebit, 0

    it 'should NOT change totalCredit', ->
      assert.equal batchFooter.totalCredit, 0

  it 'into batches array', -> assert batch

  it 'should have record type 5', ->
    assert.equal batch.recordType, 5

  it 'should NOT have serviceClassCode yet', ->
    assert.equal batch.serviceClassCode, null

  it 'should NOT have settlement date yet', ->
    assert.equal batch.settlementDate, null

  it 'should have standard originator status code', ->
    assert.equal batch.originatorStatusCode, '1'

  it 'should have CCD entry code', ->
    assert.equal batch.entryClassCode, 'CCD'

  it 'should use the from company\'s name', ->
    assert.equal batch.companyName, context.data.from.name

  it 'should use the from company\'s FEIN as ID', ->
    assert.equal batch.companyId, context.data.from.fein

  it 'should use the `for` bank\'s DFI', ->
    assert.equal batch.originatingDFIIdentification, context.data.for.dfi

  it 'should use date', ->
    assert.equal batch.date, batchData.date

  it 'should use effective date', ->
    assert.equal batch.effectiveDate, batchData.effectiveDate

  it 'should use description', ->
    assert.equal batch.description, batchData.description

  it 'should use note', ->
    assert.equal batch.discretionaryData, batchData.note

  it 'should set batch number', ->
    assert.equal batch.num, 1
