
module.exports = class JsonParser extends require('stream').Transform

  constructor: () -> super objectMode:true

  _transform: (data, encoding, done) ->

    done null, JSON.parse data
