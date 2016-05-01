fs     = require 'fs'
path   = require 'path'
assert = require 'assert'
strung = require 'strung'
Formatter = require '../../../lib/transforms/ach-formatter'

describe 'test formatter', ->

  result = null
  solution = null
  results = null
  # i'm using `solutions.length` to generate some 'it' calls, but, we don't
  # have solutions in this scope. so, i'm hard coding it with the answer
  # when 'solution.ccd' is changed, this value needs to be changed.
  solutions = length:21 # (empty line saved at the end, should be 20 really)

  before 'read test input and pass to formatter', (done) ->

    filePath = path.join __dirname, '..', '..', 'helpers', 'input.json'
    fs.readFile filePath, {encoding:'utf8'}, (error, content) ->
      if error? then done error
      else
        object = JSON.parse content
        formatter = new Formatter()
        target = strung()

        target.on 'finish', ->
          result = target.string
          done()

        target.on 'error', done

        formatter.pipe target
        formatter.end object

  before 'read solution object', (done) ->

    filePath = path.join __dirname, '..', '..', 'helpers', 'solution.ccd'
    fs.readFile filePath, {encoding:'utf8'}, (error, content) ->
      if error? then done error
      else
        solution = content
        done()

  before 'split values into individual lines', (done) ->
    results   = result.split '\n'
    solutions = solution.split '\n'
    done()

  it 'should have a result', ->

    assert result, 'result must exist'

  it 'should have the same number of lines', ->

    assert.equal results.length, solutions.length

  for i in [0...solutions.length]
    do (i) -> it "line #{i} should match", -> assert.equal results[i], solutions[i]
