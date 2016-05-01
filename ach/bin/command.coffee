# # # # # # # # #
#  ach command  #
# # # # # # # # #

# what config stuff would i use in the 'eft' cli ?
# 1. which sub-modules to enable?
# 2. which formats are the default
# 3. which values in an ACH file are the defaults...
# 4. default values for the 'ach gen' interactive mode
#
# optionValues = require('nuc') id:'eft', defaults:require './defaults'
# ach = require('../lib') optionValues

ach = require('../lib')()

# options:
#  -v --version     : show name+version and exit
#  -i --input from  : input format, default is ACH
#  -o --output to   : output format, default is ACH
#  -e --edit edit   : a transform to edit the object

# the whole "report the version" thing
if process.argv[2] in [ '-v', '--version' ]
  pkg = require '../package.json'
  console.log pkg.name, pkg.version
  process.exit 0

# hold the settings from args
inFormat  = null
outFormat = null
editTransforms = []

# loop over the args (ignore executable and script name)
for i in [2...process.argv.length]

  arg = process.argv[i]

  # when we use a later arg, set it to null so it gets ignored here
  unless arg? then continue

  switch arg

    # the input specifiers
    when '-i', '--input', 'from'
      if i < process.argv.length
        inFormat = process.argv[i + 1]
        # in case the extra arg we just grabbed isn't the right kind
        if inFormat[0] is '-' then ; # TODO: error cuz it's not the right arg
        # null it so it gets ignored
        process.argv[i + 1] = null
      else
        # TODO: error cuz there's no input format arg

    # the output specifiers
    when '-o', '--output', 'to'
      if i < process.argv.length
        outFormat = process.argv[i + 1]
        # in case the extra arg we just grabbed isn't the right kind
        if outFormat[0] is '-' then ; # TODO: error cuz it's not the right arg
        # null it so it gets ignored
        process.argv[i + 1] = null
      else
        # TODO: error cuz there's no output format arg

    when '-e', '--edit', 'edit'
      if i < process.argv.length and process.argv[i + 1] isnt '-'
        # store it in an array so there can be more than one
        editTransforms.push process.argv[i + 1]
        # null it so it gets ignored
        process.argv[i + 1] = null
      else
        # TODO: error cuz there's no edit script arg

    # TODO: implement the interactive console...
    when 'gen' then interactive = true

    # ignore these
    when 'coffee', 'node', 'with', 'and' then ;

    else
      if arg[0] is '-' then ; # TODO: error? not a valid arg
      # NOTE: this requires the path to start with a dot or slash *only* when
      #       they didn't precede the arg with 'edit' or '-e' or '--edit'
      else if arg[0] is '.' or arg[0] is '/' then editTransforms.push arg
      # TODO: could do some advanced checks to see if the arg is really an edit arg
      else unless inFormat? and ach.getParser(arg)? then inFormat = arg
      else unless outFormat? and ach.getFormatter(arg)? then outFormat = arg
      else editTransforms.push arg

# if 'interactive' then use an interactive mode to generate an EFT object and
# then output it to a file in a chosen format
if interactive
  console.log 'haven\'t coded the interactive version yet'
else
  # dont need to specify formats, they default to 'ach'
  # dont need to specify streams, they default to stdin/stdout
  # if none of those are specified then there should at least be an edit script
  # or else this won't accomplish anything.
  started = ach.from(inFormat).edit(editTransforms).to(outFormat)
  if started?.error? then console.error started.error
  # else console.log started
  # if started?.Error? then console.error started.Error
