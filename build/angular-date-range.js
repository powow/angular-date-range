(function() {
  var module, registerTemplate, template;

  template = "<div class=\"clearfix\">\n  <table class=\"pull-left\" ng-repeat=\"month in months\" style=\"margin-right: 10px;\">\n    <thead>\n      <tr class=\"text-center\">\n        <th ng-show=\"firstMonth(month)\"><button type=\"button\" class=\"btn btn-small pull-left prev-month\" ng-click=\"previousMonth()\"><i class=\"icon-chevron-left\"></i></button></th>\n        <th colspan=\"{{colspanForMonth(month)}}\"><strong>{{month.date | date:'MMMM'}}</strong></th>\n        <th ng-show=\"lastMonth(month)\"><button type=\"button\" class=\"btn btn-small pull-right next-month\" ng-click=\"nextMonth()\"><i class=\"icon-chevron-right\"></i></button></th>\n      </tr>\n      <tr class=\"text-center\">\n        <th>#</th>\n        <th ng-repeat=\"day in days\">{{day | date:'EEE'}}</th>\n      </tr>\n    </thead>\n    <tbody>\n      <tr ng-repeat=\"week in month.weeks\">\n        <td class=\"text-center\"><a href ng-click=\"weekClicked({week: week})\">{{week.number}}</a></td>\n        <td ng-repeat=\"day in week.days\" class=\"text-center\">\n          <button type=\"button\"\n            ng-hide=\"day.placeholder\"\n            style=\"width:100%;\"\n            class=\"btn btn-small select-day\"\n            ng-class=\"{'btn-info': isSelected(day), 'btn-primary': isBeginOfRange(day), 'btn-warning': isInsideRange(day)}\"\n            ng-click=\"select(day)\"\n            ng-disabled=\"isDisabled(day)\">{{day.number}}</button>\n        </td>\n      </tr>\n    </tbody>\n  </table>\n</div>\n";

  module = angular.module('powow.bootstrap.date-range.template.date-range', []);

  registerTemplate = function($templateCache) {
    return $templateCache.put('/src/date-range.html', template);
  };

  module.run(['$templateCache', registerTemplate]);

}).call(this);
(function() {
  var module, registerTemplate, template;

  template = "<input type=\"text\" />\n\n<ul class=\"dropdown-menu date-range-popup\">\n  <li>\n  <date-range-picker></date-range-picker>\n  </li>\n  <li class=\"divider\"></li>\n  <li class=\"clearfix\" style=\"padding: 3px 9px;\"><button class=\"close-popup btn btn-success btn-small pull-right\">Close</button></li>\n</ul>\n";

  module = angular.module('powow.bootstrap.date-range.template.date-range-popup', []);

  registerTemplate = function($templateCache) {
    return $templateCache.put('/src/date-range-popup.html', template);
  };

  module.run(['$templateCache', registerTemplate]);

}).call(this);
(function() {
  var Calendar, DateRangeController, Day, Month, PlaceholderDay, Week, app, dateRangeDirective, m, withDayOfWeek;

  app = angular.module('powow.bootstrap.date-range.src', ['ui.bootstrap.position']);

  m = function(date) {
    return moment(date).clone();
  };

  withDayOfWeek = function(firstDayOfWeek, fn) {
    var week;
    week = angular.copy(m().lang()._week);
    try {
      m().lang().set({
        week: {
          dow: firstDayOfWeek,
          doy: week.doy
        }
      });
      return fn();
    } finally {
      m().lang().set({
        week: week
      });
    }
  };

  Calendar = (function() {
    function Calendar(opts) {
      if (opts == null) {
        opts = {};
      }
      this.firstMonthDate = opts.firstMonthDate;
      this.numberOfMonths = opts.numberOfMonths || 2;
      this.firstDayOfWeek = opts.firstDayOfWeek || 0;
    }

    Calendar.prototype.previous = function() {
      return this._move(-1);
    };

    Calendar.prototype.next = function() {
      return this._move(1);
    };

    Calendar.prototype.months = function() {
      var _this = this;
      return withDayOfWeek(this.firstDayOfWeek, function() {
        var offset, _i, _ref, _results;
        _results = [];
        for (offset = _i = 0, _ref = _this.numberOfMonths; 0 <= _ref ? _i < _ref : _i > _ref; offset = 0 <= _ref ? ++_i : --_i) {
          _results.push(new Month(m(_this.firstMonthDate).add({
            months: offset
          }).toDate()));
        }
        return _results;
      });
    };

    Calendar.prototype.weekDays = function() {
      return withDayOfWeek(this.firstDayOfWeek, function() {
        var i, _i, _results;
        _results = [];
        for (i = _i = 0; _i <= 6; i = ++_i) {
          _results.push(m().weekday(i).toDate());
        }
        return _results;
      });
    };

    Calendar.prototype._move = function(offset) {
      var nextDate;
      nextDate = m(this.firstMonthDate).add({
        months: offset
      }).toDate();
      return new Calendar({
        firstMonthDate: nextDate,
        firstDayOfWeek: this.firstDayOfWeek,
        numberOfMonths: this.numberOfMonths
      });
    };

    return Calendar;

  })();

  Month = (function() {
    function Month(date) {
      var day, month, week;
      this.date = date;
      month = m(this.date).month();
      day = m(this.date).startOf('month');
      this.weeks = [];
      week = {};
      while (day.month() === month) {
        if (day.week() !== week.number) {
          week = new Week(day);
          this.weeks.push(week);
        }
        week.addDay(m(day).toDate());
        day.add({
          days: 1
        });
      }
    }

    Month.prototype.next = function() {
      return new Month(m(this.date).add({
        months: 1
      }).toDate());
    };

    return Month;

  })();

  Week = (function() {
    function Week(date) {
      var dayNumber;
      this.date = date;
      this.number = m(this.date).week();
      this.firstDate = m(this.date).startOf('week').toDate();
      this.lastDate = m(this.date).endOf('week').toDate();
      this.days = (function() {
        var _i, _results;
        _results = [];
        for (dayNumber = _i = 0; _i <= 6; dayNumber = ++_i) {
          _results.push(new PlaceholderDay());
        }
        return _results;
      })();
    }

    Week.prototype.addDay = function(day) {
      return this.days[m(day).weekday()] = new Day(day);
    };

    return Week;

  })();

  PlaceholderDay = (function() {
    function PlaceholderDay() {
      this.placeholder = true;
    }

    PlaceholderDay.prototype.same = function() {
      return false;
    };

    PlaceholderDay.prototype.before = function() {
      return false;
    };

    PlaceholderDay.prototype.after = function() {
      return false;
    };

    return PlaceholderDay;

  })();

  Day = (function() {
    function Day(date) {
      this.date = this._normalize(date);
      this.placeholder = false;
      this.number = this.date.getDate();
    }

    Day.prototype.same = function(date) {
      if (!date) {
        return false;
      }
      return this._diff(date) === 0;
    };

    Day.prototype.before = function(date) {
      if (!date) {
        return false;
      }
      return this._diff(date) < 0;
    };

    Day.prototype.after = function(date) {
      if (!date) {
        return false;
      }
      return this._diff(date) > 0;
    };

    Day.prototype._diff = function(date) {
      return this.date - this._normalize(date);
    };

    Day.prototype._normalize = function(date) {
      date = new Date(date);
      return new Date(date.getFullYear(), date.getMonth(), date.getDate());
    };

    return Day;

  })();

  DateRangeController = (function() {
    DateRangeController.$inject = ['$scope'];

    function DateRangeController($scope) {
      var calendar;
      $scope.selectedDate || ($scope.selectedDate = new Date());
      calendar = new Calendar({
        firstDayOfWeek: Number($scope.firstDayOfWeek),
        numberOfMonths: Number($scope.numberOfMonths),
        firstMonthDate: m($scope.selectedDate).toDate()
      });
      $scope.months = calendar.months();
      $scope.days = calendar.weekDays();
      $scope.previousMonth = function() {
        calendar = calendar.previous();
        return $scope.months = calendar.months();
      };
      $scope.nextMonth = function() {
        calendar = calendar.next();
        return $scope.months = calendar.months();
      };
      $scope.select = function(day) {
        return $scope.selectedDate = day.date;
      };
      $scope.isSelected = function(day) {
        return day.same($scope.selectedDate);
      };
      $scope.isBeginOfRange = function(day) {
        return day.same($scope.dateRangeBegin);
      };
      $scope.isInsideRange = function(day) {
        return day.after($scope.dateRangeBegin) && day.before($scope.selectedDate);
      };
      $scope.colspanForMonth = function(month) {
        var colspan;
        colspan = 8;
        if ($scope.firstMonth(month)) {
          colspan -= 1;
        }
        if ($scope.lastMonth(month)) {
          colspan -= 1;
        }
        return colspan;
      };
      $scope.isDisabled = function(day) {
        return $scope.dateDisabled({
          date: day.date
        }) || day.before($scope.minDate) || day.before($scope.dateRangeBegin) || day.after($scope.maxDate);
      };
      $scope.firstMonth = function(month) {
        return $scope.months[0] === month;
      };
      $scope.lastMonth = function(month) {
        return $scope.months[$scope.months.length - 1] === month;
      };
      $scope.$watch('dateRangeBegin', function() {
        if (!$scope.dateRangeBegin) {
          return;
        }
        if (!new Day($scope.dateRangeBegin).after($scope.selectedDate)) {
          return;
        }
        return $scope.selectedDate = $scope.dateRangeBegin;
      });
      $scope.$watch('selectedDate', function() {
        var day;
        if (!$scope.selectedDate) {
          return;
        }
        day = new Day($scope.selectedDate);
        if (day.before($scope.minDate)) {
          $scope.selectedDate = $scope.minDate;
        }
        if (day.after($scope.maxDate)) {
          $scope.selectedDate = $scope.maxDate;
        }
        return $scope.dateChanged();
      });
    }

    return DateRangeController;

  })();

  app.directive('dateRangePicker', function() {
    return {
      restrict: 'E',
      controller: DateRangeController,
      templateUrl: '/src/date-range.html',
      scope: {
        selectedDate: '=ngModel',
        dateRangeBegin: '=',
        firstDayOfWeek: '@',
        numberOfMonths: '@',
        dateDisabled: '&',
        weekClicked: '&',
        dateChanged: '&',
        minDate: '=min',
        maxDate: '=max'
      }
    };
  });

  app.directive('dateFormat', function() {
    return {
      restrict: 'A',
      require: 'ngModel',
      link: function(scope, element, attributes, ngModel) {
        var format, isValid;
        format = attributes.dateFormat;
        isValid = function(value) {
          return moment(value, format).isValid() && moment(value, format).format(format) === value;
        };
        ngModel.$parsers.unshift(function(value) {
          if (isValid(value)) {
            ngModel.$setValidity('dateFormat', true);
            return moment(value, format).toDate();
          } else {
            ngModel.$setValidity('dateFormat', false);
            return void 0;
          }
        });
        return ngModel.$formatters.push(function(value) {
          if (value) {
            return moment(value).format(format);
          }
        });
      }
    };
  });

  dateRangeDirective = function($document, $position) {
    return {
      restrict: 'E',
      templateUrl: "/src/date-range-popup.html",
      compile: function(element, attributes) {
        var input, normalized, original, picker, _ref;
        input = element.find('input');
        picker = element.find('date-range-picker');
        _ref = attributes.$attr;
        for (normalized in _ref) {
          original = _ref[normalized];
          input.attr(original, attributes[normalized]);
          picker.attr(original, attributes[normalized]);
          element.removeAttr(original);
        }
        return function(scope, element, attributes) {
          var getPopupPosition, hidePopup, popup, popupOverTheRightWindowBorder, showPopup;
          popup = element.find('ul');
          input = element.find('input');
          popup.css('display', 'none');
          hidePopup = function() {
            popup.css('display', 'none');
            return $document.unbind('click', hidePopup);
          };
          getPopupPosition = function() {
            var popupPosition;
            popup.css({
              display: 'block',
              top: '-9999px',
              left: '-9999px'
            });
            return popupPosition = $position.position(popup);
          };
          popupOverTheRightWindowBorder = function(inputPosition, popupPosition) {
            return inputPosition.left + popupPosition.width > window.innerWidth;
          };
          showPopup = function() {
            var inputPosition, left, popupPosition;
            inputPosition = $position.position(input);
            popupPosition = getPopupPosition();
            if (popupOverTheRightWindowBorder(inputPosition, popupPosition)) {
              left = inputPosition.left - popupPosition.width + inputPosition.width;
            } else {
              left = inputPosition.left;
            }
            return popup.css({
              top: inputPosition.top + inputPosition.height + 'px',
              left: left + 'px'
            });
          };
          input.on('focus', function() {
            angular.element(document.getElementsByClassName('date-range-popup')).css('display', 'none');
            showPopup();
            return $document.on('click', hidePopup);
          });
          angular.element(element[0].getElementsByClassName('close-popup')).on('click', hidePopup);
          return element.on('click', function(event) {
            return event.stopPropagation();
          });
        };
      }
    };
  };

  app.directive('dateRange', ['$document', '$position', dateRangeDirective]);

}).call(this);
(function() {
  angular.module('powow.bootstrap.date-range', ['powow.bootstrap.date-range.src', 'powow.bootstrap.date-range.template.date-range', 'powow.bootstrap.date-range.template.date-range-popup']);

}).call(this);
