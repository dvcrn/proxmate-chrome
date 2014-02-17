'use strict'

angular.module('proxmateApp')
  .factory 'chrome', () ->

    # Public API here
    {
      installPackage: (packageId, callback) ->
        # Emit message to backend
        chrome.runtime.sendMessage {action: "installPackage", params:{packageId: packageId}}, (response) ->
          callback response
    }