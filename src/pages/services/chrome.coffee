'use strict'

angular.module('chrome', [])
  .factory 'Chrome', () ->

    emitMessage = (messageId, parameter, callback) ->
      chrome.runtime.sendMessage {action: messageId, params: parameter}, callback

    # Public API here
    {
      installPackage: (packageId, callback) ->
        emitMessage('installPackage', {packageId: packageId}, callback)

      getProxmateStatus: (callback) ->
        emitMessage('getProxmateGlobalStatus', {}, callback)

      setProxmateStatus: (status, callback) ->
        emitMessage('setProxmateGlobalStatus', {newStatus: status}, callback)

      getInstalledPackages: (callback) ->
        emitMessage('getInstalledPackages', {}, callback)

      removePackage: (packageId, callback) ->
        emitMessage('removePackage', {packageId: packageId}, callback)

      getDonationkey: (callback) ->
        emitMessage('getDonationkey', {}, callback)

      setDonationkey: (key, callback) ->
        emitMessage('setDonationkey', {donationKey: key}, callback)
    }