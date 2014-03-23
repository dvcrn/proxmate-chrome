describe 'Controller: MainCtrl', () ->

  # load the controller's module
  beforeEach module 'optionsApp'

  MainCtrl = {}
  scope = {}
  controller = {}
  chromeSpy = {}

  httpBackend = {}

  beforeEach inject ($controller, $rootScope, $httpBackend) ->
    scope = $rootScope.$new()
    controller = $controller

    httpBackend = $httpBackend
    chromeSpy = jasmine.createSpyObj('chrome', ['getInstalledPackages', 'removePackage', 'getDonationkey', 'setDonationkey'])

  it 'should call init functions and attach result to scope', ->
    chromeSpy.getInstalledPackages.andCallFake (callback) ->
      callback
        'asdf': 123

    chromeSpy.getDonationkey.andCallFake (callback) ->
      callback 'foo'

    MainCtrl = controller 'MainCtrl', {
      $scope: scope,
      Chrome: chromeSpy
    }

    expect(chromeSpy.getInstalledPackages).toHaveBeenCalled()
    expect(chromeSpy.getDonationkey).toHaveBeenCalled()

    expect(scope.installedPackages).toEqual({'asdf': 123})
    expect(scope.donationKey).toEqual('foo')

    expect(scope.donationKeyStatus).toEqual('')
    expect(scope.hasDonationkey).toEqual(true)

    # Second run.
    # If donationKey is null, hasDonationkey should be false

    chromeSpy.getDonationkey.andCallFake (callback) ->
      callback null

    MainCtrl = controller 'MainCtrl', {
      $scope: scope,
      Chrome: chromeSpy
    }

    expect(scope.hasDonationkey).toEqual(false)


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

  it 'should validate key and set if valid', ->
    chromeSpy.setDonationkey.andCallFake (key, callback) -> callback true

    httpBackend.when('GET', 'http://api.proxmate.me/user/validate/invalid.json').respond({isValid: false, message: 'foo'})
    httpBackend.when('GET', 'http://api.proxmate.me/user/validate/valid.json').respond({isValid: true})

    MainCtrl = controller 'MainCtrl', {
      $scope: scope,
      Chrome: chromeSpy
    }

    fetchSpy = spyOn(scope, 'fetchDonationkey')

    httpBackend.expectGET('http://api.proxmate.me/user/validate/invalid.json');
    scope.validateKey('invalid')
    httpBackend.flush()
    expect(scope.donationKeyStatus).toBe('foo')
    # Nothing should have happened on the backend side
    expect(chromeSpy.setDonationkey).not.toHaveBeenCalled()
    expect(fetchSpy).not.toHaveBeenCalled()

    httpBackend.expectGET('http://api.proxmate.me/user/validate/valid.json');
    scope.validateKey('valid')
    httpBackend.flush()
    expect(scope.donationKeyStatus).toBe('The key you entered is valid. Thanks for donating!')
    expect(chromeSpy.setDonationkey).toHaveBeenCalled()
    expect(fetchSpy).toHaveBeenCalled()

  it 'should remove key on clearKey', ->
    chromeSpy.setDonationkey.andCallFake (key, callback) -> callback true
    MainCtrl = controller 'MainCtrl', {
      $scope: scope,
      Chrome: chromeSpy
    }

    fetchSpy = spyOn(scope, 'fetchDonationkey')
    scope.clearKey()
    expect(chromeSpy.setDonationkey).toHaveBeenCalledWith(null, jasmine.any(Function))
    expect(fetchSpy).toHaveBeenCalled()
