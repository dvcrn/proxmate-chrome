'use strict'

angular.module('proxmateApp', [
  'ngRoute',
  'chrome'
])
  .config ($locationProvider, $routeProvider, $compileProvider) ->
    $locationProvider.hashPrefix('!')
    $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|chrome-extension):/)

    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/confirm/:method/:packageId',
        templateUrl: 'views/confirm.html'
        controller: 'ConfirmCtrl'
      .when '/install/:packageId',
        templateUrl: 'views/install.html'
        controller: 'InstallCtrl'
      .otherwise redirectTo: '/'

angular.module('proxmateApp')
  .controller 'MainCtrl', ['$scope', '$route', '$routeParams', '$window', ($scope, $route, $routeParams, $window) ->
    $window.close()
  ]

angular.module('proxmateApp')
  .controller 'InstallCtrl', ['$scope', 'Chrome', '$routeParams', ($scope, Chrome, $routeParams) ->
    $scope.status = 'Installing...'

    Chrome.installPackage($routeParams.packageId, (response) ->
      if response.success
        $scope.status = 'Installed successfully!'
        $scope.$digest()
      else
        $scope.status = response.message
        $scope.$digest()
    )
]

angular.module('proxmateApp')
  .controller 'ConfirmCtrl', ['$rootScope', '$routeParams', '$http', ($rootScope, $routeParams, $http) ->
    $rootScope.method = $routeParams.method
    $http.get("http://api.proxmate.me/package/#{$routeParams.packageId}.json").success (data) ->
      $rootScope.packageData = data
]

