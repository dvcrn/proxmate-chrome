'use strict'

angular.module('optionsApp', [
  'chrome'
])

angular.module('optionsApp')
  .controller 'MainCtrl', ['$scope', 'Chrome', ($scope, Chrome) ->
    console.info 'asdf'
  ]
