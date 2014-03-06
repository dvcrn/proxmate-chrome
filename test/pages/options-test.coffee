describe 'Controller: MainCtrl', () ->

  # load the controller's module
  beforeEach module 'optionsApp'

  MainCtrl = {}
  scope = {}
  controller = {}
  chromeSpy = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    controller = $controller

    chromeSpy = jasmine.createSpyObj('chrome', ['getInstalledPackages', 'removePackage'])

  it 'should call getInstalledPackages and attach result to scope', ->
    chromeSpy.getInstalledPackages.andCallFake((callback) ->
      callback {
        'asdf': 123
      }
    )

    MainCtrl = controller 'MainCtrl', {
      $scope: scope,
      Chrome: chromeSpy
    }

    expect(chromeSpy.getInstalledPackages).toHaveBeenCalled()
    expect(scope.installedPackages).toEqual({'asdf': 123})

  it 'should remove a package on removePackage(id)', ->
    chromeSpy.removePackage.andCallFake((id, callback) ->
      callback()
    )

    MainCtrl = controller 'MainCtrl', {
      $scope: scope,
      Chrome: chromeSpy
    }

    fetchPackagesSpy = spyOn(scope, 'fetchInstalledPackages')

    window.confirm = (text) ->
      return false

    scope.removePackage(123)
    expect(chromeSpy.removePackage).not.toHaveBeenCalled()

    window.confirm = (text) ->
      return true

    scope.removePackage(123)
    expect(chromeSpy.removePackage).toHaveBeenCalledWith(123, jasmine.any(Function))
    expect(fetchPackagesSpy).toHaveBeenCalled()