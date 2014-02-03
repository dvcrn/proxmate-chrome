require.config
	paths:
    "text" : "../../bower_components/requirejs-text/text"
    "jquery" : "../../bower_components/jquery/jquery"

(->
	require([
    'config',
    'package-manager',
    'storage'
  ], (
    Config,
    PackageManager,
    Storage
  ) ->
    Config.init()
    Storage.init()
    PackageManager.init()
  )
)()