assert = require 'assert'
wrap = require '../../../lib/api/create/wrap'

describe 'test wrapping an ach file object', ->

  ach = # need just enough info to create the `data` object *and* calculate()
    file:
      origin: ' 553456789'
      destination: ' 987654321'
      originName: 'Some Company'
      destinationName: 'Some Bank'

    batches: [
      {
        #serviceClassCode: '200' # both
        entryClassCode: 'CCD'
        originatingDFIIdentification: 98765432
        entries: [
          {
            transactionCode: '22'
            receivingDFIIdentification: 13579246
            checkDigit: 8
            dfiAccount: 'account'
            amount: 12345
          }
          {
            transactionCode: '27'
            receivingDFIIdentification: 24681357
            checkDigit: 9
            dfiAccount: 'account2'
            amount: 12345
          }
        ]
      }
      {
        #serviceClassCode: '220' # credits only
        entryClassCode: 'PPD'
        originatingDFIIdentification: 98765432
        entries: [
          {
            transactionCode: '22'
            receivingDFIIdentification: 12341234
            checkDigit: 5
            dfiAccount: 'account3'
            amount:333
            addenda: 'some addenda'
          }
          {
            transactionCode: '22'
            receivingDFIIdentification: 56785678
            checkDigit: 9
            dfiAccount: 'account4'
            amount:4444
            addenda: 'some addenda'
          }
        ]
      }
      {
        #serviceClassCode: '225' # debits only
        entryClassCode: 'CCD'
        originatingDFIIdentification: 98765432
        entries: [
          {
            transactionCode: '27'
            receivingDFIIdentification: 43214321
            checkDigit: 0
            dfiAccount: 'account5'
            amount:55555
            addenda: 'some addenda'
          }
          {
            transactionCode: '27'
            receivingDFIIdentification: 98769876
            checkDigit: 5
            dfiAccount: 'account6'
            amount: 123456
            addenda: 'some addenda'
          }
        ]
      }
    ]

  next = wrap ach

  data = next.data
  object = next.object
  file = object.file

  describe 'returns appropriate next object', ->

    it 'should have object', -> assert next?.object?
    it 'should have data', -> assert next?.data?
    it 'should have ccd()', -> assert next?.ccd?
    it 'should have ppd()', -> assert next?.ppd?
    it 'should have ctx()', -> assert next?.ctx?
    it 'should have validate()', -> assert next?.validate?


  describe 'creates data object', ->

    it 'with from name', -> assert.equal data.from.name, 'Some Company'
    it 'with from FEIN (with prefix)', -> assert.equal data.from.fein, ' 553456789'
    it 'with for name', -> assert.equal data.for.name, 'Some Bank'
    it 'with for routing', -> assert.equal data.for.routing, '987654321'
    it 'with for DFI', -> assert.equal data.for.dfi, 98765432

  describe 'calculates file footer', ->

    it 'lineCount', -> assert.equal file.footer.lineCount, 18
    it 'blockCount', -> assert.equal file.footer.blockCount, 2
    it 'batch count', -> assert.equal file.footer.batchCount, 3
    it 'entry/addenda count', -> assert.equal file.footer.entryAndAddendaCount, 10
    it 'entry hash', -> assert.equal file.footer.entryHash, 249371712
    it 'total credit', -> assert.equal file.footer.totalCredit, 17122
    it 'total debit', -> assert.equal file.footer.totalDebit, 191356

  describe 'calculates batch values/footers', ->

    batches = object.batches
    batch1 = batches[0]
    batch2 = batches[1]
    batch3 = batches[2]

    it 'batch numbers', ->
      assert.equal batch1.num, 1
      assert.equal batch2.num, 2
      assert.equal batch3.num, 3

    it 'entryHash', ->
      assert.equal batch1.footer.entryHash, 38260603
      assert.equal batch2.footer.entryHash, 69126912
      assert.equal batch3.footer.entryHash, 141984197

    it 'entry/addenda count', ->
      assert.equal batch1.footer.entryAndAddendaCount, 2
      assert.equal batch2.footer.entryAndAddendaCount, 4
      assert.equal batch3.footer.entryAndAddendaCount, 4

    it 'total credit', ->
      assert.equal batch1.footer.totalCredit, 12345
      assert.equal batch2.footer.totalCredit, 4777
      assert.equal batch3.footer.totalCredit, 0

    it 'total debit', ->
      assert.equal batch1.footer.totalDebit, 12345
      assert.equal batch2.footer.totalDebit, 0
      assert.equal batch3.footer.totalDebit, 179011

    it 'service class code', ->

      assert.equal batch1.serviceClassCode, '200'
      assert.equal batch2.serviceClassCode, '220'
      assert.equal batch3.serviceClassCode, '225'

      assert.equal batch1.footer.serviceClassCode, '200'
      assert.equal batch2.footer.serviceClassCode, '220'
      assert.equal batch3.footer.serviceClassCode, '225'

  it 'calculates entry trace numbers', ->

    traceNumber1 = object.batches[0].entries[0].traceNumber
    traceNumber2 = object.batches[0].entries[1].traceNumber
    traceNumber3 = object.batches[1].entries[0].traceNumber
    traceNumber4 = object.batches[1].entries[1].traceNumber
    traceNumber5 = object.batches[2].entries[0].traceNumber
    traceNumber6 = object.batches[2].entries[1].traceNumber

    assert.equal traceNumber1, 987654320000001
    assert.equal traceNumber2, 987654320000002
    assert.equal traceNumber3, 987654320000003
    assert.equal traceNumber4, 987654320000004
    assert.equal traceNumber5, 987654320000005
    assert.equal traceNumber6, 987654320000006
