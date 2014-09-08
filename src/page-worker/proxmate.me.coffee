checkUrl = ->
  console.info('check')
  url = location.href
  if url.indexOf('package/') == -1
    return

  # Execute code here. Check the proxmate button, change it's class and put event listeners on it :)
  installButton = $('.installbutton')

  if installButton.hasClass('pxm-installbutton')
    currentUrl = url
    return

  # Indicate that the user can install now
  installButton.text('Add to ProxMate')

  # add a custom class so we can style on the server side
  installButton.addClass('pxm-installbutton')

  # Remove the link, if any. This script will handle the onClick now
  installButton.attr('a', '')

  # Finally, add a click handler
  installButton.mouseup ->
    packageid = installButton.attr('packageid')
    window.open chrome.extension.getURL("pages/install/index.html#!/confirm/install/#{packageid}")

setInterval checkUrl, 1000
