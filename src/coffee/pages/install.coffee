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
  .controller 'InstallCtrl', ['$scope', '$route', '$routeParams', ($scope, $route, $routeParams) ->
    $scope.asdf = 123
  ]