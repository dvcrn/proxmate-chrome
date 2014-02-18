define ['event-binder', 'chrome', 'package-manager'], (EventBinder, Chrome, PackageManager) ->
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