define [
  'package-manager',
  'server-manager',
  'proxy-manager'
], (PackageManager, ServerManager, ProxyManager) ->
  init = ->

  ###*
   * Starts the app. Retrieves servers and sets pac
  ###
  start = ->
    packages = PackageManager.getInstalledPackages()
    servers = ServerManager.getServers()

    if packages.length == 0 or servers.length == 0
        console.info 'No servers and packages'
    else
        pac = ProxyManager.generateProxyAutoconfigScript(packages, servers)
        ProxyManager.setProxyAutoconfig(pac)

  ###*
   * Restarts application flow
  ###
  restart = ->
    exports.start()

  exports = {
    init: init,
    start: start,
    restart: restart
  }

  return exports