'use strict'

describe 'Controller: InstallCtrl', () ->

  # load the controller's module
  beforeEach module 'proxmateApp'

  MainCtrl = {}
  scope = {}
  chromeSpy = jasmine.createSpyObj('chrome', ['installPackage'])
  chromeSpy.installPackage.andCallFake((config, callback) ->
    callback 'some callback string'
  )

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

    InstallCtrl = $controller 'InstallCtrl', {
      $scope: scope
      $routeParams: {
        'packageId': 123
      }
      chrome: chromeSpy
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.status).toBe 'Installed successfully!'
    expect(chromeSpy.installPackage).toHaveBeenCalledWith(123, jasmine.any(Function))
