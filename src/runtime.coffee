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

    Chrome.browserAction.setIcon({path: "ressources/images/icon48.png"});
    Chrome.browserAction.setBadgeText({text: ""})

    packages = PackageManager.getInstalledPackages()
    servers = ServerManager.getServers()

    if packages.length == 0 or servers.length == 0
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
    exports.stop()
    exports.start()

  ###*
   * Removed the proxy from chrome
  ###
  stop = ->
    Chrome.browserAction.setBadgeText({text: "Off"})
    Chrome.browserAction.setIcon({path: "ressources/images/icon48_grey.png"});
    ProxyManager.clearProxy()

  exports = {
    init: init
    start: start
    restart: restart
    stop: stop
  }

  return exports