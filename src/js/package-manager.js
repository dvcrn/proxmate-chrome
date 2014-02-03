(function() {
  define(['storage', 'config', 'jquery'], function(StorageManager, ConfigProvider, $) {
    var checkForUpdates, downloadVersionRepository, exports, getInstalledPackages, init, installPackage;
    init = function() {
      return exports.checkForUpdates();
    };

    /**
     * Downloads a list containing of ID and version
     * @param  {Function} callback callback to pass json on
     */
    downloadVersionRepository = function(callback) {
      var server, updateUrl;
      server = ConfigProvider.get('primary_server');
      updateUrl = "" + server + "/api/package/update.json";
      return $.get(updateUrl, function(data) {
        return callback(data);
      });
    };

    /**
     * Queries the primary server and checks for updates
     */
    checkForUpdates = function() {
      return exports.downloadVersionRepository(function(versionRepository) {
        var installedPackages, key, val, _results;
        installedPackages = StorageManager.get('installed_packages');
        _results = [];
        for (key in installedPackages) {
          val = installedPackages[key];
          if (key in versionRepository) {
            if (versionRepository[key] > val) {
              _results.push(exports.installPackage(key));
            } else {
              _results.push(void 0);
            }
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
    };

    /**
     * Installs / overrides package for key 'key'
     * @param  {String} key package identifier
     */
    installPackage = function(key) {
      var packageUrl, server;
      server = ConfigProvider.get('primary_server');
      packageUrl = "" + server + "/api/package/" + key + ".json";
      return $.get(packageUrl, function(packageData) {
        var installedPackages;
        installedPackages = StorageManager.get('installed_packages');
        installedPackages[key] = packageData['version'];
        StorageManager.set(key, packageData);
        return StorageManager.set('installed_packages', installedPackages);
      });
    };

    /**
     * Returns all installed packages with their package contents
     * @return {Object} packages
     */
    getInstalledPackages = function() {
      var id, installedPackages, packageJson, version;
      installedPackages = StorageManager.get('installed_packages');
      packageJson = [];
      for (id in installedPackages) {
        version = installedPackages[id];
        packageJson.push(StorageManager.get(id));
      }
      return packageJson;
    };
    exports = {
      init: init,
      checkForUpdates: checkForUpdates,
      downloadVersionRepository: downloadVersionRepository,
      installPackage: installPackage,
      getInstalledPackages: getInstalledPackages
    };
    return exports;
  });

}).call(this);
