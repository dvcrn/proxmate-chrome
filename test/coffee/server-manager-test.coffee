define ['server-manager', 'config', 'storage', 'text!../testdata/servers.json'], (ServerManager, Config, Storage, testServers) ->
  testServers = JSON.parse(testServers)

  describe 'Server Manager', ->
    beforeEach ->
      this.sandbox = sinon.sandbox.create()
      this.storageStub = this.sandbox.stub(Storage, 'get', ->
        return testServers
      )

      this.xhr = this.sandbox.useFakeXMLHttpRequest()

    afterEach ->
      this.sandbox.restore()

    describe 'Initialisation', ->
      it 'should initialise the manager correctly', ->

        loadServersSpy = this.sandbox.spy(ServerManager, 'loadServersFromStorage')
        fetchServersStub = this.sandbox.stub(ServerManager, 'fetchServerList')
        callback = this.sandbox.spy()

        ServerManager.init(callback)

        # First test - We have servers in storage, don't call fetchServerList
        assert.isTrue(loadServersSpy.calledOnce)
        assert.isTrue(fetchServersStub.called)
        assert.isTrue(callback.calledOnce)

        # Second test, this time no servers will get returned from the storage.
        # The manager should call fetchServerList and return the fetched content
        loadServersSpy.restore()
        loadServersSpy = this.sandbox.spy(ServerManager, 'loadServersFromStorage')

        fetchServersStub.restore()
        fetchServersStub = this.sandbox.stub(ServerManager, 'fetchServerList')

        this.storageStub.restore()
        this.storageStub = this.sandbox.stub(Storage, 'get', ->
          return null;
        )

        callback = this.sandbox.spy()
        ServerManager.init(callback)

        assert.isTrue(loadServersSpy.calledOnce)
        assert.isTrue(fetchServersStub.calledOnce)
        assert.isTrue(fetchServersStub.calledWith(callback))

      it 'should read the server configuration from local storage', ->
        servers = ServerManager.loadServersFromStorage()

        assert.isTrue(this.storageStub.calledOnce)
        assert.isTrue(this.storageStub.calledWith('server_config'))
        assert.deepEqual(testServers, servers)

        this.storageStub.restore()
        this.storageStub = this.sandbox.stub(Storage, 'get', ->
          return null;
        )

        servers = ServerManager.loadServersFromStorage()
        assert.deepEqual([], servers)

      it 'should return servers correctly', ->
        ServerManager.loadServersFromStorage()
        servers = ServerManager.getServers()

        assert.deepEqual(testServers, servers)

      it 'should ajax load the server list correctly and save in storage', ->
          configGetStub = this.sandbox.stub(Config, 'get', ->
            return 'www.abc.de'
          )

          callback = this.sandbox.spy()
          storageSetStub = this.sandbox.stub(Storage, 'set')

          ServerManager.fetchServerList(callback)

          assert.isTrue(configGetStub.calledWith('primary_server'))
          assert.equal(1, this.sandbox.server.requests.length)
          assert.equal("www.abc.de/api/server/list.json", this.sandbox.server.requests[0].url)

          this.sandbox.server.requests[0].respond(200, {'Content-Type':'application/json'}, JSON.stringify(testServers))

          assert.isTrue(callback.calledOnce)
          assert.isTrue(storageSetStub.calledWith('server_config', testServers))
          assert.deepEqual(testServers, ServerManager.getServers())
