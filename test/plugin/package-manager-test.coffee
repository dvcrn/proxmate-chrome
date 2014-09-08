{PackageManager} = require '../../src/package-manager'
{Storage} = require '../../src/storage'
{Config} = require '../../src/config'
{Runtime} = require '../../src/runtime'
{Browser} = require '../../src/browser'

testPackages = require '../testdata/packages.json'
testServers = require '../testdata/servers.json'


describe 'Package Manager', ->
  beforeEach ->
    this.sandbox = sinon.sandbox.create()

    this.sandbox.stub(Config, 'get', ->
      return 'www.abc.de'
    )

    this.runtimeStub = this.sandbox.stub(Runtime, 'restart')

  afterEach ->
    this.sandbox.restore()

  describe 'The update behaviour', ->

    it 'should checkForUpdates on init', ->
      spy = this.sandbox.stub(PackageManager, 'checkForUpdates')
      PackageManager.init()
      assert.isTrue(spy.calledOnce)

    it 'should download the version overview and execute callback', ->
      callback = this.sandbox.spy()

      # Fake XHR
      expectedPayload = {
        "1337asdf": 1,
        "anotherrandomID": 2
      }

      xhrMock = this.sandbox.stub(Browser, 'xhr').callsArgWith(2, expectedPayload)

      PackageManager.downloadVersionRepository(callback)

      assert.isTrue(xhrMock.calledOnce)
      assert.isTrue(callback.calledWith(expectedPayload))

    it 'should attach the donation key to the download url if available', ->
      xhrMock = this.sandbox.stub(Browser, 'xhr')
      this.storageGetStub = this.sandbox.stub(Storage, 'get', (key) ->
        return 'foo'
      )

      callback = this.sandbox.spy()
      PackageManager.downloadVersionRepository(callback)

      assert.isTrue(xhrMock.calledOnce)
      assert.isTrue(xhrMock.calledWith('www.abc.de/package/update.json?key=foo'))

    it 'should call downloadVersionRepository and install / delete outdated packages', ->
      # Mock storage.get to return a fake array of installed packages
      this.storageGetStub = this.sandbox.stub(Storage, 'get', ->
        return {
          'somethingThatsUpToDate': 2,
          'somethingOutdated': 1,
          'somethingWithoutUpdate': 1,
          'somethingElseOutdated': 2,
          'somethingToDelete': 3
        }
      )

      # Mock array we could get back from the server with newer versions
      testVersionJson = {
        'somethingThatsUpToDate': 2,
        'somethingOutdated': 2
        'somethingElseOutdated': 3,
        'somethingToDelete': -1
      }

      downloadVersionRepositoryStub = this.sandbox.stub(PackageManager, "downloadVersionRepository", (callback) ->
        callback testVersionJson
      )

      # InstalledPackage should get called after finding outdated packages
      openTabStub = this.sandbox.stub(Browser, "createTab")
      installPackageStub = this.sandbox.stub(PackageManager, "installPackage")
      removePackageStub = this.sandbox.stub(PackageManager, "removePackage")

      PackageManager.checkForUpdates()
      assert.isTrue(downloadVersionRepositoryStub.calledOnce)
      assert.isTrue(openTabStub.calledTwice, "All outdated packages have been passed to installing")

      assert.isTrue(removePackageStub.calledOnce)
      assert.isTrue(removePackageStub.calledWith('somethingToDelete'))


  describe 'Installation behaviour', ->
    it 'should download package information from server', ->
      this.storageSetStub = this.sandbox.stub(Storage, 'set')
      this.storageGetStub = this.sandbox.stub(Storage, 'get', (key) ->
        if key == 'donation_key'
          return null

        return {}
      )

      pkgId = 'foo'
      pkgInfo = testPackages[0]

      callback = this.sandbox.spy()
      xhrMock = this.sandbox.stub(Browser, 'xhr').callsArgWith(2, pkgInfo)

      PackageManager.installPackage(pkgId, callback)

      # Fake xhr answer
      assert.isTrue(xhrMock.calledOnce)
      assert.isTrue(xhrMock.calledWith("www.abc.de/package/#{pkgId}/install.json"))

      # The packagemanager should retrieve installed_packages
      assert.isTrue(this.storageGetStub.calledTwice)
      assert.isTrue(this.storageGetStub.calledWith('donation_key'))
      assert.isTrue(this.storageGetStub.calledWith('installed_packages'))

      # Then take what it gets back from installed packages and append the new element
      assert.isTrue(this.storageSetStub.calledTwice)
      assert.isTrue(this.storageSetStub.calledWith('installed_packages', {'foo': 1}), 'The new package ID got added in the installed_packages array')
      # Finally add the new package content into storage
      assert.isTrue(this.storageSetStub.calledWith(pkgId, pkgInfo), 'The Storage got called with the correct ID and payload')

      # And of course execute our callback
      assert.isTrue(callback.calledWith({success: true}))

      # Check that restart got called
      assert.isTrue(this.runtimeStub.calledOnce)

    it 'should append the correct donation key if available', ->
      this.storageSetStub = this.sandbox.stub(Storage, 'set')
      this.storageGetStub = this.sandbox.stub(Storage, 'get', (key) ->
        if key == 'donation_key'
          return 'asdf'

        return {}
      )
      callback = this.sandbox.spy()
      xhrMock = this.sandbox.stub(Browser, 'xhr')
      PackageManager.installPackage('asdf', callback)

      # Fake xhr answer
      assert.isTrue(xhrMock.calledOnce)
      assert.isTrue(xhrMock.calledWith('www.abc.de/package/asdf/install.json?key=asdf'))

    it 'should react correctly on 401 (unauthorised) status', ->
      this.storageSetStub = this.sandbox.stub(Storage, 'set')
      this.storageGetStub = this.sandbox.stub(Storage, 'get', (key) ->
        if key == 'donation_key'
          return 'asdf'

        return {}
      )
      callback = this.sandbox.spy()

      # Simulate error message
      xhrMock = this.sandbox.stub(Browser, 'xhr').callsArgWith(3, { status: 401, responseJSON: { "message": "Foo" } })
      PackageManager.installPackage('asdf', callback)

      # Fake xhr answer
      assert.isTrue(xhrMock.calledOnce)
      assert.isTrue(xhrMock.calledWith('www.abc.de/package/asdf/install.json?key=asdf'))

      # Check that restart didn't get called
      assert.isFalse(this.runtimeStub.calledOnce, "Runtime didn't get called")
      assert.isTrue(callback.calledWith({success: false, message: 'Foo'}))

    it 'should react correctly on 500 error', ->
      this.storageSetStub = this.sandbox.stub(Storage, 'set')
      this.storageGetStub = this.sandbox.stub(Storage, 'get', (key) ->
        return {}
      )

      callback = this.sandbox.spy()
      xhrMock = this.sandbox.stub(Browser, 'xhr').callsArgWith(3, { status: 500 })
      PackageManager.installPackage('asdf', callback)

      assert.isTrue(xhrMock.calledOnce)
      assert.isFalse(this.runtimeStub.calledOnce, "Runtime didn't get called")
      assert.isTrue(callback.calledWith({success: false, message: 'There was a problem installing this package.'}))

    it 'should react correctly on 404 error', ->
      this.storageSetStub = this.sandbox.stub(Storage, 'set')
      this.storageGetStub = this.sandbox.stub(Storage, 'get', (key) ->
        return {}
      )
      callback = this.sandbox.spy()
      xhrMock = this.sandbox.stub(Browser, 'xhr').callsArgWith(3, { status: 404 })
      PackageManager.installPackage('asdf2', callback)

      assert.isTrue(xhrMock.calledOnce)
      assert.isFalse(this.runtimeStub.calledOnce, "Runtime didn't get called")
      assert.isTrue(callback.calledWith({success: false, message: "The package you tried to install doesn't exist..."}))


  describe 'Basic functionality', ->

    it 'should retrieve all installed packages', ->
      expectedJson = testPackages

      # We are loading mock data and create a simple dummy funciton which just returns from the mock data if id matches
      this.storageGetStub = this.sandbox.stub(Storage, 'get', (key) ->
        switch key
          when 'installed_packages'
            ids = {}
            for pkg in testPackages
              ids[pkg._id] = pkg.version
            return ids
          else
            for pkg in testPackages
              if pkg._id is key
                return pkg
      )

      packages = PackageManager.getInstalledPackages()
      assert.equal((testPackages.length + 1), this.storageGetStub.callCount)
      assert.isTrue(this.storageGetStub.calledWith('installed_packages'), 'Installed packages have been queried from storage')
      for pkg in testPackages
        assert.isTrue(this.storageGetStub.calledWith(pkg._id), 'Got called with the correct id')

      assert.deepEqual(expectedJson.sort(), packages.sort())

    it 'should delete packages correctly', ->
      storageSetStub = this.sandbox.stub(Storage, 'set')
      storageDeleteStub = this.sandbox.stub(Storage, 'remove')
      storageGetStub = this.sandbox.stub(Storage, 'get', ->
        return {
          123: 1,
          'foo': 2,
          'bar': 3
        }
      )

      PackageManager.removePackage(123)

      # Check for retrieve packages
      assert.isTrue(storageGetStub.calledWith('installed_packages'))
      assert.isTrue(storageGetStub.calledOnce)
      # Check for delete call to storage
      assert.isTrue(storageDeleteStub.calledWith(123))
      assert.isTrue(storageDeleteStub.calledOnce)
      # Check for new installed_packages array
      assert.isTrue(storageSetStub.calledWith('installed_packages', {'foo': 2, 'bar': 3}))
      assert.isTrue(storageSetStub.calledOnce)

      # Check restart runtime
      assert.isTrue(this.runtimeStub.calledOnce)
