require.config
	paths:
    "text" : "../../bower_components/requirejs-text/text"
    "jquery" : "../../bower_components/jquery/jquery"

(->
	require([
    'config',
    'package-manager',
    'storage',
    'proxy-manager',
    'server-manager'
  ], (
    Config,
    PackageManager,
    Storage,
    ProxyManager,
    ServerManager
  ) ->
    Config.init()
    # Storage is built on top of asynchronous chrome.storage code.
    # We have to use a callback to make sure the content has been copied from storage into ram
    Storage.init(->
      ServerManager.init(->
        PackageManager.init()
        ProxyManager.init()

        packages = PackageManager.getInstalledPackages()
        servers = ServerManager.getServers()

        pac = ProxyManager.generateProxyAutoconfigScript(packages, servers)
        ProxyManager.setProxyAutoconfig(pac)
      )
    )
  )
)()