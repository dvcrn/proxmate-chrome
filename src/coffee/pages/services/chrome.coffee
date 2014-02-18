'use strict'

angular.module('proxmateApp')
  .factory 'chrome', () ->

    # Public API here
    {
      installPackage: (packageId, callback) ->
        console.info "trying to install package #{packageId}"
        # Emit message to backend
        chrome.runtime.sendMessage {action: "installPackage", params:{packageId: packageId}}, (response) ->
          callback response
    }