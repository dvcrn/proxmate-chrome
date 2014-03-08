define [
  'package-manager',
  'server-manager',
  'proxy-manager',
  'storage',
  'chrome'
], (PackageManager, ServerManager, ProxyManager, Storage, Chrome) ->
  init = ->

  ###*
   * Starts the app. Retrieves servers and sets pac
  ###
  start = ->
    globalStatus = Storage.get('global_status')
    if not globalStatus
      exports.stop()
      return

    packages = PackageManager.getInstalledPackages()
    servers = ServerManager.getServers()

    if packages.length == 0 or servers.length == 0
        console.info 'No servers and packages'
        if packages.length == 0
          Chrome.browserAction.setBadgeText({text: "None"})
    else
        Chrome.browserAction.setBadgeText({text: ""})
        pac = ProxyManager.generateProxyAutoconfigScript(packages, servers)
        ProxyManager.setProxyAutoconfig(pac)

  ###*
   * Restarts application flow. This means the app is already running and now getting started again.
  ###
  restart = ->
    exports.start()

  ###*
   * Removed the proxy from chrome
  ###
  stop = ->
    ProxyManager.clearProxy()

  exports = {
    init: init
    start: start
    restart: restart
    stop: stop
  }

  return exports