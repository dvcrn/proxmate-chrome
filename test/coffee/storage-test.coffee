# Mock for chrome dependency

define 'ChromeMock', ->
  return {
    storage:
      local:
        set: (obj) ->
        get: (key, callback) ->
  }

require.config
  map:
    'storage':
      'chrome': 'ChromeMock'

# The testsuite
define ['storage', 'ChromeMock'], (StorageModule, ChromeMock) ->
  describe 'Storage', ->

    after ->
      require.config({map: {}})
      require.undef('ChromeMock')

    # Testing flush first, since it will be used in all other tests here
    describe 'Testing flush', ->
      StorageModule.set('123', 5678)
      StorageModule.flush()
      assert.equal(null, StorageModule.get('123'))

    describe 'Testing get/set', ->
      beforeEach ->
        this.clock = sinon.useFakeTimers()

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
        spy = sinon.spy(ChromeMock.storage.local, 'set')
        StorageModule.set(123, 'hallo')
        StorageModule.set(456, 'wuhu')

        # Check if the storage function has been called alrady
        assert.isFalse(spy.calledOnce)

        this.clock.tick(1000)
        expectedPayload =
          123: 'hallo'
          456: 'wuhu'

        assert.isTrue(spy.calledWith(expectedPayload))

      it 'should sync chrome storage on init into RAM', ->
        expectedStorageContent =
          123: 456
          'asdf': 'muh'
          8888: 9999999

        stub = sinon.stub(ChromeMock.storage.local, 'get', (key, callback) ->
          callback expectedStorageContent
        )

        callback = sinon.spy()
        StorageModule.init(callback)

        assert.isTrue(callback.calledOnce, 'Callback executed correctly')
        assert.isTrue(stub.calledOnce)
        assert.equal(456, StorageModule.get(123))
        assert.equal('muh', StorageModule.get('asdf'))
        assert.equal(9999999, StorageModule.get(8888))