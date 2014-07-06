host = window.location.host
url = window.location.href
path = window.location.pathname

ProxMate.getProxmateStatus (status) ->
  if !status
    return

  ProxMate.getInstalledPackages (packages) ->
    for pkg in packages
      for pkghost in pkg.hosts
        # Generate a valid regex rule from the host
        regex = pkghost.replace(/\./g, "\\.")
        regex = regex.replace(/\*/g, ".*")

        regexObject = new RegExp("^#{regex}$", "g")
        if host.search(regexObject) != -1
          # We have a valid host match
          for contentScript in pkg.contentScripts
            regexObject = new RegExp(contentScript.matches, "g")
            if path.search(regexObject) != -1
              # Content script regex rule matches, continue injecting
              eval(atob(contentScript.script))
