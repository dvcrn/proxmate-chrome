(function() {
  define(['chrome'], function(Chrome) {
    var copyFromChromeStorage, copyInterval, copyIntoChromeStorage, flush, get, init, internStorage, set;
    init = function() {
      return copyFromChromeStorage();
    };
    internStorage = {};
    copyInterval = null;

    /**
     * Writes the RAM storage into chrome HDD storage, after a 1 second delay
     */
    copyIntoChromeStorage = function() {
      clearInterval(copyInterval);
      return copyInterval = setTimeout(function() {
        return Chrome.storage.local.set(internStorage);
      }, 1000);
    };
    copyFromChromeStorage = function() {
      return Chrome.storage.local.get(null, function(object) {
        return internStorage = object;
      });
    };

    /**
     * Deletes all content from RAM storage
     */
    flush = function() {
      return internStorage = {};
    };

    /**
     * Returns value for 'key' from Storage
     * @return {String|Array} the value inside the storage
     */
    get = function(key) {
      return internStorage[key];
    };

    /**
     * Sets 'value' for 'key' in storage
     */
    set = function(key, value) {
      internStorage[key] = value;
      return copyIntoChromeStorage();
    };
    return {
      init: init,
      flush: flush,
      set: set,
      get: get
    };
  });

}).call(this);
