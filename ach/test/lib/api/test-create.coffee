assert = require 'assert'
create = require '../../../lib/api/create/create'

describe 'test creating an ach file object', ->

  fileData =
    from:
      name: 'Our Company'
      fein: ' 553456789' # no dash, is this the `id` with a preceeding char?
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
      #dfi: 12345678

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
        #dfi: 98765432

  context = create:create
  next = context.create fileData

  file   = next.object.file
  footer = file?.footer

  describe 'returns appropriate next object', ->

    it 'should have data', -> assert next?.data?
    it 'should have ccd()', -> assert next?.ccd?
    it 'should have ppd()', -> assert next?.ppd?
    # it 'should have ctx()', -> assert next?.ctx?
    it 'should have object', -> assert next?.object?
    it 'should have validate()', -> assert next?.validate?

  describe 'updates file data input', ->

    it 'with DFI values', ->
      assert.equal fileData.for.dfi, 12345678
      assert.equal fileData.to['some key for a target company'].dfi, 98765432

    it 'with starting entry count', -> assert.equal fileData.entryCount, 0

  describe 'creates file object', ->

    it 'with standard record type', -> assert.equal file.recordType, '1'
    it 'with standard priority', -> assert.equal file.priority, 1
    it 'with standard file ID modifier', -> assert.equal file.idModifier, 'A'
    it 'with standard record size', -> assert.equal file.recordSize, '094'
    it 'with standard blocking factor', -> assert.equal file.blockingFactor, '10'
    it 'with standard format code', -> assert.equal file.formatCode, '1'

    it 'with YYMMDD formated date', -> # close approximation...
      assert /\d\d((0[1-9])|(1[012]))((0[1-9])|([12]\d)|(3[01]))/.test file.creationDate

    it 'with HHMM formatted time', ->
      assert /(([01]\d)|(2[0123]))[0-5]\d/.test file.creationTime

    it 'with from company\'s FEIN ID (with a prefix) as origin', ->
      assert.equal file.origin, fileData.from.fein

    it 'with bank\'s routing number (with a prefix) as destination', ->
      assert.equal file.destination, ' ' + fileData.for.routing

    it 'with from company\'s name as origin name', ->
      assert.equal file.originName, fileData.from.name

    it 'with bank\'s name as destination name', ->
      assert.equal file.destinationName, fileData.for.name

  describe 'creates file footer', ->

    it 'with starter block count', ->
      assert.equal footer.blockCount, 2

    it 'with starter batch count', ->
      assert.equal footer.batchCount, 0

    it 'with starter entry/addenda count', ->
      assert.equal footer.entryAndAddendaCount, 0

    it 'with starter entryHash', ->
      assert.equal footer.entryHash, 0

    it 'with starter totalDebit', ->
      assert.equal footer.totalDebit, 0

    it 'with starter totalCredit', ->
      assert.equal footer.totalCredit, 0
