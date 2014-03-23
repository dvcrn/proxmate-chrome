'use strict'

angular.module('optionsApp', [
  'chrome'
])

angular.module('optionsApp')
  .controller 'MainCtrl', ['$scope', 'Chrome', '$http', ($scope, Chrome, $http) ->

    $scope.fetchInstalledPackages = () ->
      Chrome.getInstalledPackages((packages) ->
        $scope.installedPackages = packages
        $scope.$digest()
      )

    $scope.setDonationkey = (key, callback) ->
      Chrome.setDonationkey(key, ->
        $scope.fetchDonationkey(callback)
      )

    $scope.fetchDonationkey = (callback) ->
      Chrome.getDonationkey (key) ->
        if key?
          $scope.hasDonationkey = true
        else
          $scope.hasDonationkey = false

        $scope.donationKey = key
        $scope.$digest()


    $scope.validateKey = (key) ->
      $scope.donationKeyStatus = 'Validating key... Please wait a moment.'
      encodedKey = encodeURIComponent(key)

      $http.get("http://api.proxmate.me/user/validate/#{encodedKey}.json").success((data) ->
        if data.isValid
          $scope.donationKeyStatus = "The key you entered is valid. Thanks for donating!"
          $scope.setDonationkey(key, ->)
        else
          $scope.donationKeyStatus = data.message
      )

    $scope.clearKey = ->
      $scope.setDonationkey(null, ->
        $scope.fetchDonationkey()
      )

    $scope.hasDonationkey = false
    $scope.donationKey = ''
    $scope.donationKeyStatus = ''

    $scope.fetchInstalledPackages()
    $scope.fetchDonationkey()


    $scope.removePackage = (id, name) ->
      if (confirm("Are you sure you want to remove the package '#{name}'?"))
        Chrome.removePackage(id, ->
          $scope.fetchInstalledPackages()
        )
  ]
