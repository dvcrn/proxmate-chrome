define ['chrome', 'package-manager'], (Chrome, PackageManager) ->
  init = ->
    Chrome.runtime.onMessage.addListener exports.messageListener

  ###*
   * Event listener for chrome message events
   * @param  {Object} request      request and parameters
   * @param  {Object} sender       sender object
   * @param  {Function} sendResponse callback to emit answer back to frontend
   * @return {boolean}              status whether to keep the connection open or not
  ###
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