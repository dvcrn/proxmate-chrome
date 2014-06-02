class Chrome
  init: ->

  storage:
    local:
      set: ->
      get: ->
      remove: ->

  proxy:
    settings:
      set: ->
      clear: ->

  runtime:
    onMessage:
      addListener: ->

  browserAction:
    setBadgeText: ->
    setIcon: ->


if chrome? and chrome.app?
  exports.Chrome = chrome
else
  exports.Chrome = new Chrome()
