describe Calendar, ->
  monthForDate = (date, firstDayOfWeek = 0) ->
    new Calendar(firstMonthDate: new Date(date), firstDayOfWeek: firstDayOfWeek).months()[0]

  it "returns list of weeks in a month", ->
    month = monthForDate("2011-01-01")

    expect(month.weeks.length).toEqual(6)

  it "adds placeholder days to the first week", ->
    month = monthForDate("2011-01-01")

    firstWeek = month.weeks[0]

    expect(firstWeek.days.length).toEqual(7)
    expect(day.placeholder for day in firstWeek.days).toEqual([true, true, true, true, true, true, false])

  it "can be configured with different first day of week", ->
    month = monthForDate("2011-01-01", 3)

    firstWeek = month.weeks[0]

    expect(day.placeholder for day in firstWeek.days).toEqual([true, true, true, false, false, false, false])

  it "returns the days of week", ->
    calendar = new Calendar(firstMonthDate: new Date(), firstDayOfWeek: 3)
    days = calendar.weekDays()

    dayNames = (moment(day).format('dd') for day in days)

    expect(dayNames).toEqual(['We', 'Th', 'Fr', 'Sa', 'Su', 'Mo', 'Tu'])

  it "adds placeholder days to the last week", ->
    month = monthForDate("2011-01-01")

    lastWeek = month.weeks[5]

    expect(lastWeek.days.length).toEqual(7)
    expect(day.placeholder for day in lastWeek.days).toEqual([false, false, true, true, true, true, true])

  it "calculates a calendar for next month", ->
    calendar = new Calendar(firstMonthDate: new Date("2011-01-31"))
    nextCalendar = calendar.next()

    firstMonth = nextCalendar.months()[0].date

    expect(moment(firstMonth).month()).toEqual(1)

  it "calculates a calendar for previous month", ->
    calendar = new Calendar(firstMonthDate: new Date("2011-01-31"))
    previousCalendar = calendar.previous()

    firstMonth = previousCalendar.months()[0].date

    expect(moment(firstMonth).month()).toEqual(11)

  it "returns specified number of months", ->
    calendar = new Calendar(firstMonthDate: new Date("2011-01-31"), numberOfMonths: 3)
    months = calendar.months()

    expect(months.length).toEqual(3)
    expect(moment(month.date).month() for month in months).toEqual([0, 1, 2])

describe Day, ->
  date = moment("2011-01-30 21:30").toDate()

  it "always returns false if comparing with an undefined value", ->
    expect(new Day(date).same(undefined)).toBeFalsy()
    expect(new Day(date).after(undefined)).toBeFalsy()
    expect(new Day(date).before(undefined)).toBeFalsy()

  it "can be compared with a string", ->
    expect(new Day(date).same("2011-01-30T12:51")).toBeTruthy()
    expect(new Day(date).same("2011-01-31")).toBeFalsy()

  it "can be compared with a date", ->
    expect(new Day(date).same(moment("2011-01-30 12:51").toDate())).toBeTruthy()
    expect(new Day(date).same(new Date("2011-01-31"))).toBeFalsy()

  it "is before when the given date is at least one day later", ->
    expect(new Day(date).before(moment("2011-01-31 12:51").toDate())).toBeTruthy()
    expect(new Day(date).before(moment("2011-01-30 22:51").toDate())).toBeFalsy()
    expect(new Day(date).before(moment("2011-01-29 22:51").toDate())).toBeFalsy()

  it "is after the given date is at least one day before", ->
    expect(new Day(date).after(moment("2011-01-29 12:51").toDate())).toBeTruthy()
    expect(new Day(date).after(moment("2011-01-30 12:51").toDate())).toBeFalsy()
    expect(new Day(date).after(moment("2011-01-31 22:51").toDate())).toBeFalsy()

describe Week, ->
  it "calculates the first date", ->
    week = new Week(new Date("2013-08-20"))
    expect(new Day(week.firstDate).same("2013-08-18")).toBeTruthy()

  it "calculates the last date", ->
    week = new Week(new Date("2013-08-20"))
    expect(new Day(week.lastDate).same("2013-08-24")).toBeTruthy()

