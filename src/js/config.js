(function() {
  define(['text!../../proxmate.json'], function(configJson) {
    var config, get, init;
    config = {};
    init = function() {
      return config = JSON.parse(configJson);
    };

    /**
     * Return config content for key 'key'
     * @param  {String} key the key
     * @return {Mixed}     Whatever is written in the config
     */
    get = function(key) {
      return config[key];
    };
    return {
      init: init,
      get: get
    };
  });

}).call(this);
