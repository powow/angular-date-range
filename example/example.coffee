app = angular.module('date-range.example', ['powow.bootstrap.date-range'])
app.controller 'ExampleController', ($scope) ->
  $scope.dateTo = moment().add(days: 13).toDate()
