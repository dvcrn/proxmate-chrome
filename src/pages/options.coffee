'use strict'

angular.module('optionsApp', [
  'chrome'
])

angular.module('optionsApp')
  .controller 'MainCtrl', ['$scope', 'Chrome', ($scope, Chrome) ->

    $scope.fetchInstalledPackages = () ->
      console.info 'asdf'
      Chrome.getInstalledPackages((packages) ->
        $scope.installedPackages = packages
        console.info packages
        $scope.$digest()
      )
    $scope.fetchInstalledPackages()

    $scope.removePackage = (id, name) ->
      if (confirm("Are you sure you want to remove the package '#{name}'?"))
        Chrome.removePackage(id, ->
          $scope.fetchInstalledPackages()
        )
  ]
