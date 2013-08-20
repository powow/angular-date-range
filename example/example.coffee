app = angular.module('date-range.example', ['powow.bootstrap.date-range'])
app.controller 'ExampleController', ($scope) ->
  $scope.dateTo = moment().add(days: 13).toDate()
  $scope.today = new Date()
  $scope.fourMonthsFromNow = moment().add(months: 4).toDate()

  $scope.isWeekend = (date) ->
    dayNumber = moment(date).day()
    dayNumber == 0 || dayNumber == 6

  $scope.selectFirstDay = (week) ->
    $scope.dateFrom = week.firstDate

  $scope.selectLastDay = (week) ->
    $scope.dateTo = week.lastDate
