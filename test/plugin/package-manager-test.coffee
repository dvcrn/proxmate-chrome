define [
  'package-manager',
  'storage',
  'config',
  'text!../testdata/packages.json',
  'text!../testdata/servers.json',
  'runtime'
], (PackageManager, Storage, Config, testPackages, testServers, Runtime) ->
  testServers = JSON.parse(testServers)
  testPackages = JSON.parse(testPackages)

  describe 'Package Manager', ->
    beforeEach ->
      this.sandbox = sinon.sandbox.create()

      this.sandbox.stub(Config, 'get', ->
        return 'www.abc.de'
      )

      this.xhr = this.sandbox.useFakeXMLHttpRequest()
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
        PackageManager.downloadVersionRepository(callback)

        expectedPayload = {
          "1337asdf": 1,
          "anotherrandomID": 2
        }

        # Fake XHR
        assert.equal(1, this.sandbox.server.requests.length)
        assert.equal('www.abc.de/package/update.json', this.sandbox.server.requests[0].url)
        this.sandbox.server.requests[0].respond(200, {'Content-Type':'application/json'}, JSON.stringify(expectedPayload))

        assert.isTrue(callback.calledWith(expectedPayload))

      it 'should call downloadVersionRepository and install outdated packages', ->
        # Mock storage.get to return a fake array of installed packages
        this.storageGetStub = this.sandbox.stub(Storage, 'get', ->
          return {
            'somethingThatsUpToDate': 2,
            'somethingOutdated': 1,
            'somethingWithoutUpdate': 1,
            'somethingElseOutdated': 2,
          }
        )

        # Mock array we could get back from the server with newer versions
        testVersionJson = {
          'somethingThatsUpToDate': 2,
          'somethingOutdated': 2
          'somethingElseOutdated': 3
        }

        downloadVersionRepositoryStub = this.sandbox.stub(PackageManager, "downloadVersionRepository", (callback) ->
          callback testVersionJson
        )

        # InstalledPackage should get called after finding outdated packages
        installPackageStub = this.sandbox.stub(PackageManager, "installPackage")

        PackageManager.checkForUpdates()
        assert.isTrue(downloadVersionRepositoryStub.calledOnce)

        assert.isTrue(installPackageStub.calledTwice, "All outdated packages have been passed to installing")
        assert.isTrue(installPackageStub.calledWith('somethingOutdated'))
        assert.isTrue(installPackageStub.calledWith('somethingElseOutdated'))

    describe 'Installation behaviour', ->
      it 'should download package information from server', ->
        this.storageSetStub = this.sandbox.stub(Storage, 'set')
        this.storageGetStub = this.sandbox.stub(Storage, 'get', ->
          return {}
        )

        pkgId = 'foo'
        pkgInfo = testPackages[0]

        callback = this.sandbox.spy()
        PackageManager.installPackage(pkgId, callback)

        # Fake xhr answer
        assert.equal(1, this.sandbox.server.requests.length)
        assert.equal("www.abc.de/package/#{pkgId}/install.json", this.sandbox.server.requests[0].url)
        this.sandbox.server.requests[0].respond(200, {'Content-Type':'application/json'}, JSON.stringify(pkgInfo))

        # The packagemanager should retrieve installed_packages
        assert.isTrue(this.storageGetStub.calledOnce)
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

    describe 'Basic functionality', ->

      it 'should retrieve all installed packages', ->
        expectedJson = testPackages

        # We need different functionality for get this time, so restore the old one
        this.storageGetStub.restore()
        # We are loading mock data and create a simple dummy funciton which just returns from the mock data if id matches
        StorageGetMock = this.sandbox.stub(Storage, 'get', (key) ->
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
        assert.equal((testPackages.length + 1), StorageGetMock.callCount)
        assert.isTrue(StorageGetMock.calledWith('installed_packages'), 'Installed packages have been queried from storage')
        for pkg in testPackages
          assert.isTrue(StorageGetMock.calledWith(pkg._id), 'Got called with the correct id')

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