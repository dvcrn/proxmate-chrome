'use strict'

describe 'Factory: chrome', () ->

  # load the service's module
  beforeEach module 'proxmateApp'

  # Mock chrome's chrome module
  runtimeSpy = jasmine.createSpyObj('runtime', ['sendMessage'])
  # We fake the callback callback call here
  runtimeSpy.sendMessage.andCallFake((config, callback) ->
    callback 'some callback string'
  )
  # Put it into window.chrome, since we are not in a
  # chrome extension environment and need to emulate it
  window.chrome = {
    runtime: runtimeSpy
  }

  # instantiate service
  chrome = {}
  beforeEach inject (_chrome_) ->
    chrome = _chrome_

  it 'should be an object', () ->
    callback = jasmine.createSpy('callback spy')
    chrome.installPackage(123, callback)

    # sendMessage should receive the correct parameters and callback
    expect(runtimeSpy.sendMessage).toHaveBeenCalledWith({action: 'installPackage', params:{packageId: 123}}, jasmine.any(Function))
    expect(callback).toHaveBeenCalledWith('some callback string')
