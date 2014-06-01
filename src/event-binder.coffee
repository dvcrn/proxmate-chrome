{Chrome} = require './chrome'
{PackageManager} = require './package-manager'
{Storage} = require './storage'
{Runtime} = require './runtime'

class EventBinder
  init: ->
    Chrome.runtime.onMessage.addListener @messageListener

  ###*
   * Event listener for chrome message events
   * @param  {Object} request      request and parameters
   * @param  {Object} sender       sender object
   * @param  {Function} sendResponse callback to emit answer back to frontend
   * @return {boolean}              status whether to keep the connection open or not
  ###
  messageListener: (request, sender, sendResponse) ->
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

      when 'getInstalledPackages'
        packages = PackageManager.getInstalledPackages()
        sendResponse packages

      when 'removePackage'
        packageId = params.packageId
        PackageManager.removePackage(packageId)

        sendResponse true

      when 'getDonationkey'
        key = Storage.get('donation_key')
        sendResponse key

      when 'setDonationkey'
        key = params.donationKey

        if key?
          Storage.set('donation_key', key)
        else
          Storage.remove('donation_key')

        {Runtime} = require('./runtime')
        Runtime.restart()
        sendResponse true

    true

exports.EventBinder = new EventBinder()
