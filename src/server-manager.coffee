define ['storage', 'config', 'jquery'], (Storage, Config, $) ->
  servers = []

  init = (callback) ->
    servers = exports.loadServersFromStorage()

    if servers.length > 0
      exports.fetchServerList(->)
      callback()
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
    server = Config.get('primary_server')
    donationKey = Storage.get('donation_key')
    serverUrl = "#{server}/server/list.json"
    if donationKey?
      donationKey = encodeURIComponent(donationKey)
      serverUrl = "#{server}/server/list.json?key=#{donationKey}"

    $.get(serverUrl, (data) ->
      servers = data
      Storage.set('server_config', servers)
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
