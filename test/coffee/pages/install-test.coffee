'use strict'

describe 'Controller: InstallCtrl', () ->

  # load the controller's module
  beforeEach module 'proxmateApp'

  MainCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    InstallCtrl = $controller 'InstallCtrl', {
      $scope: scope
      $routeParams: {
        'id': 123
      }
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.asdf).toBe 123
