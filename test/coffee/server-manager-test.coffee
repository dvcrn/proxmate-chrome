define ['server-manager', 'storage', 'text!../testdata/servers.json'], (ServerManager, Storage, testServers) ->
  testServers = JSON.parse(testServers)

  describe 'Server Manager', ->
    beforeEach ->
      this.sandbox = sinon.sandbox.create()
      this.storageStub = this.sandbox.stub(Storage, 'get', ->
        return testServers
      )

    afterEach ->
      this.sandbox.restore()

    describe 'Initialisation', ->
      it 'should call loadServersFromStorage and fetchServerList on init', ->
        stubs = [
          this.sandbox.stub(ServerManager, 'loadServersFromStorage')
          this.sandbox.stub(ServerManager, 'fetchServerList')
        ]

        ServerManager.init()

        for stub in stubs
          assert.isTrue(stub.calledOnce, 'called correct function on init')

      it 'should read the server configuration from local storage', ->
        ServerManager.loadServersFromStorage()

        assert.isTrue(this.storageStub.calledOnce)
        assert.isTrue(this.storageStub.calledWith('server_config'))

      it 'should ajax load the server list', ->
