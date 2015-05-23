{PackageManager} = require './package-manager'
{ServerManager} = require './server-manager'
{ProxyManager} = require './proxy-manager'
{Storage} = require './storage'
{Browser} = require './browser'

class Runtime
  init: ->

  ###*
   * Starts the app. Retrieves servers and sets pac
  ###
  start: ->
    # Ping server on first start to gather the actual user count
    if Storage.get('did_server_ping') == undefined
      if Storage.get('uuid') == undefined
        uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
          r = Math.random() * 16 | 0
          v = if c == 'x' then r else r & 0x3 | 0x8
          v.toString 16
        )

        Storage.set('uuid', uuid)
      else
        uuid = Storage.get('uuid')

      Browser.xhr("https://damp-retreat-5872.herokuapp.com/api/chrome.json?uuid=#{uuid}", 'POST', (data) ->
        Storage.set('did_server_ping', true)
      )

    globalStatus = Storage.get('global_status')
    if not globalStatus
      @stop()
      return

    Browser.setIcon("ressources/images/icon48.png")
    Browser.setIcontext("")

    packages = PackageManager.getInstalledPackages()
    servers = ServerManager.getServers()

    if packages.length == 0 or servers.length == 0
        if packages.length == 0
          Browser.setIcontext("None")
    else
        Browser.setIcontext("")
        pac = ProxyManager.generateProxyAutoconfigScript(packages, servers)
        ProxyManager.setProxyAutoconfig(pac)

  ###*
   * Restarts application flow. This means the app is already running and now getting started again.
  ###
  restart: ->
    @stop()
    ServerManager.init( =>
      PackageManager.init() # Since we want to fetch new packages / update the existing ones
      @start()
    )

  ###*
   * Removed the proxy from chrome
  ###
  stop: ->
    Browser.setIcontext("Off")
    Browser.setIcon("ressources/images/icon48_grey.png")
    ProxyManager.clearProxy()

exports.Runtime = new Runtime()
