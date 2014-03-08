define [
  'runtime'
  'package-manager',
  'server-manager',
  'proxy-manager',
  'storage',
  'chrome'
], (Runtime, PackageManager, ServerManager, ProxyManager, Storage, Chrome) ->

  describe 'Runtime ', ->
    beforeEach ->
      this.sandbox = sinon.sandbox.create()

    afterEach ->
      this.sandbox.restore()

    describe 'start', ->
      it 'should do nothing if no servers are available', ->
        getInstalledPackagesStub = this.sandbox.stub(PackageManager, 'getInstalledPackages', ->
          return [1,2,3]
        )

        getServersStub = this.sandbox.stub(ServerManager, 'getServers', ->
          return []
        )

        storageGetStub = this.sandbox.stub(Storage, 'get', (key) ->
          if key is 'global_status'
            return true
        )

        generatePacStub = this.sandbox.stub(ProxyManager, 'generateProxyAutoconfigScript')
        setPacStub = this.sandbox.stub(ProxyManager, 'setProxyAutoconfig')
        chromeBadgeTextStub = this.sandbox.stub(Chrome.browserAction, 'setBadgeText')

        Runtime.start()

        assert.isTrue(getInstalledPackagesStub.calledOnce)
        assert.isTrue(getServersStub.calledOnce)

        assert.isFalse(chromeBadgeTextStub.calledOnce)
        assert.isFalse(generatePacStub.calledOnce)
        assert.isFalse(setPacStub.calledOnce)

      it 'should change the badgeText when no packages are available and do nothing', ->
        getInstalledPackagesStub = this.sandbox.stub(PackageManager, 'getInstalledPackages', ->
          return []
        )

        getServersStub = this.sandbox.stub(ServerManager, 'getServers', ->
          return [1,2,3]
        )

        storageGetStub = this.sandbox.stub(Storage, 'get', (key) ->
          if key is 'global_status'
            return true
        )

        generatePacStub = this.sandbox.stub(ProxyManager, 'generateProxyAutoconfigScript')
        setPacStub = this.sandbox.stub(ProxyManager, 'setProxyAutoconfig')
        chromeBadgeTextStub = this.sandbox.stub(Chrome.browserAction, 'setBadgeText')

        Runtime.start()

        assert.isTrue(getInstalledPackagesStub.calledOnce)
        assert.isTrue(getServersStub.calledOnce)

        # Browser text got changed
        assert.isTrue(chromeBadgeTextStub.calledWith({text: "None"}))

        # It shouldn't do anything other than that
        assert.isFalse(generatePacStub.calledOnce)
        assert.isFalse(setPacStub.calledOnce)

      it 'should do nothing and call stop() if global_status is set to false', ->
        getInstalledPackagesStub = this.sandbox.stub(PackageManager, 'getInstalledPackages', ->
          return []
        )

        getServersStub = this.sandbox.stub(ServerManager, 'getServers', ->
          return []
        )

        storageGetStub = this.sandbox.stub(Storage, 'get', (key) ->
          if key is 'global_status'
            return false
        )

        stopStub = this.sandbox.stub(Runtime, 'stop')

        generatePacStub = this.sandbox.stub(ProxyManager, 'generateProxyAutoconfigScript')
        setPacStub = this.sandbox.stub(ProxyManager, 'setProxyAutoconfig')

        Runtime.start()

        assert.isFalse(getInstalledPackagesStub.calledOnce)
        assert.isFalse(getServersStub.calledOnce)

        assert.isFalse(generatePacStub.calledOnce)
        assert.isFalse(setPacStub.calledOnce)

        assert.isTrue(stopStub.calledOnce)


      it 'should generate and set pac if packages and servers are available', ->
        getInstalledPackagesStub = this.sandbox.stub(PackageManager, 'getInstalledPackages', ->
          return [1]
        )

        getServersStub = this.sandbox.stub(ServerManager, 'getServers', ->
          return [1,2,3]
        )

        storageGetStub = this.sandbox.stub(Storage, 'get', (key) ->
          if key is 'global_status'
            return true
        )

        generatePacStub = this.sandbox.stub(ProxyManager, 'generateProxyAutoconfigScript')
        setPacStub = this.sandbox.stub(ProxyManager, 'setProxyAutoconfig')
        chromeBadgeTextStub = this.sandbox.stub(Chrome.browserAction, 'setBadgeText')

        Runtime.start()

        assert.isTrue(getInstalledPackagesStub.calledOnce)
        assert.isTrue(getServersStub.calledOnce)
        assert.isTrue(chromeBadgeTextStub.calledWith({text: ""}))

        assert.isTrue(generatePacStub.calledOnce)
        assert.isTrue(setPacStub.calledOnce)

      it 'should call start on restart', ->
        stub = this.sandbox.stub(Runtime, 'start')
        Runtime.restart()

        assert.isTrue(stub.calledOnce)

      it 'should reset the proxy on stop', ->
        clearProxyStub = this.sandbox.stub(ProxyManager, 'clearProxy')
        Runtime.stop()
        assert.isTrue(clearProxyStub.calledOnce)