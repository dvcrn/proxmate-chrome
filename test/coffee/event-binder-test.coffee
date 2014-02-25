define ['event-binder', 'chrome', 'package-manager', 'storage'], (EventBinder, Chrome, PackageManager, Storage) ->
  describe 'Event Binder ', ->

    beforeEach ->
      this.sandbox = sinon.sandbox.create()

    afterEach ->
      this.sandbox.restore()

    it 'shold bind chrome message events on init', ->
      bindMessageEventStub = this.sandbox.stub(Chrome.runtime.onMessage, 'addListener')
      messageListenerStub = this.sandbox.stub(EventBinder, 'messageListener')
      EventBinder.init()

      assert.isTrue(bindMessageEventStub.calledWith(messageListenerStub))

    describe 'event behaviour', ->
      it 'should call packageManager.installpackage on installPackage event', ->
        callback = this.sandbox.spy()
        installPackageStub = this.sandbox.stub(PackageManager, 'installPackage', (id, callback) ->
          callback()
        )

        flag = EventBinder.messageListener({action: 'installPackage', params: {packageId: 'asdf'}}, {}, callback)

        assert.isTrue(flag)
        assert.isTrue(installPackageStub.calledWith('asdf'))
        assert.isTrue(callback.calledOnce)

      it 'should retrieve storage content on getProxmateGlobalStatus event', ->
        callback = this.sandbox.spy()
        storageGetStub = this.sandbox.stub(Storage, 'get', (key) -> return true)

        flag = EventBinder.messageListener({action: 'getProxmateGlobalStatus', params: {}}, {}, callback)

        assert.isTrue(storageGetStub.calledWith('global_status'))
        assert.isTrue(callback.calledWith(true))

        # Storage not defined yet
        storageGetStub.restore()
        callback = this.sandbox.spy()
        storageGetStub = this.sandbox.stub(Storage, 'get', (key) ->
          return null
        )

        flag = EventBinder.messageListener({action: 'getProxmateGlobalStatus', params: {}}, {}, callback)

        assert.isTrue(storageGetStub.calledWith('global_status'))
        assert.isTrue(callback.calledWith(false))


      it 'should set the proxmate status correctly on setProxmateGlobalStatus', ->
        callback = this.sandbox.spy()
        storageSetStub = this.sandbox.stub(Storage, 'set')

        # True
        flag = EventBinder.messageListener({action: 'setProxmateGlobalStatus', params: {newStatus: true}}, {}, callback)
        assert.isTrue(storageSetStub.calledWith('global_status', true))
        assert.isTrue(callback.calledOnce)

        storageSetStub.restore()
        callback = this.sandbox.spy()
        storageSetStub = this.sandbox.stub(Storage, 'set')

        # False
        flag = EventBinder.messageListener({action: 'setProxmateGlobalStatus', params: {newStatus: false}}, {}, callback)
        assert.isTrue(storageSetStub.calledWith('global_status', false))
        assert.isTrue(callback.calledOnce)

        storageSetStub.restore()
        callback = this.sandbox.spy()
        storageSetStub = this.sandbox.stub(Storage, 'set')

        # something not bool
        flag = EventBinder.messageListener({action: 'setProxmateGlobalStatus', params: {newStatus: 'asdf'}}, {}, callback)
        assert.isTrue(storageSetStub.calledWith('global_status', false))
        assert.isTrue(callback.calledOnce)