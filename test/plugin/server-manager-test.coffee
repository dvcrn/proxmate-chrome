{ServerManager} = require '../../src/server-manager'
{Config} = require '../../src/config'
{Storage} = require '../../src/storage'
{Browser} = require '../../src/browser'

testServers = require '../testdata/servers.json'

describe 'Server Manager', ->
  beforeEach ->
    this.sandbox = sinon.sandbox.create()
    this.storageStub = this.sandbox.stub(Storage, 'get', ->
      return testServers
    )

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

      this.storageStub.restore()
      storageGetStub = this.sandbox.stub(Storage, 'get', ->
        return null
      )

      callback = this.sandbox.spy()
      storageSetStub = this.sandbox.stub(Storage, 'set')

      xhrMock = this.sandbox.stub(Browser, 'xhr').callsArgWith(2, testServers)
      ServerManager.fetchServerList(callback)

      assert.isTrue(configGetStub.calledWith('primary_server'))
      assert.isTrue(xhrMock.calledOnce)
      assert.isTrue(xhrMock.calledWith('www.abc.de/server/list.json'))

      assert.isTrue(callback.calledOnce)
      assert.isTrue(storageSetStub.calledWith('server_config', testServers))
      assert.deepEqual(testServers, ServerManager.getServers())
      assert.isTrue(storageGetStub.calledOnce)

    it 'should attach donation key if available', ->
      configGetStub = this.sandbox.stub(Config, 'get', ->
        return 'www.abc.de'
      )

      this.storageStub.restore()
      storageGetStub = this.sandbox.stub(Storage, 'get', ->
        return 'foo'
      )

      callback = this.sandbox.spy()
      storageSetStub = this.sandbox.stub(Storage, 'set')

      xhrMock = this.sandbox.stub(Browser, 'xhr').callsArgWith(2, testServers)
      ServerManager.fetchServerList(callback)

      assert.isTrue(configGetStub.calledWith('primary_server'))
      assert.isTrue(xhrMock.calledOnce)
      assert.isTrue(xhrMock.calledWith('www.abc.de/server/list.json?key=foo'))

      assert.isTrue(storageGetStub.calledOnce)
