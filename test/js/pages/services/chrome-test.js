// Generated by CoffeeScript 1.7.1
(function() {
  'use strict';
  describe('Factory: chrome', function() {
    var chrome, runtimeSpy;
    beforeEach(module('chrome'));
    runtimeSpy = jasmine.createSpyObj('runtime', ['sendMessage']);
    runtimeSpy.sendMessage.andCallFake(function(config, callback) {
      return callback('some callback string');
    });
    window.chrome = {
      runtime: runtimeSpy
    };
    chrome = {};
    beforeEach(inject(function(_Chrome_) {
      return chrome = _Chrome_;
    }));
    it('installPackage should create the correct message for backend', function() {
      var callback;
      callback = jasmine.createSpy('callback spy');
      chrome.installPackage(123, callback);
      expect(runtimeSpy.sendMessage).toHaveBeenCalledWith({
        action: 'installPackage',
        params: {
          packageId: 123
        }
      }, jasmine.any(Function));
      return expect(callback).toHaveBeenCalledWith('some callback string');
    });
    it('getProxmateGlobalStatus should create the correct message for backend', function() {
      var callback;
      callback = jasmine.createSpy('callback spy');
      chrome.getProxmateStatus(callback);
      expect(runtimeSpy.sendMessage).toHaveBeenCalledWith({
        action: 'getProxmateGlobalStatus',
        params: {}
      }, jasmine.any(Function));
      return expect(callback).toHaveBeenCalledWith('some callback string');
    });
    return it('should create the correct message for activate/deactivate proxmate', function() {
      var callback;
      callback = jasmine.createSpy('callback spy');
      chrome.setProxmateStatus(true, callback);
      expect(runtimeSpy.sendMessage).toHaveBeenCalledWith({
        action: 'setProxmateGlobalStatus',
        params: {
          newStatus: true
        }
      }, jasmine.any(Function));
      expect(callback).toHaveBeenCalledWith('some callback string');
      callback = jasmine.createSpy('callback spy');
      chrome.setProxmateStatus(false, callback);
      expect(runtimeSpy.sendMessage).toHaveBeenCalledWith({
        action: 'setProxmateGlobalStatus',
        params: {
          newStatus: false
        }
      }, jasmine.any(Function));
      return expect(callback).toHaveBeenCalledWith('some callback string');
    });
  });

}).call(this);