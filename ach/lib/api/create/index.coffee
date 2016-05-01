create = require './create'

# create a new ACH file object with the provided data
# returns an object containing the created object internally and providing
# functions to add more to it, such as batches/entries/addendas.
# Supports standard ACH file header/footer and batch/entry/addendas for:
#  1. CCD+
#  2. PPD+
#  3. [Not Yet] CTX+

module.exports = (data) ->

  # TODO: consider making this:  object = ach: create data
  #       then we'd do @ach.file and @ach.batches ...
  #       gives us room to set things into @ without being inside `@ach`
  create data # the ACH file info holder
