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
    @currentDate = opts.currentDate
    @firstDayOfWeek = opts.firstDayOfWeek || 0

  previous: ->
    @_move(-1)

  next: ->
    @_move(1)

  months: ->
    withDayOfWeek @firstDayOfWeek, =>
      month = new Month(@currentDate)
      [month, month.next()]

  weekDays: ->
    withDayOfWeek @firstDayOfWeek, ->
      (moment().weekday(i).toDate() for i in [0..6])

  _move: (offset) ->
    nextDate = moment(@currentDate).add(months: offset).toDate()
    new Calendar(currentDate: nextDate, firstDayOfWeek: @firstDayOfWeek)

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
    @days = []
    (@days[dayNumber] = new PlaceholderDay() for dayNumber in [0..6])

  addDay: (day) ->
    @days[moment(day).weekday()] = new Day(day)

class PlaceholderDay
  constructor: ->
    @placeholder = true

  same: -> false

class Day
  constructor: (@date) ->
    @placeholder = false
    @number = moment(@date).date()

  same: (date) ->
    moment(@date).startOf('day').unix() == moment(date).startOf('day').unix()

class DateRangeController
  @$inject = ['$scope']
  constructor: ($scope) ->
    $scope.currentDate ||= new Date()

    firstVisibleMonth = moment($scope.currentDate).toDate()
    calendar = new Calendar(firstDayOfWeek: 3, currentDate: firstVisibleMonth)

    $scope.months = calendar.months()
    $scope.days = calendar.weekDays()

    $scope.previousMonth = ->
      calendar = calendar.previous()
      $scope.months = calendar.months()

    $scope.nextMonth = ->
      calendar = calendar.next()
      $scope.months = calendar.months()

    $scope.select = (day) ->
      $scope.currentDate = day.date

    $scope.isSelected = (day) ->
      day.same($scope.currentDate)

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
    currentDate: '=ngModel'
