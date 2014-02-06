define ['chrome'], (Chrome) ->
  init = (callback) ->
    copyFromChromeStorage(callback)

  # Internal array to keep in ram for faster look ups
  internStorage = {}

  copyInterval = null
  ###*
   * Writes the RAM storage into chrome HDD storage, after a 1 second delay
  ###
  copyIntoChromeStorage = ->
    clearInterval copyInterval
    copyInterval = setTimeout(->
      Chrome.storage.local.set(internStorage)
    , 1000)

  copyFromChromeStorage = (callback) ->
    Chrome.storage.local.get(null, (object) ->
      internStorage = object
      callback()
    )

  ###*
   * Deletes all content from RAM storage
  ###
  flush = ->
    internStorage = {}

  ###*
   * Returns value for 'key' from Storage
   * @return {String|Array} the value inside the storage
  ###
  get = (key) ->
    return internStorage[key]

  ###*
   * Sets 'value' for 'key' in storage
  ###
  set = (key, value) ->
    internStorage[key] = value
    copyIntoChromeStorage()

  return {
    init: init,
    flush: flush,
    set: set,
    get: get
  }