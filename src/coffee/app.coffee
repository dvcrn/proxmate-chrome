require.config
  paths:
    "text" : "../../bower_components/requirejs-text/text"
    "jquery" : "../../bower_components/jquery/dist/jquery"

(->
  require([
    'config',
    'package-manager',
    'storage',
    'proxy-manager',
    'server-manager',
    'event-binder',
    'runtime'
  ], (
    Config,
    PackageManager,
    Storage,
    ProxyManager,
    ServerManager,
    EventBinder,
    Runtime
  ) ->
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
)
)()