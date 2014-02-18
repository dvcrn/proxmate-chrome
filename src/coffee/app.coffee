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
    'event-binder'
  ], (
    Config,
    PackageManager,
    Storage,
    ProxyManager,
    ServerManager,
    EventBinder
  ) ->
    Config.init()
    # Storage is built on top of asynchronous chrome.storage code.
    # We have to use a callback to make sure the content has been copied from storage into ram
    Storage.init(->
      ServerManager.init(->
        PackageManager.init()
        ProxyManager.init()
        EventBinder.init()

        packages = PackageManager.getInstalledPackages()
        servers = ServerManager.getServers()

        if !packages or !servers
            pac = ProxyManager.generateProxyAutoconfigScript(packages, servers)
            ProxyManager.setProxyAutoconfig(pac)
        else
            console.info 'No servers and packages'
      )
    )
)
)()