define ['storage'], (Storage) ->
  servers = []

  init = ->
    exports.loadServersFromStorage()
    exports.fetchServerList()

  ###*
   * Load servers from storage into array
  ###
  loadServersFromStorage = ->
    servers = Storage.get('server_config')

  fetchServerList = ->


  exports = {
    init: init
    loadServersFromStorage: loadServersFromStorage
    fetchServerList: fetchServerList
  }

  return exports