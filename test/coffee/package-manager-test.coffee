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

define ['package-manager', 'StorageMock'], (PackageManager, StorageMock) ->
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
        pkgInfo =
          {
            "name": "Test Package",
            "version": 100,
            "url": "http://pandora.com",
            "user": "52e51a98217d32e2270e211f",
            "country": "52e5c40294ed6bd4032daa49",
            "_id": "52e5c59e18bf010c04b0ef9e",
            "__v": 0,
            "createdAt": "2014-01-27T02:34:06.874Z",
            "routeRegex": [
              "host == 'www.pandora.com'"
            ],
            "hosts": [
              "pandora.com",
              "*.pandora.com"
            ]
          }

        newInstalledPackageObject = {
          'somethingThatsUpToDate': 2,
          'somethingOutdated': 100,
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

        assert.isTrue(StorageSetMock.calledWith(pkgId, pkgInfo))
        assert.isTrue(StorageSetMock.calledWith('installed_packages', newInstalledPackageObject))
