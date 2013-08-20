app = angular.module('powow.bootstrap.date-range', [])

withDayOfWeek = (firstDayOfWeek, fn) ->
  week = angular.copy(moment().lang()._week)
  try
    moment().lang().set(week: {dow: firstDayOfWeek, doy: week.doy})
    fn()
  finally
    moment().lang().set(week: week)

class Calendar
  constructor: (opts = {}) ->
    @firstMonthDate = opts.firstMonthDate
    @numberOfMonths = opts.numberOfMonths || 2
    @firstDayOfWeek = opts.firstDayOfWeek || 0

  previous: ->
    @_move(-1)

  next: ->
    @_move(1)

  months: ->
    withDayOfWeek @firstDayOfWeek, =>
      (new Month(moment(@firstMonthDate).add(months: offset).toDate()) for offset in [0...@numberOfMonths])

  weekDays: ->
    withDayOfWeek @firstDayOfWeek, ->
      (moment().weekday(i).toDate() for i in [0..6])

  _move: (offset) ->
    nextDate = moment(@firstMonthDate).add(months: offset).toDate()
    new Calendar
      firstMonthDate: nextDate
      firstDayOfWeek: @firstDayOfWeek
      numberOfMonths: @numberOfMonths

class Month
  constructor: (@date) ->
    month = moment(@date).month()
    day = moment(@date).startOf('month')
    @weeks = []
    week = {}
    while day.month() == month
      if day.week() != week.number
        week = new Week(day.week())
        @weeks.push(week)
      week.addDay(moment(day).toDate())
      day.add(days: 1)

  next: ->
    new Month(moment(@date).add(months: 1).toDate())

class Week
  constructor: (@number) ->
    @days = (new PlaceholderDay() for dayNumber in [0..6])

  addDay: (day) ->
    @days[moment(day).weekday()] = new Day(day)

class PlaceholderDay
  constructor: ->
    @placeholder = true

  same: -> false
  before: -> false
  after: -> false

class Day
  constructor: (@date) ->
    @placeholder = false
    @number = moment(@date).date()

  same: (date) ->
    @_unix(@date) == @_unix(date)

  before: (date) ->
    @_unix(@date) < @_unix(date)

  after: (date) ->
    @_unix(@date) > @_unix(date)

  _unix: (date) ->
    moment(date).startOf('day').unix()


class DateRangeController
  @$inject = ['$scope']
  constructor: ($scope) ->
    $scope.selectedDate ||= new Date()

    firstMonthDate = moment($scope.selectedDate).toDate()
    firstDayOfWeek = Number($scope.firstDayOfWeek)
    numberOfMonths = Number($scope.numberOfMonths)
    calendar = new Calendar
      firstDayOfWeek: firstDayOfWeek
      numberOfMonths: numberOfMonths
      firstMonthDate: firstMonthDate

    $scope.months = calendar.months()
    $scope.days = calendar.weekDays()

    $scope.previousMonth = ->
      calendar = calendar.previous()
      $scope.months = calendar.months()

    $scope.nextMonth = ->
      calendar = calendar.next()
      $scope.months = calendar.months()

    $scope.select = (day) ->
      $scope.selectedDate = day.date

    $scope.isSelected = (day) ->
      day.same($scope.selectedDate)

    $scope.isBeginOfRange = (day) ->
      day.same($scope.dateRangeBegin)

    $scope.isInsideRange = (day) ->
      day.after($scope.dateRangeBegin) && day.before($scope.selectedDate)

    $scope.colspanForMonth = (month) ->
      colspan = 8
      colspan -= 1 if $scope.firstMonth(month)
      colspan -= 1 if $scope.lastMonth(month)
      colspan

    $scope.firstMonth = (month) ->
      $scope.months[0] == month

    $scope.lastMonth = (month) ->
      $scope.months[$scope.months.length - 1] == month

app.directive 'dateRange', ->
  restrict: 'E'
  controller: DateRangeController
  templateUrl: '/src/date-range.html'
  scope: 
    selectedDate: '=ngModel'
    dateRangeBegin: '='
    firstDayOfWeek: '@'
    numberOfMonths: '@'
