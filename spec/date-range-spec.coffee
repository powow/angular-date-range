describe "DateRange", ->
  describe "calculating calendar", ->
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

  describe "Day", ->
    date = moment("2011-01-30 21:30").toDate()

    it "always returns false if comparing with an undefined value", ->
      expect(new Day(date).same(undefined)).toBeFalsy()
      expect(new Day(date).after(undefined)).toBeFalsy()
      expect(new Day(date).before(undefined)).toBeFalsy()

    it "can be compared with a string", ->
      expect(new Day(date).same("2011-01-30 12:51")).toBeTruthy()
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

