'use strict'

angular.module('proxmateApp', [
  'ngRoute',
  'chrome'
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
  .controller 'InstallCtrl', ['$scope', 'Chrome', '$routeParams', ($scope, Chrome, $routeParams) ->
    $scope.status = 'Installing...'

    Chrome.installPackage($routeParams.packageId, (response) ->
      if response.success
        $scope.status = 'Installed successfully!'
        $scope.$digest()
    )
  ]