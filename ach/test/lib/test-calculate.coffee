assert    = require 'assert'
calculate = require '../../lib/api/calculate'

describe 'test calculate', ->

  describe 'with ...', ->

    ach =
      file:
        priority: 1
        immediateDestination: ' 123456789'
        immediateOrigin: '553456789'
        idModifier: 'A'
        recordSize: '094'
        blockingFactor: '10'
        formatCode:'1'
        destinationName: 'Some Bank'
      batches: [
        {
          serviceClassCode: '200'
          companyName: 'Some Company'
          discretionaryData: 'discretionary data'
          companyId: ' 123456789'
          entryClassCode: 'CCD'
          description: 'blah blah'
          date: '160804'
          effectiveDate: '160805'
          settlementDate: '   '
          originatorStatusCode: 1
          originatingDFIIdentification: '12345678'
          entries: [
            {
              transactionCode: '22', amount:12345, addendaIndicator:1
              receivingCompanyName:'Target Vendor', dfiAccount:'their acct#'
              receivingDFIIdentification:'98765432', checkDigit:1
              discretionaryData:'discretionary data'
              addenda: 'some addenda value'
            }
            {
              transactionCode: '22', amount:11335, addendaIndicator:1
              receivingCompanyName:'Target Vendor', dfiAccount:'their acct#'
              receivingDFIIdentification:'98765432', checkDigit:1
              discretionaryData:'discretionary data'
              addenda: 'some addenda value'
            }
            {
              transactionCode: '27', amount:12345 + 11335, addendaIndicator:0
              receivingCompanyName:'Some Company', dfiAccount:'our acct#'
              receivingDFIIdentification:'12345678', checkDigit:9
              discretionaryData:'discretionary data'
            }
          ]
        }
      ]


    # set the calculated footers into this object
    result = calculate ach:ach, set:true

    it 'should return a result object', ->
      assert result?.footer, 'result should have a `footer` property'
      assert result?.batchFooters, 'result should have a `batchFooters` property'

    it 'should count the entries and addendas for Batch', ->
      assert.equal result?.batchFooters?[0]?.entryAndAddendaCount, 3 + 2 # (entries + addenda)

    it 'should sum the credits for Batch', ->
      assert.equal result?.batchFooters?[0]?.totalCredit, 12345 + 11335

    it 'should sum the debits for Batch', ->
      assert.equal result?.batchFooters?[0]?.totalDebit, 12345 + 11335

    it 'should create an entry hash for Batch', ->
      assert.equal result?.batchFooters?[0]?.entryHash, (98765432 + 98765432 + 12345678)

    it 'should set a batch number for Batch', ->
      assert.equal ach?.batches?[0]?.num, 0
      assert.equal result?.batchFooters?[0]?.num, 0


    it 'should count the entries and addendas', ->
      assert.equal result?.footer?.entryAndAddendaCount, 3 + 2 # (entries + addenda)

    it 'should count the lines (block count)', ->
      assert.equal result?.footer?.blockCount, 9

    it 'should sum the credits', ->
      assert.equal result?.footer?.totalCredit, 12345 + 11335

    it 'should sum the debits', ->
      assert.equal result?.footer?.totalDebit, 12345 + 11335

    it 'should create an entry hash', ->
      assert.equal result?.footer?.entryHash, (98765432 + 98765432 + 12345678)



  describe 'file', ->

    describe 'with ...', ->

      ach =
        file:
          priority: 1
          immediateDestination: ' 123456789'
          immediateOrigin: '553456789'
          idModifier: 'A'
          recordSize: '094'
          blockingFactor: '10'
          formatCode:'1'
          destinationName: 'Some Bank'
        batches: [
          {
            serviceClassCode: '200'
            companyName: 'Some Company'
            discretionaryData: 'discretionary data'
            companyId: ' 123456789'
            entryClassCode: 'CCD'
            description: 'blah blah'
            date: '160804'
            effectiveDate: '160805'
            settlementDate: '   '
            originatorStatusCode: 1
            originatingDFIIdentification: '12345678'
            entries: [
              {
                transactionCode: '22', amount:12345, addendaIndicator:1
                receivingCompanyName:'Target Vendor', dfiAccount:'their acct#'
                receivingDFIIdentification:'98765432', checkDigit:1
                discretionaryData:'discretionary data'
                addenda: 'some addenda value'
              }
              {
                transactionCode: '22', amount:11335, addendaIndicator:1
                receivingCompanyName:'Target Vendor', dfiAccount:'their acct#'
                receivingDFIIdentification:'98765432', checkDigit:1
                discretionaryData:'discretionary data'
                addenda: 'some addenda value'
              }
              {
                transactionCode: '27', amount:12345 + 11335, addendaIndicator:0
                receivingCompanyName:'Some Company', dfiAccount:'our acct#'
                receivingDFIIdentification:'12345678', checkDigit:9
                discretionaryData:'discretionary data'
              }
            ]

            footer:
              entryAndAddendaCount: 5
              serviceClassCode: '200'
              companyId: ' 123456789'
              totalDebit: 23680
              totalCredit: 23680
              entryHash: 209876542
              originatingDFIIdentification: '12345678'
          }
        ]

      result = calculate.file ach:ach

      it 'should return a result object', ->
        assert result?.footer, 'result should have a `footer` property'

      it 'should count the entries and addendas', ->
        assert.equal result?.footer?.entryAndAddendaCount, 3 + 2 # (entries + addenda)

      it 'should count the lines (block count)', ->
        assert.equal result?.footer?.blockCount, 9

      it 'should sum the credits', ->
        assert.equal result?.footer?.totalCredit, 12345 + 11335

      it 'should sum the debits', ->
        assert.equal result?.footer?.totalDebit, 12345 + 11335

      it 'should create an entry hash', ->
        assert.equal result?.footer?.entryHash, (98765432 + 98765432 + 12345678)



  describe 'batch', ->


    describe 'with debits, credits, and addendas', ->

      batch =
        serviceClassCode: '200'
        companyName: 'Some Company'
        discretionaryData: 'discretionary data'
        companyId: ' 123456789'
        entryClassCode: 'CCD'
        description: 'blah blah'
        date: '160804'
        effectiveDate: '160805'
        settlementDate: '   '
        originatorStatusCode: 1
        originatingDFIIdentification: '12345678'
        entries: [
          {
            transactionCode: '22', amount:12345, addendaIndicator:1
            receivingCompanyName:'Target Vendor', dfiAccount:'their acct#'
            receivingDFIIdentification:'98765432', checkDigit:1
            discretionaryData:'discretionary data'
            addenda: 'some addenda value'
          }
          {
            transactionCode: '22', amount:11335, addendaIndicator:1
            receivingCompanyName:'Target Vendor', dfiAccount:'their acct#'
            receivingDFIIdentification:'98765432', checkDigit:1
            discretionaryData:'discretionary data'
            addenda: 'some addenda value'
          }
          {
            transactionCode: '27', amount:12345 + 11335, addendaIndicator:0
            receivingCompanyName:'Some Company', dfiAccount:'our acct#'
            receivingDFIIdentification:'12345678', checkDigit:9
            discretionaryData:'discretionary data'
          }
        ]

      result = calculate.batch batch:batch

      it 'should return a result object', ->
        assert result?.footer, 'result should have a `footer` property'

      it 'should count the entries and addendas', ->
        assert.equal result?.footer?.entryAndAddendaCount, 3 + 2 # (entries + addenda)

      it 'should sum the credits', ->
        assert.equal result?.footer?.totalCredit, 12345 + 11335

      it 'should sum the debits', ->
        assert.equal result?.footer?.totalDebit, 12345 + 11335

      it 'should create an entry hash', ->
        assert.equal result?.footer?.entryHash, (98765432 + 98765432 + 12345678)

      it 'should use values from header', ->
        assert.equal result?.footer?.serviceClassCode, batch.serviceClassCode
        assert.equal result?.footer?.companyId, batch.companyId
        assert.equal result?.footer?.originatingDFIIdentification, batch.originatingDFIIdentification
