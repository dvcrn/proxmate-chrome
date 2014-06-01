{Config} = require './config'
{PackageManager} = require './package-manager'
{Storage} = require './storage'
{ProxyManager} = require './proxy-manager'
{ServerManager} = require './server-manager'
{EventBinder} = require './event-binder'
{Runtime} = require './runtime'

class App
  init: ->
    Config.init()
    # Storage is built on top of asynchronous chrome.storage code.
    # We have to use a callback to make sure the content has been copied from storage into ram
    Storage.init(->
      ServerManager.init(->
        PackageManager.init()
        ProxyManager.init()
        EventBinder.init()
        Runtime.init()

        Runtime.start()
      )
    )

app = new App()
app.init()
