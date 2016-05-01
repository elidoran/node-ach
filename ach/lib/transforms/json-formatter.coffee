
module.exports = class JsonFormatter extends require('stream').Transform

  constructor: () ->
    super
      readableObjectMode: false
      writableObjectMode: true

  _transform: (data, encoding, done) ->

    done null, JSON.stringify data, null, 2 # prettified
