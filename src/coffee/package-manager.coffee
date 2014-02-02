define ['storage', 'config', 'jquery'], (StorageManager, ConfigProvider, $) ->
  init = ->
    exports.checkForUpdates()

  ###*
   * Downloads a list containing of ID and version
   * @param  {Function} callback callback to pass json on
  ###
  downloadVersionRepository = (callback) ->
    server = ConfigProvider.get('primary_server')
    updateUrl = "#{server}/api/package/update.json"

    $.get updateUrl, (data) ->
      callback(data)

  ###*
   * Queries the primary server and checks for updates
  ###
  checkForUpdates = ->
    exports.downloadVersionRepository (versionRepository) ->
      installedPackages = StorageManager.get('installed_packages')
      # Compare and check for available updates
      for key, val of installedPackages
        # Check if the key exists in the downloaded list
        if key of versionRepository
          if versionRepository[key] > val
            exports.installPackage(key)

  ###*
   * Installs / overrides package for key 'key'
   * @param  {String} key package identifier
  ###
  installPackage = (key) ->
    server = ConfigProvider.get('primary_server')
    packageUrl = "#{server}/api/package/#{key}.json"
    $.get packageUrl, (packageData) ->
      # Query existing installed packages and add the new version / id
      installedPackages = StorageManager.get('installed_packages')
      installedPackages[key] = packageData['version']

      StorageManager.set(key, packageData)
      StorageManager.set('installed_packages', installedPackages)


  exports = {
    init: init
    checkForUpdates: checkForUpdates
    downloadVersionRepository: downloadVersionRepository
    installPackage: installPackage
  }

  return exports