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
    # Storage is built on top of asynchronous chrome.storage code.
    # We have to use a callback to make sure the content has been copied from storage into ram
    Storage.init(->
      PackageManager.init()
      ProxyManager.init()

      packages = PackageManager.getInstalledPackages()
      pac = ProxyManager.generateProxyAutoconfigScript(packages)
      # console.info pac
      # ProxyManager.setProxyAutoconfig(pac)
    )

  )
)()