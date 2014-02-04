define 'StorageMock', ->
  return {
    get: (key) ->
      return {
        'somethingThatsUpToDate': 2,
        'somethingOutdated': 1,
        'somethingWithoutUpdate': 1,
        'somethingElseOutdated': 2,
      }

    set: (key, val) ->

  }

define 'ConfigMock', ->
  return {
    get: (key) ->
      return 'www.abc.de'
  }

require.config
  map:
    'package-manager':
      'storage': 'StorageMock',
      'config': 'ConfigMock'

define [
  'package-manager',
  'StorageMock',
  'text!../testdata/packages.json',
  'text!../testdata/servers.json'
], (PackageManager, StorageMock, testPackages, testServers) ->
  testServers = JSON.parse(testServers)
  testPackages = JSON.parse(testPackages)

  describe 'Package Manager', ->
    beforeEach ->
      requests = this.requests = [];
      this.xhr = sinon.useFakeXMLHttpRequest()
      this.xhr.onCreate = (xhr) ->
        requests.push xhr

    after ->
      require.undef('StorageMock')
      require.undef('ConfigMock')
      require.config({map: {}})
      this.xhr.restore()

    describe 'The update behaviour', ->
      # Restore all stubs back to normal after each test
      afterEach ->
        for key, val of PackageManager
          if typeof PackageManager[key].restore is 'function'
            PackageManager[key].restore()

      it 'should checkForUpdates on init', ->
        spy = sinon.stub(PackageManager, 'checkForUpdates')
        PackageManager.init()
        assert.isTrue(spy.calledOnce)

      it 'should download the version overview and execute callback', ->
        callback = sinon.spy();
        PackageManager.downloadVersionRepository(callback)

        expectedPayload = {
          "1337asdf": 1,
          "anotherrandomID": 2
        }

        assert.equal(1, this.requests.length)
        assert.equal('www.abc.de/api/package/update.json', this.requests[0].url)
        this.requests[0].respond(200, {'Content-Type':'application/json'}, JSON.stringify(expectedPayload))

        assert.isTrue(callback.calledWith(expectedPayload))

      it 'should call downloadVersionRepository and install outdated packages', ->
        testVersionJson = {
          'somethingThatsUpToDate': 2,
          'somethingOutdated': 2
          'somethingElseOutdated': 3
        }

        downloadVersionRepositoryStub = sinon.stub(PackageManager, "downloadVersionRepository", (callback) ->
          callback testVersionJson
        )

        # InstalledPackage should get called after finding outdated packages
        installPackageStub = sinon.stub(PackageManager, "installPackage")

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

        StorageSetMock = sinon.stub(StorageMock, 'set')
        StorageGetMock = sinon.spy(StorageMock, 'get')

        PackageManager.installPackage(pkgId)

        assert.equal(1, this.requests.length)
        assert.equal("www.abc.de/api/package/#{pkgId}.json", this.requests[0].url)
        this.requests[0].respond(200, {'Content-Type':'application/json'}, JSON.stringify(pkgInfo))

        assert.isTrue(StorageGetMock.calledOnce)
        assert.isTrue(StorageSetMock.calledTwice)

        assert.isTrue(StorageGetMock.calledWith('installed_packages'))

        assert.isTrue(StorageSetMock.calledWith(pkgId, pkgInfo), 'The Storage got called with the correct ID and payload')
        assert.isTrue(StorageSetMock.calledWith('installed_packages', newInstalledPackageObject), 'The new package ID got added in the installed_packages array')

        StorageSetMock.restore()
        StorageGetMock.restore()

    describe 'Basic functionality', ->

      it 'should retrieve all installed packages', ->
        expectedJson = testPackages

        StorageGetMock = sinon.stub(StorageMock, 'get', (key) ->
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