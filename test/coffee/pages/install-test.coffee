'use strict'

describe 'Controller: InstallCtrl', () ->

  # load the controller's module
  beforeEach module 'proxmateApp'

  MainCtrl = {}
  scope = {}
  controller = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    controller = $controller

  it 'should call installPackage and indicate the status', () ->
    chromeSpy = jasmine.createSpyObj('chrome', ['installPackage'])
    chromeSpy.installPackage.andCallFake((config, callback) ->
      callback {success: true}
    )

    InstallCtrl = controller 'InstallCtrl', {
      $scope: scope
      $routeParams: {
        'packageId': 123
      }
      chrome: chromeSpy
    }

    expect(scope.status).toBe 'Installed successfully!'
    expect(chromeSpy.installPackage).toHaveBeenCalledWith(123, jasmine.any(Function))
