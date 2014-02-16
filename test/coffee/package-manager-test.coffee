define [
  'package-manager',
  'storage',
  'config',
  'text!../testdata/packages.json',
  'text!../testdata/servers.json'
], (PackageManager, Storage, Config, testPackages, testServers) ->
  testServers = JSON.parse(testServers)
  testPackages = JSON.parse(testPackages)

  describe 'Package Manager', ->
    beforeEach ->
      this.sandbox = sinon.sandbox.create()

      this.storageGetStub = this.sandbox.stub(Storage, 'get', ->
        return {
          'somethingThatsUpToDate': 2,
          'somethingOutdated': 1,
          'somethingWithoutUpdate': 1,
          'somethingElseOutdated': 2,
        }
      )
      this.storageSetStub = this.sandbox.stub(Storage, 'set')

      this.sandbox.stub(Config, 'get', ->
        return 'www.abc.de'
      )

      this.xhr = this.sandbox.useFakeXMLHttpRequest()

    afterEach ->
      this.sandbox.restore()

    describe 'The update behaviour', ->
      # Restore all stubs back to normal after each test
      afterEach ->
        for key, val of PackageManager
          if typeof PackageManager[key].restore is 'function'
            PackageManager[key].restore()

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

        assert.equal(1, this.sandbox.server.requests.length)
        assert.equal('www.abc.de/package/update.json', this.sandbox.server.requests[0].url)
        this.sandbox.server.requests[0].respond(200, {'Content-Type':'application/json'}, JSON.stringify(expectedPayload))

        assert.isTrue(callback.calledWith(expectedPayload))

      it 'should call downloadVersionRepository and install outdated packages', ->
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
        pkgId = 'somethingOutdated'
        pkgInfo = testPackages[0]

        newInstalledPackageObject = {
          'somethingThatsUpToDate': 2,
          'somethingOutdated': 1,
          'somethingWithoutUpdate': 1,
          'somethingElseOutdated': 2,
        }

        PackageManager.installPackage(pkgId)

        assert.equal(1, this.sandbox.server.requests.length)
        assert.equal("www.abc.de/package/#{pkgId}.json", this.sandbox.server.requests[0].url)
        this.sandbox.server.requests[0].respond(200, {'Content-Type':'application/json'}, JSON.stringify(pkgInfo))

        assert.isTrue(this.storageGetStub.calledOnce)
        assert.isTrue(this.storageSetStub.calledTwice)

        assert.isTrue(this.storageGetStub.calledWith('installed_packages'))

        assert.isTrue(this.storageSetStub.calledWith(pkgId, pkgInfo), 'The Storage got called with the correct ID and payload')
        assert.isTrue(this.storageSetStub.calledWith('installed_packages', newInstalledPackageObject), 'The new package ID got added in the installed_packages array')

    describe 'Basic functionality', ->

      it 'should retrieve all installed packages', ->
        expectedJson = testPackages

        # We need different functionality for get this time, so restore the old one
        this.storageGetStub.restore()
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