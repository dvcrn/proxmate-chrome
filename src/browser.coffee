{Chrome} = require './chrome'
$ = require '../bower_components/jquery/dist/jquery.js'

class Browser
  init: ->

  ###*
   * Opens url in a new tab
   * @param {String} url the url to open
  ###
  createTab: (url) ->
    Chrome.tabs.create({url: url})

  ###*
   * Sets browser wide proxy to autoconfig
   * @param {String}   pacScript the autoconfig string
   * @param {Function} callback  callback to execute after
  ###
  setProxyAutoconfig: (pacScript, callback) ->
    config =
        mode: "pac_script",
        pacScript:
          data: pacScript

    Chrome.proxy.settings.set({
      value: config,
      scope: 'regular'
    }, callback)

  ###*
   * Removes all custom proxies and resets to system
   * @param  {Function} callback callback
  ###
  clearProxy: (callback) ->
    Chrome.proxy.settings.clear({}, callback)

  ###*
   * Sets the browser icon
   * @param {string} iconUrl the url for the icon
  ###
  setIcon: (iconUrl) ->
    Chrome.browserAction.setIcon({path: iconUrl});

  ###*
   * Sets the text for the icon (if possible)
   * @param {string} text the text to set
  ###
  setIcontext: (text) ->
    Chrome.browserAction.setBadgeText({text: text})

  ###*
   * Removes a key from the browser storage
   * @param  {string} key the key to remove
  ###
  removeFromStorage: (key) ->
    Chrome.storage.local.remove(key)

  ###*
   * Writes a object into browser storage
   * @param  {Object} object the object (key, value) to write
  ###
  writeIntoStorage: (object) ->
    Chrome.storage.local.set(object)

  ###*
   * Returns a element from storage
   * @param  {string}   key      the elements key
   * @param  {Function} callback callback
  ###
  retrieveFromStorage: (key, callback) ->
    Chrome.storage.local.get(key, callback)

  ###*
   * Add a event listener for the message event
   * @param  {function} listener listener function
  ###
  addEventListener: (listener) ->
    Chrome.runtime.onMessage.addListener listener

  ###*
   * Performs a xmlhttprequest
   * @param  {string} url             the url to request
   * @param  {string} type            POST or GET
   * @param  {Function} successCallback callback
   * @param  {Function} errorCallback   callback
  ###
  xhr: (url, type, successCallback, errorCallback) ->
    if !successCallback?
      successCallback = ->

    if !errorCallback?
      errorCallback = ->

    $.ajax url,
      type: type,
      success: successCallback
      error: errorCallback


exports.Browser = new Browser()
