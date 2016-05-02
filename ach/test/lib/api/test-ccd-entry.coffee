assert = require 'assert'
{credit, debit} = require '../../../lib/api/create/entry-ccd-ppd'

baseContext = ->
  context =
    credit: credit
    debit : debit

    object: # the `ach` object
      file:
        footer:
          lineCount: 4
          blockCount: 1
          batchCount: 1
          entryAndAddendaCount: 0
          entryHash: 0
          totalDebit: 0
          totalCredit: 0

      batches: [
        {
          num: 1
          entries: []
          footer:
            entryAndAddendaCount: 0
            entryHash: 0
            totalDebit: 0
            totalCredit: 0
            num: 1
        }
      ]

    data:
      entryCount: 1
      from:
        name: 'Our Company'
        fein: '553456789' # no dash, is this the `id` with a preceeding char?
        # account:
        #   num: '12345'
        #   type: 'C'
        # # OR: could make an `accouts: {}` store by account number to ref diff ones...
        # accounts:
        #   12345: # the account number as an ID
        #     num: '123545' # our bank account number with the bank
        #     type: 'C' # C - checking, S - Savings

      for:
        name: 'Our Bank' # they receive the file
        routing: '123456789' # the routing number for the bank
        # implied from `routing` by dropping the check digit
        dfi: 12345678

      to:
        'some key for a target company':
          key: 'some key for a target company'
          name: 'Target Company'
          account:
            num: 'sd98d882h32hfhds' # their bank account number
            type: 'C' # C - checking, S - Savings
          routing: '987654321' # their bank routing number
          # implied from `routing` by dropping check digit
          dfi: 98765432


