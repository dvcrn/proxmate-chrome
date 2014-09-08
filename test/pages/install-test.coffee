'use strict'

describe 'Controller: ConfirmCtrl', () ->

  # load the controller's module
  beforeEach module 'proxmateApp'

  MainCtrl = {}
  scope = {}
  controller = {}
  httpBackend = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope, $httpBackend) ->
    scope = $rootScope.$new()
    controller = $controller
    httpBackend = $httpBackend

  it 'should fetch package information', () ->
    httpBackend.expectGET("http://api.proxmate.me/package/123.json")
    InstallCtrl = controller 'ConfirmCtrl', {
      $scope: scope
      $routeParams: {
        'method': 'foo',
        'packageData': 'bar',
        'packageId': 123
      }
    }

    httpBackend.when('GET', "http://api.proxmate.me/package/123.json").respond({'moo': 'cow'})
    httpBackend.flush()
    expect(scope.method).toBe 'foo'
    expect(scope.packageData).toEqual {'moo': 'cow'}

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
      Chrome: chromeSpy
    }

    expect(scope.status).toBe 'Installed successfully!'
    expect(chromeSpy.installPackage).toHaveBeenCalledWith(123, jasmine.any(Function))

  it 'should pass the message from backend on error', () ->
    chromeSpy = jasmine.createSpyObj('chrome', ['installPackage'])
    chromeSpy.installPackage.andCallFake((config, callback) ->
      callback {success: false, message: 'Wooooohohohohoho'}
    )

    InstallCtrl = controller 'InstallCtrl', {
      $scope: scope
      $routeParams: {
        'packageId': 123
      }
      Chrome: chromeSpy
    }

    expect(scope.status).toBe 'Wooooohohohohoho'
    expect(chromeSpy.installPackage).toHaveBeenCalled()
