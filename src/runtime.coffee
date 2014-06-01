{PackageManager} = require './package-manager'
{ServerManager} = require './server-manager'
{ProxyManager} = require './proxy-manager'
{Storage} = require './storage'
{Chrome} = require './chrome'

class Runtime
  init: ->

  ###*
   * Starts the app. Retrieves servers and sets pac
  ###
  start: ->
    globalStatus = Storage.get('global_status')
    if not globalStatus
      @stop()
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
  restart: ->
    @stop()
    ServerManager.init( ->
      PackageManager.init() # Since we want to fetch new packages / update the existing ones
    )
    @start()

  ###*
   * Removed the proxy from chrome
  ###
  stop: ->
    Chrome.browserAction.setBadgeText({text: "Off"})
    Chrome.browserAction.setIcon({path: "ressources/images/icon48_grey.png"});
    ProxyManager.clearProxy()

exports.Runtime = new Runtime()