describe 'test creating a ccd entry', ->

  describe 'credit', ->

    context = baseContext()

    entryData =
      to: 'some key for a target company'
      amount: 12345
      addenda: 'some addenda info'
      note: 'blah'

    context.credit entryData

    file  = context.object.file
    batch = context.object.batches[0]
    entry = batch.entries[0]

    describe 'changing the file', ->

      it 'to have a line count of 6', ->
        assert.equal file.footer.lineCount, 6

      it 'to have a block count of 1', ->
        assert.equal file.footer.blockCount, 1

      it 'to have an entryAndAddendaCount of 2', ->
        assert.equal file.footer.entryAndAddendaCount, 2

      it 'to have the totalCredit', ->
        assert.equal file.footer.totalCredit, 12345

      it 'should still have a zero totalDebit', ->
        assert.equal file.footer.totalDebit, 0

      it 'to have a proper entryHash', ->
        assert.equal file.footer.entryHash, 98765432


    describe 'changing the batch', ->

      it 'to have the serviceClassCode set to credit only', ->
        # 200 = both, 220 = credit, 225 = debit
        assert.equal batch.serviceClassCode, '220'
        assert.equal batch.footer.serviceClassCode, '220'

      it 'to have an entryAndAddendaCount of 2', ->
        assert.equal batch.footer.entryAndAddendaCount, 2

      it 'to have the totalCredit', ->
        assert.equal batch.footer.totalCredit, 12345

      it 'should still have a zero totalDebit', ->
        assert.equal batch.footer.totalDebit, 0

      it 'to have a proper entryHash', ->
        assert.equal batch.footer.entryHash, 98765432


    it 'should have correct record type', ->
      assert.equal entry.recordType, '6'

    it 'should have correct transaction code', ->
      assert.equal entry.transactionCode, 22

    it 'should have the target DFI', ->
      assert.equal entry.receivingDFIIdentification, '98765432'

    it 'should have the target DFI check digit', ->
      assert.equal entry.checkDigit, 1

    it 'should have the target DFI account number', ->
      assert.equal entry.dfiAccount, 'sd98d882h32hfhds'

    it 'should have correct amount', -> assert.equal entry.amount, 12345

    it 'should have correct receiving company name', ->
      assert.equal entry.receivingCompanyName, 'Target Company'

    it 'should have correct discretionary data', ->
      assert.equal entry.discretionaryData, 'blah'

    it 'should have correct addenda indicator', ->
      assert.equal entry.addendaIndicator, 1

    it 'should have correct trace number', ->
      assert.equal entry.traceNumber, 123456780000001

    it 'should have correct addenda record type', -> assert.equal entry.addenda.recordType, '7'

    it 'should have correct addenda type', -> assert.equal entry.addenda.type, '05'

    it 'should have correct addenda info', -> assert.equal entry.addenda.info, 'some addenda info'

    it 'should have correct addenda num', -> assert.equal entry.addenda.num, 1

    it 'should have correct addenda entryNum', -> assert.equal entry.addenda.entryNum, 1




  describe 'debit', ->

    context = baseContext()

    entryData =
      to: 'some key for a target company'
      amount: 12345
      addenda: 'some addenda info'
      note: 'blah'

    context.debit entryData

    file  = context.object.file
    batch = context.object.batches[0]
    entry = batch.entries[0]

    describe 'changing the file', ->

      it 'to have a line count of 6', ->
        assert.equal file.footer.lineCount, 6

      it 'to have a block count of 1', ->
        assert.equal file.footer.blockCount, 1

      it 'to have an entryAndAddendaCount of 2', ->
        assert.equal file.footer.entryAndAddendaCount, 2

      it 'to have the totalCredit', ->
        assert.equal file.footer.totalCredit, 0

      it 'should still have a zero totalDebit', ->
        assert.equal file.footer.totalDebit, 12345

      it 'to have a proper entryHash', ->
        assert.equal file.footer.entryHash, 98765432


    describe 'changing the batch', ->

      it 'to have the serviceClassCode set to credit only', ->
        # 200 = both, 220 = credit, 225 = debit
        assert.equal batch.serviceClassCode, '225'
        assert.equal batch.footer.serviceClassCode, '225'

      it 'to have an entryAndAddendaCount of 2', ->
        assert.equal batch.footer.entryAndAddendaCount, 2

      it 'to have the totalCredit', ->
        assert.equal batch.footer.totalCredit, 0

      it 'should still have a zero totalDebit', ->
        assert.equal batch.footer.totalDebit, 12345

      it 'to have a proper entryHash', ->
        assert.equal batch.footer.entryHash, 98765432


    it 'should have correct record type', ->
      assert.equal entry.recordType, '6'

    it 'should have correct transaction code', ->
      assert.equal entry.transactionCode, 27

    it 'should have the target DFI', ->
      assert.equal entry.receivingDFIIdentification, '98765432'

    it 'should have the target DFI check digit', ->
      assert.equal entry.checkDigit, 1

    it 'should have the target DFI account number', ->
      assert.equal entry.dfiAccount, 'sd98d882h32hfhds'

    it 'should have correct amount', -> assert.equal entry.amount, 12345

    it 'should have correct receiving company name', ->
      assert.equal entry.receivingCompanyName, 'Target Company'

    it 'should have correct discretionary data', ->
      assert.equal entry.discretionaryData, 'blah'

    it 'should have correct addenda indicator', ->
      assert.equal entry.addendaIndicator, 1

    it 'should have correct trace number', ->
      assert.equal entry.traceNumber, 123456780000001

    it 'should have correct addenda record type', -> assert.equal entry.addenda.recordType, '7'

    it 'should have correct addenda type', -> assert.equal entry.addenda.type, '05'

    it 'should have correct addenda info', -> assert.equal entry.addenda.info, 'some addenda info'

    it 'should have correct addenda num', -> assert.equal entry.addenda.num, 1

    it 'should have correct addenda entryNum', -> assert.equal entry.addenda.entryNum, 1




  describe 'credit and debit', ->

    context = baseContext()

    creditData =
      to: 'some key for a target company'
      amount: 12345
      addenda: 'some addenda info'
      note: 'blah'
      prenote:true

    debitData =
      to:
        name: 'Company Two'
        routing: '135792468'
        dfi: 13579246
        account:
          num: 'blah blah'
          type: 'S'
      amount: 12345
      addenda: 'some addenda info2'
      note: 'blah2'

    context.credit creditData
    context.debit debitData

    file  = context.object.file
    batch = context.object.batches[0]
    creditEntry = batch.entries[0]
    debitEntry = batch.entries[1]

    describe 'changing the file', ->

      it 'to have a line count of 8', ->
        assert.equal file.footer.lineCount, 8

      it 'to have a block count of 1', ->
        assert.equal file.footer.blockCount, 1

      it 'to have an entryAndAddendaCount of 4', ->
        assert.equal file.footer.entryAndAddendaCount, 4

      it 'to have the totalCredit', ->
        assert.equal file.footer.totalCredit, 12345

      it 'should still have a zero totalDebit', ->
        assert.equal file.footer.totalDebit, 12345

      it 'to have a proper entryHash', ->
        assert.equal file.footer.entryHash, 112344678


    describe 'changing the batch', ->

      it 'to have the serviceClassCode set to credit only', ->
        # 200 = both, 220 = credit, 225 = debit
        assert.equal batch.serviceClassCode, '200'
        assert.equal batch.footer.serviceClassCode, '200'

      it 'to have an entryAndAddendaCount', ->
        assert.equal batch.footer.entryAndAddendaCount, 4

      it 'to have the totalCredit', ->
        assert.equal batch.footer.totalCredit, 12345

      it 'should still have a zero totalDebit', ->
        assert.equal batch.footer.totalDebit, 12345

      it 'to have a proper entryHash', ->
        assert.equal batch.footer.entryHash, 112344678


    describe 'the credit', ->

      it 'should have correct record type', ->
        assert.equal creditEntry.recordType, '6'

      it 'should have correct transaction code', ->
        assert.equal creditEntry.transactionCode, 23

      it 'should have the target DFI', ->
        assert.equal creditEntry.receivingDFIIdentification, 98765432

      it 'should have the target DFI check digit', ->
        assert.equal creditEntry.checkDigit, 1

      it 'should have the target DFI account number', ->
        assert.equal creditEntry.dfiAccount, 'sd98d882h32hfhds'

      it 'should have correct amount', -> assert.equal creditEntry.amount, 12345

      it 'should have correct receiving company name', ->
        assert.equal creditEntry.receivingCompanyName, 'Target Company'

      it 'should have correct discretionary data', ->
        assert.equal creditEntry.discretionaryData, 'blah'

      it 'should have correct addenda indicator', ->
        assert.equal creditEntry.addendaIndicator, 1

      it 'should have correct trace number', ->
        assert.equal creditEntry.traceNumber, 123456780000001

      it 'should have correct addenda record type', -> assert.equal creditEntry.addenda.recordType, '7'

      it 'should have correct addenda type', -> assert.equal creditEntry.addenda.type, '05'

      it 'should have correct addenda info', -> assert.equal creditEntry.addenda.info, 'some addenda info'

      it 'should have correct addenda num', -> assert.equal creditEntry.addenda.num, 1

      it 'should have correct addenda entryNum', -> assert.equal creditEntry.addenda.entryNum, 1


    describe 'the debit', ->

      it 'should have correct record type', ->
        assert.equal debitEntry.recordType, '6'

      it 'should have correct transaction code', ->
        assert.equal debitEntry.transactionCode, 37

      it 'should have the target DFI', ->
        assert.equal debitEntry.receivingDFIIdentification, '13579246'

      it 'should have the target DFI check digit', ->
        assert.equal debitEntry.checkDigit, 8

      it 'should have the target DFI account number', ->
        assert.equal debitEntry.dfiAccount, 'blah blah'

      it 'should have correct amount', -> assert.equal debitEntry.amount, 12345

      it 'should have correct receiving company name', ->
        assert.equal debitEntry.receivingCompanyName, 'Company Two'

      it 'should have correct discretionary data', ->
        assert.equal debitEntry.discretionaryData, 'blah2'

      it 'should have correct addenda indicator', ->
        assert.equal debitEntry.addendaIndicator, 1

      it 'should have correct trace number', ->
        assert.equal debitEntry.traceNumber, 123456780000002

      it 'should have correct addenda record type', -> assert.equal debitEntry.addenda.recordType, '7'

      it 'should have correct addenda type', -> assert.equal debitEntry.addenda.type, '05'

      it 'should have correct addenda info', -> assert.equal debitEntry.addenda.info, 'some addenda info2'

      it 'should have correct addenda num', -> assert.equal debitEntry.addenda.num, 1

      it 'should have correct addenda debitEntryNum', -> assert.equal debitEntry.addenda.entryNum, 2
