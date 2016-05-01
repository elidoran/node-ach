fs     = require 'fs'
path   = require 'path'
assert = require 'assert'
strung = require 'strung'
Parser = require '../../../lib/transforms/ach-parser'

describe 'test parser', ->

  result = null
  solution = null

  before 'read test input and pass to parser', (done) ->

    filePath = path.join __dirname, '..', '..', 'helpers', 'input.ccd'
    fs.readFile filePath, {encoding:'utf8'}, (error, content) ->
      if error? then done error
      else
        source = strung content
        parser = new Parser()
        parser.on 'data', (object) ->
          result = object
          done()
        parser.on 'error', done
        source.pipe parser

  before 'read solution object', (done) ->

    filePath = path.join __dirname, '..', '..', 'helpers', 'solution.json'
    fs.readFile filePath, {encoding:'utf8'}, (error, content) ->
      if error? then done error
      else
        solution = JSON.parse content
        done()

  it 'should have a result', -> assert result, 'result must exist'

  it 'should have full object', -> assert.deepEqual result, solution
