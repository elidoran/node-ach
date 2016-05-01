{EachPart}  = require 'each-part'
lineParsers = require './line-parsers'

# we want to use some transforms *ahead* of this transform.
# so, we'll listen to the 'pipe' event to handle it.
insertTransform = (source) ->

  # if this is the source we want then return
  if source instanceof EachPart then return

  # unpipe this because we're going to give it a different one
  source.unpipe this

  # pipe it to a new transform and then to this
  eacher = new EachPart delim:'\n'

  source.pipe(eacher).pipe this

module.exports = class AchParser extends require('stream').Transform

  constructor: () ->
    super objectMode:true

    @on 'pipe', insertTransform.bind this
    @ach = {}

  _transform: (data, encoding, done) ->

    # TODO:
    #  consider using a state machine to control which parsing is being done.
    #  move from state to state based on the first character and the
    #  batch's entryClassCode.

    # TODO:
    #  instead of maintaining long lists of fields and lengths i could use a
    #  regular expression for each type of line, and, even a multi-line grouping
    #  (which would require gathering lines which go together)
    #  enhance it with the named groups so it analyzes a line and produces an
    #  object with named keys for the matched values.
    #
    #  and, validating an entire line is easy with a regex...would need to
    #  define each line validator as a function using the regex so it can do
    #  spot checks, like the date, because that is super difficult with regex
    #  (well, for days 29-31). tho, i bet someone *has* a regex which handles
    #  the vast majority of it...)

    # get the line from the data result provided by the each-part stream
    line = data.string

    # if there's no data, or, if it's a line starting with two 9's, then we're done
    if line.length is 0 or (line[0] is '9' and line[1] is '9') then return done()

    # if there is a line parser for the first character of the line then call it
    lineParsers?[line[0]]? line, @ach

    # if the line begins with a '9' then push the object and start a new one
    if line[0] is '9' and @ach?
      @push @ach
      @ach = {}

    done()
