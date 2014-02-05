require.config
	paths:
    "text" : "../../bower_components/requirejs-text/text"
    "jquery" : "../../bower_components/jquery/jquery"

(->
	require([
    'config',
    'package-manager',
    'storage',
    'proxy-manager'
  ], (
    Config,
    PackageManager,
    Storage,
    ProxyManager
  ) ->
    Config.init()
    Storage.init()
    PackageManager.init()
    ProxyManager.init()


  )
)()