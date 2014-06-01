configJson = require '../../proxmate.json'

class Config
  config: {}
  init: ->
    @config = configJson

  ###*
   * Return config content for key 'key'
   * @param  {String} key the key
   * @return {Mixed}     Whatever is written in the config
  ###
  get: (key) ->
    return @config[key]

exports.Config = new Config()
