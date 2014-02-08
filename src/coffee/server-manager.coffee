define ['storage', 'config', 'jquery'], (Storage, Config, $) ->
  servers = []

  init = (callback) ->
    exports.loadServersFromStorage()

    if servers.length > 0
      callback()
    else
      exports.fetchServerList(callback)

  ###*
   * Load servers from storage into array
  ###
  loadServersFromStorage = ->
    tmpServers = Storage.get('server_config')
    if tmpServers is null
      tmpServers = []

    servers = tmpServers
    return servers

  ###*
   * Fetch a fresh server list from storage
   * @param  {Function} callback Callback
  ###
  fetchServerList = (callback) ->
    $.get(Config.get('primary_server') + '/api/server/list.json', (data) ->
      @servers = data
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