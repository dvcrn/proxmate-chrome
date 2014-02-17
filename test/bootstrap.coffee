deps = []
for file in Object.keys(window.__karma__.files)
  if /test\.js$/.test(file)
    deps.push file

# Overwrite chrome object
window.chrome =
  storage:
    local:
      set: ->
      get: ->

  proxy:
    settings:
      set: ->
      clear: ->

require.config
  baseUrl: '/base/src/js'
  paths:
    "text": "../../bower_components/requirejs-text/text"
    "jquery": "../../bower_components/jquery/jquery"

  # load all tests
  deps: deps

  # kick off karma
  callback: window.__karma__.start