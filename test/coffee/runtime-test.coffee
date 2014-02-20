define [
  'runtime'
  'package-manager',
  'server-manager',
  'proxy-manager'
], (Runtime, PackageManager, ServerManager, ProxyManager) ->

  describe 'Runtime ', ->
    beforeEach ->
      this.sandbox = sinon.sandbox.create()

    afterEach ->
      this.sandbox.restore()

    describe 'start', ->
      it 'should do nothing if no servers or packages are available', ->
        getInstalledPackagesStub = this.sandbox.stub(PackageManager, 'getInstalledPackages', ->
          return []
        )

        getServersStub = this.sandbox.stub(ServerManager, 'getServers', ->
          return []
        )

        generatePacStub = this.sandbox.stub(ProxyManager, 'generateProxyAutoconfigScript')
        setPacStub = this.sandbox.stub(ProxyManager, 'setProxyAutoconfig')

        Runtime.start()

        assert.isTrue(getInstalledPackagesStub.calledOnce)
        assert.isTrue(getServersStub.calledOnce)

        assert.isFalse(generatePacStub.calledOnce)
        assert.isFalse(setPacStub.calledOnce)

      it 'should generate and set pac if packages and servers are available', ->
        getInstalledPackagesStub = this.sandbox.stub(PackageManager, 'getInstalledPackages', ->
          return [1]
        )

        getServersStub = this.sandbox.stub(ServerManager, 'getServers', ->
          return [1,2,3]
        )

        generatePacStub = this.sandbox.stub(ProxyManager, 'generateProxyAutoconfigScript')
        setPacStub = this.sandbox.stub(ProxyManager, 'setProxyAutoconfig')

        Runtime.start()

        assert.isTrue(getInstalledPackagesStub.calledOnce)
        assert.isTrue(getServersStub.calledOnce)

        assert.isTrue(generatePacStub.calledOnce)
        assert.isTrue(setPacStub.calledOnce)

      it 'should call start on restart', ->
        stub = this.sandbox.stub(Runtime, 'start')
        Runtime.restart()

        assert.isTrue(stub.calledOnce)
