{Storage} = require './storage'
{Config} = require './config'
{Browser} = require './browser'

class PackageManager
  init: ->
    @checkForUpdates()

  ###*
   * Downloads a list containing of ID and version
   * @param  {Function} callback callback to pass json on
  ###
  downloadVersionRepository: (callback) ->
    donationKey = Storage.get('donation_key')
    server = Config.get('primary_server')
    updateUrl = "#{server}/package/update.json"
    if donationKey?
      donationKey = encodeURIComponent(donationKey)
      updateUrl = "#{server}/package/update.json?key=#{donationKey}"

    Browser.xhr(updateUrl, 'GET', (data) ->
      callback(data)
    )

  ###*
   * Queries the primary server and checks for updates
  ###
  checkForUpdates: ->
    @downloadVersionRepository (versionRepository) =>
      installedPackages = Storage.get('installed_packages')
      # Compare and check for available updates
      for key, val of installedPackages
        # Check if the key exists in the downloaded list
        if key of versionRepository
          # If the version on the server is higher, reinstall the package
          if versionRepository[key] > val
            @installPackage(key)
          # -1 implied that the package is no longer available and marked for delete
          if versionRepository[key] == -1
            @removePackage(key)

  ###*
   * Installs / overrides package for key 'key'
   * @param  {String} key package identifier
   * @param {Function} callback callback function
  ###
  installPackage: (key, callback) ->
    callback = callback || ->

    server = Config.get('primary_server')

    donationKey = Storage.get('donation_key')
    packageUrl = "#{server}/package/#{key}/install.json"
    if donationKey?
      donationKey = encodeURIComponent(donationKey)
      packageUrl = "#{server}/package/#{key}/install.json?key=#{donationKey}"

    Browser.xhr packageUrl, 'GET', (packageData) ->
      # Query existing installed packages and add the new version / id
      installedPackages = Storage.get('installed_packages')
      if not installedPackages
        installedPackages = {}

      installedPackages[key] = packageData['version']

      Storage.set(key, packageData)
      Storage.set('installed_packages', installedPackages)

      {Runtime} = require('./runtime')
      Runtime.restart()
      callback({success: true})
    , (xhr) ->
      switch xhr.status
        when 401
          callback {success: false, message: xhr.responseJSON.message}
          return
        when 404
          callback {success: false, message: "The package you tried to install doesn't exist..."}
          return
        else
          callback {success: false, message: 'There was a problem installing this package.'}

  ###*
   * Returns all installed packages with their package contents
   * @return {Object} packages
  ###
  getInstalledPackages: ->
    # Query storage for all installed packages
    installedPackages = Storage.get('installed_packages')
    packageJson = []
    for id, version of installedPackages
      packageJson.push(Storage.get(id))

    return packageJson

  ###*
   * Removes a installed package
   * @param  {String} key package id
  ###
  removePackage: (key) ->
    # Kick the package out of the storage
    Storage.remove(key)
    # Remove it from versions array
    installedPackages = Storage.get('installed_packages')
    delete installedPackages[key]
    Storage.set('installed_packages', installedPackages)
    {Runtime} = require('./runtime')
    Runtime.restart()

exports.PackageManager = new PackageManager()
