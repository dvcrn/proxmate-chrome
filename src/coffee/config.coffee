define ['text!../../proxmate.json'], (configJson) ->
  config = {}
  init = ->
    config = JSON.parse(configJson)

  ###*
   * Return config content for key 'key'
   * @param  {String} key the key
   * @return {Mixed}     Whatever is written in the config
  ###
  get = (key) ->
    return config[key]

  return {
    init: init
    get: get
  }