describe DateRangeController, ->
  today = moment().startOf('day').toDate()
  tomorrow = moment().add(days: 1).toDate()

  createController = (opts) ->
    scope = dateChanged: (->), $watch: (watch, fn) -> fn()
    angular.extend(scope, opts)
    new DateRangeController(scope)
    scope

  beforeEach ->
    @scope = selectedDate: new Date("2013-08-20"), $watch: ->
    new DateRangeController(@scope)

  describe "#previousMonth", ->
    it "shows the previous month", ->
      @scope.previousMonth()

      expect(@scope.months[0].date.getMonth()).toEqual(6)

    it "can be repeated", ->
      @scope.previousMonth()
      @scope.previousMonth()

      expect(@scope.months[0].date.getMonth()).toEqual(5)

  describe "#nextMonth", ->
    it "shows the next month", ->
      @scope.nextMonth()

      expect(@scope.months[0].date.getMonth()).toEqual(8)

    it "can be repeated", ->
      @scope.nextMonth()
      @scope.nextMonth()

      expect(@scope.months[0].date.getMonth()).toEqual(9)

  describe "range predicates", ->
    day = (date) ->
      new Day(new Date(date))

    describe "with a dateRangeBegin", ->
      beforeEach ->
        @scope = 
          selectedDate: new Date("2013-08-20")
          dateRangeBegin: new Date("2013-08-14")
          $watch: ->
        new DateRangeController(@scope)

      it "marks the selected date", ->
        expect(@scope.isSelected(day("2013-08-20"))).toBeTruthy()
        expect(@scope.isBeginOfRange(day("2013-08-20"))).toBeFalsy()
        expect(@scope.isInsideRange(day("2013-08-20"))).toBeFalsy()

      it "marks the range begin", ->
        expect(@scope.isBeginOfRange(day("2013-08-14"))).toBeTruthy()
        expect(@scope.isSelected(day("2013-08-14"))).toBeFalsy()
        expect(@scope.isInsideRange(day("2013-08-14"))).toBeFalsy()
      
      it "marks the dates included in range", ->
        expect(@scope.isInsideRange(day("2013-08-15"))).toBeTruthy()
        expect(@scope.isBeginOfRange(day("2013-08-15"))).toBeFalsy()
        expect(@scope.isSelected(day("2013-08-15"))).toBeFalsy()

      it "does not mark other dates", ->
        expect(@scope.isInsideRange(day("2013-08-13"))).toBeFalsy()
        expect(@scope.isBeginOfRange(day("2013-08-13"))).toBeFalsy()
        expect(@scope.isSelected(day("2013-08-13"))).toBeFalsy()

    describe "without a dateRangeBegin", ->
      beforeEach ->
        @scope = 
          selectedDate: new Date("2013-08-20")
          $watch: ->
        new DateRangeController(@scope)

      it "marks the selected date", ->
        expect(@scope.isSelected(day("2013-08-20"))).toBeTruthy()
        expect(@scope.isBeginOfRange(day("2013-08-20"))).toBeFalsy()
        expect(@scope.isInsideRange(day("2013-08-20"))).toBeFalsy()

      it "marks the dates included in range", ->
        expect(@scope.isInsideRange(day("2013-08-15"))).toBeFalsy()
        expect(@scope.isBeginOfRange(day("2013-08-15"))).toBeFalsy()
        expect(@scope.isSelected(day("2013-08-15"))).toBeFalsy()

      it "does not mark other dates", ->
        expect(@scope.isInsideRange(day("2013-08-13"))).toBeFalsy()
        expect(@scope.isBeginOfRange(day("2013-08-13"))).toBeFalsy()
        expect(@scope.isSelected(day("2013-08-13"))).toBeFalsy()

  describe "#colspanForMonth", ->
    it "returns 7 for first month", ->
      firstMonth = @scope.months[0]

      expect(@scope.colspanForMonth(firstMonth)).toEqual(7)

    it "returns 7 for last month", ->
      firstMonth = @scope.months[1]

      expect(@scope.colspanForMonth(firstMonth)).toEqual(7)

    it "returns 8 for middle months", ->
        scope = numberOfMonths: 3, $watch: ->
        new DateRangeController(scope)
        middleMonth = scope.months[1]

        expect(scope.colspanForMonth(middleMonth)).toEqual(8)

    it "returns 6 for a calendar with one month", ->
        scope = numberOfMonths: 1, $watch: ->
        new DateRangeController(scope)
        month = scope.months[0]

        expect(scope.colspanForMonth(month)).toEqual(6)

  describe "#isDisabled", ->
    it "is disabled for dates filtered by dateDisabled callback", ->
      scope = $watch: (->), dateDisabled: (opts) -> today - opts.date == 0

      new DateRangeController(scope)

      expect(scope.isDisabled(new Day(today))).toBeTruthy()
      expect(scope.isDisabled(new Day(tomorrow))).toBeFalsy()

    it "is disabled for dates before min date", ->
      scope = $watch: (->), dateDisabled: (->), minDate: tomorrow

      new DateRangeController(scope)

      expect(scope.isDisabled(new Day(today))).toBeTruthy()
      expect(scope.isDisabled(new Day(tomorrow))).toBeFalsy()

    it "is disabled for dates after max date", ->
      scope = $watch: (->), dateDisabled: (->), maxDate: today

      new DateRangeController(scope)

      expect(scope.isDisabled(new Day(tomorrow))).toBeTruthy()
      expect(scope.isDisabled(new Day(today))).toBeFalsy()

    it "is disabled for dates before dateRangeBegin", ->
      scope = $watch: (->), dateDisabled: (->), dateRangeBegin: tomorrow

      new DateRangeController(scope)

      expect(scope.isDisabled(new Day(today))).toBeTruthy()
      expect(scope.isDisabled(new Day(tomorrow))).toBeFalsy()

  describe "dateRangeBegin changes", ->
    it "does nothing when dateRangeBegin is changed to undefined", ->
      scope = createController(selectedDate: tomorrow)

      expect(scope.selectedDate).toEqual(tomorrow)

    it "does nothing when new dateRangeBegin changes to date before selected one", ->
      scope = createController(dateRangeBegin: today, selectedDate: tomorrow)

      expect(scope.selectedDate).toEqual(tomorrow)

    it "moves selectedDate to dateRangeBegin otherwise", ->
      scope = createController(dateRangeBegin: tomorrow, selectedDate: today)

      expect(scope.selectedDate).toEqual(tomorrow)

  describe "selectedDate changes", ->
    it "does not allow selectDate to change before minDate", ->
      scope = createController(minDate: tomorrow, selectedDate: today)

      expect(scope.selectedDate).toEqual(tomorrow)

    it "does not allow selectDate to change after maxDate", ->
      scope = createController(maxDate: today, selectedDate: tomorrow)

      expect(scope.selectedDate).toEqual(today)

    it "does not modify selectedDate when meets limits", ->
      scope = createController(maxDate: tomorrow, selectedDate: today)

      expect(scope.selectedDate).toEqual(today)

    it "calls the dateChanged callback", ->
      scope = createController(dateChanged: jasmine.createSpy())

      expect(scope.dateChanged).toHaveBeenCalled()
