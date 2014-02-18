define ['chrome', 'package-manager'], (Chrome, PackageManager) ->
  init = ->
    Chrome.runtime.onMessage.addListener exports.messageListener

  messageListener = (request, sender, sendResponse) ->
    params = request.params

    switch request.action
      when 'installPackage'
        PackageManager.installPackage(params.packageId, (response) ->
          sendResponse response
        )

    true

  exports = {
    init: init
    messageListener: messageListener
  }

  return exports