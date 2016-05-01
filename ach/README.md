# NACHA ACH CCD+/PPD+ Formatter/Parser
[![Build Status](https://travis-ci.org/elidoran/node-ach.svg?branch=master)](https://travis-ci.org/elidoran/node-ach)
[![Dependency Status](https://gemnasium.com/badges/github.com/elidoran/node-ach.svg)](https://gemnasium.com/github.com/elidoran/node-ach)
[![npm version](https://badge.fury.io/js/%40ach%2Fach.svg)](https://badge.fury.io/js/%40ach%2Fach)

Parses and formats NACHA ACH standard CCD+/PPD+ bank transaction files.

## Install Options

### Install CLI

    npm install -g @ach/ach

### Install Library

    npm install @ach/ach --save

# Table of Contents

1. [Install Options](#install-options)
    1. [Install CLI](#install-cli)
    2. [Install Library](#install-library)
2. [Use CLI](#use-cli)
3. [Use API](#use-api)
    1. [create()](#api-create)
    2. [wrap()](#api-wrap)
    3. [Using from().edit().to()](#using-fromeditto)
    4. [from()](#api-from)
    5. [edit()](#api-edit)
    6. [to()](#api-to)
    7. [Examples](#api-examples)
4. [Future Plans](#future-plans)
    1. [Additional Output Formats](#additional-output-formats)
    2. [Additional Bank Formats](#additional-bank-formats)

## Use CLI

* Provide input to stdin and get output from stdout.
* Both input and output formats default to 'ACH' when not provided.
* Provide one or more transform scripts use in between parsing and formatting

```sh
# these are all the same
# ach is both the CLI name and the default format
ach from ach to ach and edit with some.js
ach from ach to ach edit with some.js      # no 'and'
ach from ach to ach edit some.js           # no 'with'
ach from ach to ach some.js                # no 'edit'
ach to ach some.js                         # no 'from ach'
ach from ach some.js                       # or, no 'to ach'
ach some.js                                # only the edit script

# short options
ach -i ach -o ach -e some.js

# long options
ach --input ach --output ach --edit some.js

# can input or output an ach file object in JSON
# read an ACH file and output it as JSON
ach to json
# read a JSON file and output it as ACH
ach from json

# read a file as ACH, send it thru another transform, and output as ACH
ach edit some-transform.js

# provide the content with OS specific commands to pipe it in and out
cat file.ach | ach to json > file.json
cat file.json | ach from json > file.ach
```

Note: when more formats are added all this will look better :)

[Back to: Table of Contents](#table-of-contents)


## Use API

`ach` has three main functions to start with

1. create() - used to generate an ACH file object with a series of calls
2. wrap() - wraps an already built ACH file object to be used with create()'s API
3. from() - used to start specifying a stream pipeline to parse/format

[Back to: Table of Contents](#table-of-contents)


### API: create()

```coffeescript
ach = require('@ach/ach')

# this shows chained functions, but, you can hold the returns in a variable to reuse
achFile = ach.create
  from: # the company generating the ACH file
    name: 'Your Company'
    # company tax ID. If the "predetermined char" isn't in front then
    # a space is prepended
    fein: '123456789'

  for: # the bank the ACH file is being sent to
    name: 'Our Bank' # they receive the file
    routing: '123456789' # the routing number for the bank, with check digit

  .ccd # a batch using CCD format
    effectiveDate: '991231' # format: YYMMDD
    description: 'Payment'  # or, Payroll, or whatever
    # optional values
    note: 'the "discretionary data"'
    date: 'Mar 30'

  .credit # send money to another company
    name: 'Target Company'    # company receiving the money
    account:                  # their bank account info
      num: '135792468'
      type: 'C'               # C - checking (default), S - Savings
    routing: '987654321'      # their bank's routing number
    amount: 12345             # amount in cents
    # optional. CCD/PPD allows a single 'addenda' with an 80 character block
    addenda: 'some addenda 80 chars long'

  .credit # send money to another company
    name: 'Another Company'   # company receiving the money
    account:                  # their bank account info
      num: '159260'
      type: 'C'               # C - checking (default), S - Savings
    routing: '987654321'      # their bank's routing number
    amount: 13579             # amount in cents

  .debit # take that money from your company
    name: 'Your Company'      # your company sending the money
    account:                  # your bank account info
      num: '135792468'
      type: 'C'               # C - checking (default), S - Savings
    routing: '987654321'      # their bank's routing number
    amount: 25924             # amount in cents
    # optional. CCD/PPD allows a single 80 character 'addenda'
    addenda: 'some addenda 80 chars long'

  # same with a PPD batch.
  # .ppd # a batch using PPD format
  #   effectiveDate: '991231' # format: YYMMDD
  #   description: 'Payroll'
  #   # optional values
  #   note: 'Some Employee'
  #   date: 'Mar 30'

# then you can send it to a stream or get it as a string.
# 1. stream
ach.from(achFile).to process.stdout
ach.from(achFile).to someFileStream

# 2. string
ach.from(achFile).to (string) -> console.log 'ACH File:\n', string
```

[Back to: Table of Contents](#table-of-contents)

## API: wrap()

```coffeescript
ach = require '@ach/ach'
achObject = getSomeAchObjectSomehow()

ach.wrap achObject
  # then use the same API functions provided by ach.create()
  .ccd {}
  .credit {}
  .debit {}

# the `achObject` has all changes made by function calls
```

[Back to: Table of Contents](#table-of-contents)

## Using from().edit().to()

The goal is to setup a pipeline of stream transforms which parse an input stream, optionally edit the parsed object, then format the object back into a string and output it.

There are variations to use an object as the source as well as provide the result as a string or object.

These are used by the ach CLI.

An example pipeline:

1. a file reader as the 'source' stream
2. 'ach' format stream parser (transform) which converts the file to an ACH object
3. optionally, some editing transform provided by user which receives the object, edits it, and passes it on
4. 'ach' format stream formatter (writer) which converts the object to a string
5. the final writer, maybe a file writer

[Back to: Table of Contents](#table-of-contents)

### API: from()

Valid arguments:

1. a string representing the input format
2. a string as the source of content
3. a Readable stream as the source of content
4. an object with two optional properties

The object (#4) can have:

* format - the name of the input format. currently only 'ach' and 'json' are available
* source - the input source may be:
    * stream - any Readable object, or process.stdin (the default)
    * string - string content must be in a format compatible with a known parser
    * object - an ACH object to send into the pipeline

[Back to: Table of Contents](#table-of-contents)

### API: edit()

Valid argument for `edit()` is an array. Array elements must be:

  1. string - a path, relative to the current working directory, to a JavaScript or CoffeeScript file
  2. a Transform class
  3. an instance of a Transform
  4. an object with implementation functions for Transform constructor

[Back to: Table of Contents](#table-of-contents)

### API: to()

Valid arguments:

1. a string representing the output format
2. a writable stream
3. an object with two optional properties

The object (#3) can have:

* format - the name of the output format. currently only 'ach' and 'json' are available
* target - the output target may be:
    * stream - a Writable object, or process.stdout (the default)
    * function - a listener to receive either the object or string. If a format is specified then the listener receives a string in that format. Without a specified format it receives the ACH object.

[Back to: Table of Contents](#table-of-contents)

### API Examples

```coffeescript
# specify everything, the longest style:
input  = source: process.stdin, format: 'ach'
output = target: process.stdout, format: 'ach'
ach.from(input).to output
# Note: the above are all defaults and can be left out.

# the `source` and `target` properties can be: streams, strings, an ACH object
# specify only a format by specifying it as a string
ach.from('json').to()
ach.from().to 'json'

# specify the source content as a string:
someString = getAchObjectAsString()
ach.from(someString).to 'json'
# Note: it knows to do this because someString isn't a valid format

# input from a file reader
inputFile = fs.createReadStream 'some-file.ach', encoding:'utf8'
ach.from(inputFile).to(whatever)


# basic trio  
ach.from('ach').edit(updateFileHeader).to 'json'
```

[Back to: Table of Contents](#table-of-contents)

## Future Plans


### Additional Output Formats

[Back to: Table of Contents](#table-of-contents)

1. 'english' - a human readable format
1. JSON
2. YAML
3. XML


### Additional Bank Formats

[Back to: Table of Contents](#table-of-contents)

There are many more formats in the NACHA ACH standards.

1. CTX - This is very similar to CCD/PPD. It allows many addendas using EDI X12 820 format.
2. IAT - International
3. ... there's more

[Back to: Table of Contents](#table-of-contents)

## MIT License
