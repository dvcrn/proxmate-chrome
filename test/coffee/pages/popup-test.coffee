'use strict'

describe 'Controller: InstallCtrl', () ->

  # load the controller's module
  beforeEach module 'popupApp'

  MainCtrl = {}
  scope = {}
  controller = {}
  chromeSpy = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    controller = $controller

    chromeSpy = jasmine.createSpyObj('chrome', ['getProxmateStatus', 'setProxmateStatus'])


  it 'should call getProxmateStatus and bind to scope', () ->
    chromeSpy.getProxmateStatus.andCallFake((callback) ->
      callback true
    )

    MainCtrl = controller 'MainCtrl', {
      $scope: scope,
      Chrome: chromeSpy
    }

    expect(chromeSpy.getProxmateStatus).toHaveBeenCalled()
    expect(scope.proxmateStatus).toBe(true)

  it 'should call chrome.setProxmateStatus correctly on activate / deactivate', ->
    chromeSpy.setProxmateStatus.andCallFake((status, callback) ->
      callback true
    )

    MainCtrl = controller 'MainCtrl', {
      $scope: scope,
      Chrome: chromeSpy
    }

    scope.deactivateProxmate()
    expect(chromeSpy.setProxmateStatus).toHaveBeenCalledWith(false, jasmine.any(Function))

    scope.activateProxmate()
    expect(chromeSpy.setProxmateStatus).toHaveBeenCalledWith(true, jasmine.any(Function))

    # Every call to activate / deactivate ProxMate should trigger one get
    expect(chromeSpy.getProxmateStatus.callCount).toBe(3)