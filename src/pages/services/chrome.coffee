'use strict'

angular.module('chrome', [])
  .factory 'Chrome', () ->

    # Public API here
    {
      installPackage: (packageId, callback) ->
        console.info "trying to install package #{packageId}"
        # Emit message to backend
        chrome.runtime.sendMessage {action: "installPackage", params:{packageId: packageId}}, (response) ->
          callback response

      getProxmateStatus: (callback) ->
        chrome.runtime.sendMessage {action: "getProxmateGlobalStatus", params:{}}, (response) ->
          callback response

      setProxmateStatus: (status, callback) ->
        chrome.runtime.sendMessage {action: "setProxmateGlobalStatus", params:{newStatus: status}}, (response) ->
          callback response

      getInstalledPackages: (callback) ->
        chrome.runtime.sendMessage {action: "getInstalledPackages", params:{}}, (response) ->
          callback response

      removePackage: (packageId, callback) ->
        chrome.runtime.sendMessage {action: "removePackage", params:{packageId: packageId}}, (response) ->
          callback response
    }