# The testsuite
define ['storage', 'chrome'], (StorageModule, Chrome) ->
  describe 'Storage', ->

    beforeEach ->
      this.sandbox = sinon.sandbox.create()
      this.storageSetStub = this.sandbox.stub(Chrome.storage.local, 'set')
      this.storageGetStub = this.sandbox.stub(Chrome.storage.local, 'get')

      this.clock = this.sandbox.useFakeTimers()

    afterEach ->
      this.sandbox.restore()

    # Testing flush first, since it will be used in all other tests here
    describe 'Testing flush', ->
      StorageModule.set('123', 5678)
      StorageModule.flush()
      assert.equal(null, StorageModule.get('123'))

    describe 'Testing get/set', ->
      afterEach ->
        StorageModule.flush()

      it 'should set and return values correctly', ->
        testValue = 12345
        testArray = [1,2,3,4,5]
        testString = '12345asdf'

        StorageModule.set('test', testValue)
        assert.equal(testValue, StorageModule.get('test'))

        StorageModule.set('test', testArray)
        assert.equal(testArray, StorageModule.get('test'))

        StorageModule.set('test', testString)
        assert.equal(testString, StorageModule.get('test'))

      it 'should return null on missing keys', ->
        assert.equal(null, StorageModule.get('abcasdfasdfasdfkasdfjasdf'))

      it 'should call chrome.storage.local after 1000 ms', ->
        StorageModule.set(123, 'hallo')
        StorageModule.set(456, 'wuhu')

        # Check if the storage function has been called alrady
        assert.isFalse(this.storageSetStub.calledOnce)

        this.clock.tick(1000)
        expectedPayload =
          123: 'hallo'
          456: 'wuhu'

        assert.isTrue(this.storageSetStub.calledWith(expectedPayload))

      it 'should init the module correctly', ->
        expectedStorageContent =
          123: 456
          'asdf': 'muh'
          8888: 9999999

        this.storageGetStub.restore()
        stub = this.sandbox.stub(Chrome.storage.local, 'get', (key, callback) ->
          callback expectedStorageContent
        )

        callback = this.sandbox.spy()
        StorageModule.init(callback)

        assert.isTrue(callback.calledOnce, 'Callback executed correctly')
        assert.isTrue(stub.calledOnce)
        assert.equal(456, StorageModule.get(123))
        assert.equal('muh', StorageModule.get('asdf'))
        assert.equal(9999999, StorageModule.get(8888))

        # If we didn't have global_status in the storage yet, it should be true
        assert.equal(true, StorageModule.get('global_status'))

    describe 'Testing Remove', ->
      it 'should remove a key correctly and write into chrome storage', ->
        StorageModule.set('asdf', 123)
        StorageModule.set('asdf2', 123)
        StorageModule.set('asdf3', 123)

        assert.equal(123, StorageModule.get('asdf'))
        assert.equal(123, StorageModule.get('asdf2'))
        assert.equal(123, StorageModule.get('asdf3'))

        StorageModule.remove('asdf')
        assert.equal(null, StorageModule.get('asdf'))
        assert.equal(123, StorageModule.get('asdf2'))
        assert.equal(123, StorageModule.get('asdf3'))

        this.clock.tick(1000)
        assert.isTrue(this.storageSetStub.calledWith({'asdf2': 123, 'asdf3': 123}))
