define ['chrome', 'package-manager', 'storage', 'runtime'], (Chrome, PackageManager, Storage, Runtime) ->
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

      when 'getProxmateGlobalStatus'
        status = Storage.get('global_status')
        if status
          sendResponse status
        else
          sendResponse false

      when 'setProxmateGlobalStatus'
        newStatus = params.newStatus
        if typeof newStatus != 'boolean'
          newStatus = false

        Storage.set('global_status', newStatus)

        # Start / Stop ProxMate service if neccesary
        if newStatus
          Runtime.start()
        else
          Runtime.stop()

        sendResponse true

    true

  exports = {
    init: init
    messageListener: messageListener
  }

  return exports