assert = require 'assert'
ach =
  batch: require '../../../lib/api/create/batch'
  wrap : require '../../../lib/api/create/wrap'

describe 'test batch()', ->

  describe 'with unknown batch', ->

    result = null
    file = null

    object =
      file:
        origin: ' 553456789'
        destination: ' 987654321'
        originName: 'Some Company'
        destinationName: 'Some Bank'
      batches: []


    before 'wrap object', -> file = ach.wrap object

    before 'call with negative index', -> result = file.batch -1

    it 'should return undefined', -> assert.strictEqual result, undefined



  describe 'with a batch with no entries', ->

    result = null
    file = null

    object =
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
          entries: []
        }
      ]


    before 'wrap object', -> file = ach.wrap object

    before 'call with index 0', -> result = file.batch 0

    it 'should return entry making context', ->
      assert result?.credit, 'should have credit()'
      assert result?.debit, 'should have debit()'



  describe 'with known batch with entries', ->

    result = null
    file = null

    object =
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
      ]


    before 'wrap object', -> file = ach.wrap object

    before 'call with index 0', -> result = file.batch 0

    it 'should return entry making context', ->
      assert result?.credit, 'should have credit()'
      assert result?.debit, 'should have debit()'



  describe 'with known batches with entries', ->

    result = null
    file = null

    object =
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
      ]


    before 'wrap object', -> file = ach.wrap object

    before 'call with index 1', -> result = file.batch 1

    it 'should return entry making context', ->
      assert result?.credit, 'should have credit()'
      assert result?.debit, 'should have debit()'
