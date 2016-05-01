validate = require '../validate'

# ach.batch(4)
module.exports = (index) ->

  # get the batch
  batch = @object.batches[index]

  # bail if it doesn't exist
  unless batch? then return

  # choose an entry module based on the batch's type
  module =
    switch batch.entryClassCode
      when 'CCD', 'PPD' then './entry-ccd-ppd'
      when 'CTX'        then './entry-ctx'

  # extract the two entry creating functions from the module
  {credit, debit} = require module

  # build the context to return
  next =
    # add them to our new context
    credit: credit
    debit : debit
    data  : @data
    object: @object
    validate: validate.bind this, @object

  return next
