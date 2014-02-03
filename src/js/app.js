(function() {
  require.config({
    paths: {
      "text": "../../bower_components/requirejs-text/text",
      "jquery": "../../bower_components/jquery/jquery"
    }
  });

  (function() {
    return require(['config', 'package-manager', 'storage'], function(Config, PackageManager, Storage) {
      Config.init();
      Storage.init();
      return PackageManager.init();
    });
  })();

}).call(this);
