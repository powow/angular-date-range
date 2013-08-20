app = angular.module('date-range.example', ['powow.bootstrap.date-range'])
app.controller 'ExampleController', ($scope) ->
  $scope.dateFrom = new Date("2013-05-25")
