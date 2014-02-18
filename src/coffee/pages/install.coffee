'use strict'

angular.module('proxmateApp', [
  'ngRoute'
])
  .config ($locationProvider, $routeProvider) ->
    $locationProvider.hashPrefix('!')

    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/install/:packageId',
        templateUrl: 'views/install.html'
        controller: 'InstallCtrl'
      .otherwise redirectTo: '/'

angular.module('proxmateApp')
  .controller 'MainCtrl', ['$scope', '$route', '$routeParams', ($scope) ->]

angular.module('proxmateApp')
  .controller 'InstallCtrl', ['$scope', 'chrome', '$routeParams', ($scope, chrome, $routeParams) ->
    $scope.status = 'Installing...'

    chrome.installPackage($routeParams.packageId, (response) ->
      if response.success
        $scope.status = 'Installed successfully!'
        $scope.$digest()
    )
  ]