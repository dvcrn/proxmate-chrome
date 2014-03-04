currentHash = null
checkHash = ->
  hash = location.hash
  if hash is currentHash
    return
  currentHash = hash

  # Execute code here. Check the proxmate button, change it's class and put event listeners on it :)
  if currentHash.indexOf('package/') != -1
    installButton = $('.installbutton')

    # Indicate that the user can install now
    installButton.text('Add to ProxMate')

    # add a custom class so we can style on the server side
    installButton.addClass('pxm-installbutton')

    # Remove the link, if any. This script will handle the onClick now
    installButton.attr('a', '')

    # Finally, add a click handler
    installButton.mouseup ->
      # Packageid is set by the server as a seperate attribute
      packageid = installButton.attr('packageid')
      window.open chrome.extension.getURL("pages/install/index.html#!/install/#{packageid}")


setInterval checkHash, 1000