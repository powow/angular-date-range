app = angular.module('powow.bootstrap.date-range.src', ['ui.bootstrap.position'])

# immutable moment wrapper
m = (date) ->
  moment(date).clone()

withDayOfWeek = (firstDayOfWeek, fn) ->
  week = angular.copy(m().lang()._week)
  try
    m().lang().set(week: {dow: firstDayOfWeek, doy: week.doy})
    
    fn()
  finally
    m().lang().set(week: week)

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
      (new Month(m(@firstMonthDate).add(months: offset).toDate()) for offset in [0...@numberOfMonths])

  weekDays: ->
    withDayOfWeek @firstDayOfWeek, ->
      (m().weekday(i).toDate() for i in [0..6])

  _move: (offset) ->
    nextDate = m(@firstMonthDate).add(months: offset).toDate()
    new Calendar
      firstMonthDate: nextDate
      firstDayOfWeek: @firstDayOfWeek
      numberOfMonths: @numberOfMonths

class Month
  constructor: (@date) ->
    month = m(@date).month()
    day = m(@date).startOf('month')
    @weeks = []
    week = {}
    while day.month() == month
      if day.week() != week.number
        week = new Week(day)
        @weeks.push(week)
      week.addDay(m(day).toDate())
      day.add(days: 1)

  next: ->
    new Month(m(@date).add(months: 1).toDate())

class Week
  constructor: (@date) ->
    @number = m(@date).week()
    @firstDate = m(@date).startOf('week').toDate()
    @lastDate = m(@date).endOf('week').toDate()
    @days = (new PlaceholderDay() for dayNumber in [0..6])

  addDay: (day) ->
    @days[m(day).weekday()] = new Day(day)

class PlaceholderDay
  constructor: ->
    @placeholder = true

  same: -> false
  before: -> false
  after: -> false

class Day
  constructor: (date) ->
    @date = @_normalize(date)
    @placeholder = false
    @number = @date.getDate()

  same: (date) ->
    return false unless date
    @_diff(date) == 0

  before: (date) ->
    return false unless date
    @_diff(date) < 0

  after: (date) ->
    return false unless date
    @_diff(date) > 0

  _diff: (date) ->
    @date - @_normalize(date)

  _normalize: (date) ->
    date = new Date(date)
    new Date(date.getFullYear(), date.getMonth(), date.getDate())

class DateRangeController
  @$inject = ['$scope']
  constructor: ($scope) ->
    $scope.selectedDate ||= new Date()

    calendar = new Calendar
      firstDayOfWeek: Number($scope.firstDayOfWeek)
      numberOfMonths: Number($scope.numberOfMonths)
      firstMonthDate: m($scope.selectedDate).toDate()

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

    $scope.isDisabled = (day) ->
      $scope.dateDisabled(date: day.date) || 
        day.before($scope.minDate) || 
        day.before($scope.dateRangeBegin) || 
        day.after($scope.maxDate)

    $scope.firstMonth = (month) ->
      $scope.months[0] == month

    $scope.lastMonth = (month) ->
      $scope.months[$scope.months.length - 1] == month

    $scope.$watch 'dateRangeBegin', ->
      return unless $scope.dateRangeBegin
      return unless new Day($scope.dateRangeBegin).after($scope.selectedDate)
      $scope.selectedDate = $scope.dateRangeBegin

    $scope.$watch 'selectedDate', ->
      return unless $scope.selectedDate
      day = new Day($scope.selectedDate)
      $scope.selectedDate = $scope.minDate if day.before($scope.minDate)
      $scope.selectedDate = $scope.maxDate if day.after($scope.maxDate)
      $scope.dateChanged()

app.directive 'dateRangePicker', ->
  restrict: 'E'
  controller: DateRangeController
  templateUrl: '/src/date-range.html'
  scope: 
    selectedDate: '=ngModel'
    dateRangeBegin: '='
    firstDayOfWeek: '@'
    numberOfMonths: '@'
    dateDisabled: '&'
    weekClicked: '&'
    dateChanged: '&'
    minDate: '=min'
    maxDate: '=max'

app.directive 'dateFormat', ->
  restrict: 'A'
  require: 'ngModel'
  link: (scope, element, attributes, ngModel) ->
    format = attributes.dateFormat

    isValid = (value) ->
      moment(value, format).isValid() && moment(value, format).format(format) == value

    ngModel.$parsers.unshift (value) ->
      if isValid(value)
        ngModel.$setValidity('dateFormat', true)
        moment(value, format).toDate()
      else
        ngModel.$setValidity('dateFormat', false)
        undefined

    ngModel.$formatters.push (value) ->
      return moment(value).format(format) if value
    
dateRangeDirective = ($document, $position) ->
  restrict: 'E'
  templateUrl: "/src/date-range-popup.html"
  compile: (element, attributes) ->
    input = element.find('input')
    picker = element.find('date-range-picker')

    for normalized, original of attributes.$attr
      input.attr(original, attributes[normalized])
      picker.attr(original, attributes[normalized])

    return (scope, element, attributes) ->
      popup = element.find('ul')
      input = element.find('input')

      popup.css('display', 'none')

      hidePopup = ->
        popup.css('display', 'none')
        $document.unbind('click', hidePopup)

      showPopup = ->
        position = $position.position(input)
        popup.css 
          display: 'block'
          top: position.top + position.height + 'px'
          left: position.left + 'px'

      input.on 'focus', ->
        angular.element(document.getElementsByClassName('date-range-popup')).css('display', 'none')
        showPopup()
        $document.on 'click', hidePopup

      angular.element(element[0].getElementsByClassName('close-popup')).on 'click', hidePopup
      
      element.on 'click', (event) ->
        event.stopPropagation()

app.directive 'dateRange', ['$document', '$position', dateRangeDirective]
