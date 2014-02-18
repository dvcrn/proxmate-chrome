define [], ->
  init = ->

  exports = {
    init: init

    storage:
      local:
        set: chrome.storage.local.set
        get: chrome.storage.local.get

    proxy:
      settings:
        set: chrome.proxy.settings.set
        clear: chrome.proxy.settings.clear

    runtime:
      onMessage:
        addListener: chrome.runtime.onMessage.addListener
  }

  if chrome.app
    return chrome
  else
    return exports