define ['storage', 'config', 'jquery'], (Storage, Config, $) ->
  servers = []

  init = (callback) ->
    exports.loadServersFromStorage()

    if servers.length > 0
      callback()
      exports.fetchServerList(->)
    else
      exports.fetchServerList(callback)

  ###*
   * Load servers from storage into array
  ###
  loadServersFromStorage = ->
    tmpServers = Storage.get('server_config')
    if !tmpServers
      tmpServers = []

    servers = tmpServers
    return servers

  ###*
   * Fetch a fresh server list from storage
   * @param  {Function} callback Callback
  ###
  fetchServerList = (callback) ->
    $.get(Config.get('primary_server') + '/server/list.json', (data) ->
      @servers = data
      Storage.set('server_config', @servers)
      callback()
    )

  ###*
   * Return all servers
   * @return {Object} all servers
  ###
  getServers = ->
    return servers

  exports = {
    init: init
    getServers: getServers
    loadServersFromStorage: loadServersFromStorage
    fetchServerList: fetchServerList
  }

  return exports