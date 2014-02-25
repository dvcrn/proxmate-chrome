'use strict'

angular.module('popupApp', [
  'chrome'
])

angular.module('popupApp')
  .controller 'MainCtrl', ['$scope', 'Chrome', ($scope, Chrome) ->

    $scope.updateProxmateStatus = ->
      Chrome.getProxmateStatus((response) ->
        $scope.proxmateStatus = response
        $scope.$digest()
      )
    $scope.updateProxmateStatus()

    $scope.deactivateProxmate = ->
      Chrome.setProxmateStatus(false, ->
        $scope.updateProxmateStatus()
      )

    $scope.activateProxmate = ->
      Chrome.setProxmateStatus(true, ->
        $scope.updateProxmateStatus()
      )
  ]