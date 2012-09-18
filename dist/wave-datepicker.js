var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __slice = [].slice;

(function(root, factory) {
  if (typeof define === 'function' && define.amd) {
    return define(['jquery'], function($) {
      return root.WDP = factory($);
    });
  } else {
    return root.WDP = factory(root.$);
  }
})(this, function($) {
  var WDP;
  WDP = {};
  WDP.$ = $;
  WDP.template = "<div class=\"wdp dropdown-menu\">  <div class=\"row-fluid\">    <div class=\"span5 wdp-shortcuts\"></div>    <div class=\"span7\">      <table class=\"table-condensed wdp-calendar\">        <thead>          <tr>              <th class=\"wdp-prev\">                <a href=\"javascript:void(0)\" class=\"js-wdp-prev\"><i class=\"icon-arrow-left\"/></a>              </th>              <th colspan=\"5\" class=\"wdp-month-and-year js-wdp-set-month-year\"></th>              <th class=\"wdp-next\">                <a href=\"javascript:void(0)\" class=\"js-wdp-next\"><i class=\"icon-arrow-right\"/></a>              </th>          </tr>        </thead>        <tbody></tbody>      </table>      <table class=\"table-condensed wdp-year-calendar\">      <tbody></tbody>      </table>      <table class=\"table-condensed wdp-month-calendar\">      <tbody></tbody>      </table>    </div>  </div></div>";
  WDP.DateUtils = {
    format: function(date, format) {
      return moment(date).format(format);
    },
    parse: function(str, format) {
      return moment(str, format);
    }
  };
  WDP.configure = function(options) {
    WDP.template = options.template || WDP.template;
    WDP.DateUtils.format = options.dateFormat || WDP.DateUtils.format;
    return WDP.DateUtils.parse = options.dateParse || WDP.DateUtils.parse;
  };
  WDP.Keys = {
    RETURN: 13,
    ESC: 27,
    LEFT: 37,
    UP: 38,
    RIGHT: 39,
    DOWN: 40,
    H: 72,
    J: 74,
    K: 75,
    L: 76
  };
  WDP.Shortcuts = (function() {

    Shortcuts.prototype._defaults = {
      'Today': {
        days: 0
      }
    };

    Shortcuts.prototype.currSelectedIndex = -1;

    function Shortcuts(options) {
      this.options = options;
      this._updateSelected = __bind(this._updateSelected, this);

      this._onShortcutClick = __bind(this._onShortcutClick, this);

      this.selectPrev = __bind(this.selectPrev, this);

      this.selectNext = __bind(this.selectNext, this);

      this.options || (this.options = this._defaults);
      this.$el = WDP.$('<ul>');
      this.$el.on('click', this._onShortcutClick);
    }

    Shortcuts.prototype.render = function() {
      var name, offset, shortcuts, _ref;
      shortcuts = [];
      this.numShortcuts = 0;
      _ref = this.options;
      for (name in _ref) {
        offset = _ref[name];
        shortcuts.push("<li><a          data-days=\"" + (offset.days || 0) + "\"          data-months=\"" + (offset.months || 0) + "\"          data-years=\"" + (offset.years || 0) + "\"          data-shortcut-num=\"" + this.numShortcuts + "\"          class=\"wdp-shortcut js-wdp-shortcut\"          href=\"javascript:void(0)\">" + name + "</a></li>");
        this.numShortcuts++;
      }
      this.$el.html(shortcuts.join(''));
      return this;
    };

    Shortcuts.prototype.resetClass = function() {
      return this.$el.find('.wdp-shortcut-active').removeClass('wdp-shortcut-active');
    };

    Shortcuts.prototype.selectNext = function() {
      this.currSelectedIndex = (this.currSelectedIndex + 1) % this.numShortcuts;
      return this._updateSelected();
    };

    Shortcuts.prototype.selectPrev = function() {
      this.currSelectedIndex = (this.currSelectedIndex - 1) % this.numShortcuts;
      if (this.currSelectedIndex < 0) {
        this.currSelectedIndex = this.numShortcuts - 1;
      }
      return this._updateSelected();
    };

    Shortcuts.prototype.select = function($target) {
      var data, offset, wrapper;
      data = $target.data();
      wrapper = moment(new Date());
      offset = {
        days: data.days,
        months: data.months,
        years: data.years
      };
      wrapper.add(offset);
      this.resetClass();
      $target.addClass('wdp-shortcut-active');
      return this.$el.trigger('dateselect', wrapper.toDate());
    };

    Shortcuts.prototype._onShortcutClick = function(e) {
      return this.select(WDP.$(e.target));
    };

    Shortcuts.prototype._updateSelected = function() {
      var $target;
      this.resetClass();
      $target = this.$el.find(".wdp-shortcut[data-shortcut-num=" + this.currSelectedIndex + "]").addClass('wdp-shortcut-active');
      return this.select($target);
    };

    return Shortcuts;

  })();
  WDP.WaveDatepicker = (function() {

    WaveDatepicker.prototype._defaultFormat = 'YYYY-MM-DD';

    WaveDatepicker.prototype._state = null;

    function WaveDatepicker(options) {
      var _ref, _ref1,
        _this = this;
      this.options = options;
      this._selectDate = __bind(this._selectDate, this);

      this._onInputKeydown = __bind(this._onInputKeydown, this);

      this._cancelEvent = __bind(this._cancelEvent, this);

      this._showMonthGrid = __bind(this._showMonthGrid, this);

      this._showYearGrid = __bind(this._showYearGrid, this);

      this._place = __bind(this._place, this);

      this._updateMonthAndYear = __bind(this._updateMonthAndYear, this);

      this._updateFromInput = __bind(this._updateFromInput, this);

      this.destroy = __bind(this.destroy, this);

      this.next = __bind(this.next, this);

      this.prev = __bind(this.prev, this);

      this.setDate = __bind(this.setDate, this);

      this.hide = __bind(this.hide, this);

      this.show = __bind(this.show, this);

      this.render = __bind(this.render, this);

      this.el = this.options.el;
      this.$el = WDP.$(this.el);
      this.dateFormat = this.options.format || this._defaultFormat;
      this._state = {};
      this._updateFromInput();
      this._initPicker();
      this._initElements();
      this._initEvents();
      this.shortcuts = new WDP.Shortcuts(options.shortcuts).render();
      this.$shortcuts.append(this.shortcuts.$el);
      if ((_ref = this.shortcuts) != null) {
        _ref.resetClass();
      }
      if ((_ref1 = this.shortcuts) != null) {
        _ref1.resetClass();
      }
      this.$shortcuts.on('dateselect', function(e, date) {
        return _this.setDate(date);
      });
    }

    WaveDatepicker.prototype.render = function() {
      this._updateMonthAndYear();
      this._fill();
      this._updateSelection();
      return this;
    };

    WaveDatepicker.prototype.show = function() {
      if (!this._isShown) {
        this._isShown = true;
        this.$calendar.show();
        this.$datepicker.addClass('show');
        this.height = this.$el.outerHeight();
        this._place();
        return this.$window.on('resize', this._place);
      }
    };

    WaveDatepicker.prototype.hide = function() {
      if (this._isShown) {
        this._isShown = false;
        this.$calendarYear.hide();
        this.$calendarMonth.hide();
        this.$datepicker.removeClass('show');
        return this.$window.off('resize', this._place);
      }
    };

    WaveDatepicker.prototype.setDate = function(date) {
      this.date = date;
      this._state.month = this.date.getMonth();
      this._state.year = this.date.getFullYear();
      this.$el.val(this._formatDate(date));
      return this.$el.trigger('datechange', this.date);
    };

    WaveDatepicker.prototype.getDate = function() {
      return this.date;
    };

    WaveDatepicker.prototype.prev = function() {
      if (this._state.month === 1) {
        this._state.month = 12;
        this._state.year -= 1;
      } else {
        this._state.month -= 1;
      }
      return this.render();
    };

    WaveDatepicker.prototype.next = function() {
      if (this._state.month === 12) {
        this._state.month = 1;
        this._state.year += 1;
      } else {
        this._state.month += 1;
      }
      return this.render();
    };

    WaveDatepicker.prototype.destroy = function() {
      this.$datepicker.remove();
      return this.$el.removeData('datepicker');
    };

    WaveDatepicker.prototype._initElements = function() {
      if (this.options.className) {
        this.$el.addClass(this.options.className);
      }
      this.$el.val(this._formatDate(this.date));
      this.$shortcuts = this.$datepicker.find('.wdp-shortcuts');
      this.$calendar = this.$datepicker.find('.wdp-calendar');
      this.$calendarTbody = this.$calendar.find('tbody');
      this.$calendarYear = this.$datepicker.find('.wdp-year-calendar');
      this.$calendarYearTbody = this.$calendarYear.find('tbody');
      this.$calendarMonth = this.$datepicker.find('.wdp-month-calendar');
      this.$calendarMonthTbody = this.$calendarMonth.find('tbody');
      this.$monthAndYear = this.$calendar.find('.wdp-month-and-year');
      return this.$window = $(window);
    };

    WaveDatepicker.prototype._initPicker = function() {
      var weekdays;
      this.$datepicker = $(WDP.template);
      this.$datepicker.appendTo(document.body);
      weekdays = moment.weekdaysMin.join('</th><th>');
      return this.$datepicker.find('thead').append("<tr class=\"wdp-weekdays\"><th>" + weekdays + "</th></tr>");
    };

    WaveDatepicker.prototype._initEvents = function() {
      this.$el.on('focus', this.show);
      this.$el.on('mousedown', this.show);
      this.$el.on('blur', this.hide);
      this.$el.on('change', this._updateFromInput);
      this.$el.on('datechange', this.render);
      this.$el.on('keydown', this._onInputKeydown);
      this.$datepicker.on('mousedown', this._cancelEvent);
      this.$datepicker.on('click', '.js-wdp-calendar-cell', this._selectDate);
      this.$datepicker.on('click', '.js-wdp-prev', this.prev);
      this.$datepicker.on('click', '.js-wdp-next', this.next);
      this.$datepicker.on('click', '.js-wdp-set-month-year', this._showYearGrid);
      return this.$datepicker.on('click', '.js-wdp-year-calendar-cell', this._showMonthGrid);
    };

    WaveDatepicker.prototype._updateFromInput = function() {
      var dateStr;
      if ((dateStr = this.$el.val())) {
        this.date = this._parseDate(dateStr);
      }
      this.date || (this.date = new Date());
      return this.setDate(this.date);
    };

    WaveDatepicker.prototype._updateMonthAndYear = function() {
      var date, monthAndYear;
      date = new Date(this._state.year, this._state.month, 1);
      monthAndYear = moment(date).format('MMMM YYYY');
      return this.$monthAndYear.text(monthAndYear);
    };

    WaveDatepicker.prototype._formatDate = function(date) {
      return WDP.DateUtils.format(date, this.dateFormat);
    };

    WaveDatepicker.prototype._parseDate = function(str) {
      return WDP.DateUtils.parse(str, this.dateFormat).toDate();
    };

    WaveDatepicker.prototype._place = function() {
      var offset, zIndex;
      zIndex = parseInt(this.$el.parents().filter(function() {
        return $(this).css('z-index') !== 'auto';
      }).first().css('z-index'), 10) + 10;
      offset = this.$el.offset();
      return this.$datepicker.css({
        top: offset.top + this.height,
        left: offset.left,
        zIndex: zIndex
      });
    };

    WaveDatepicker.prototype._showYearGrid = function() {
      var currentClass, html, i, m, _i;
      html = [];
      m = moment(new Date(this._state.year - 9, 0, 1));
      for (i = _i = 0; _i <= 19; i = ++_i) {
        if (i % 5 === 0) {
          html.push("<tr class=\"wdp-calendar-row\">");
        }
        if (m.year() === this._state.year) {
          currentClass = "wdp-current-month-year-cell";
        } else {
          currentClass = "";
        }
        html.push("<td class=\"js-wdp-year-calendar-cell " + currentClass + "\" data-date=\"" + (m.format("YYYY-MM-DD")) + "\">" + (m.format("YYYY")) + "</td>");
        m.add("years", 1);
      }
      html.push("</tr>");
      this.$calendarYearTbody.html(html.join(''));
      this.$calendar.hide();
      return this.$calendarYear.show();
    };

    WaveDatepicker.prototype._showMonthGrid = function(e) {
      var currentClass, date, html, i, m, _i;
      html = [];
      date = moment(this._parseDate($(e.target).data('date')));
      m = moment(new Date(date.year(), 0, 1));
      for (i = _i = 0; _i <= 11; i = ++_i) {
        if (i % 3 === 0) {
          html.push("<tr class=\"wdp-calendar-row\">");
        }
        if (m.month() === this._state.month) {
          currentClass = 'wdp-current-month-year-cell';
        } else {
          currentClass = "";
        }
        html.push("<td class=\"js-wdp-calendar-cell " + currentClass + "\" data-date=\"" + (m.format("YYYY-MM-DD")) + "\">" + (m.format("MMM")) + "</td>");
        m.add("months", 1);
      }
      html.push("</tr>");
      this.$calendarMonthTbody.html(html.join(''));
      this.$calendarYear.hide();
      return this.$calendarMonth.show();
    };

    WaveDatepicker.prototype._fill = function() {
      var currMonth, d, date, daysInMonth, endOfMonth, firstDateDay, formatted, formattedNextMonth, formattedPrevMonth, html, i, index, lastDateDay, nextMonth, paddingStart, prevMonth, startOfMonth, wrapped, _i, _j, _ref;
      date = new Date(this._state.year, this._state.month, 1);
      index = 0;
      html = [];
      wrapped = moment(date);
      daysInMonth = wrapped.daysInMonth();
      startOfMonth = wrapped.clone().startOf('month');
      endOfMonth = wrapped.clone().endOf('month');
      firstDateDay = startOfMonth.day();
      lastDateDay = endOfMonth.day();
      paddingStart = 0;
      if (firstDateDay !== 0) {
        prevMonth = startOfMonth.clone();
        for (i = _i = 0, _ref = firstDateDay - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          if ((index++) === 0) {
            html.push('<tr class="wdp-calendar-row">');
          }
          d = prevMonth.add('days', -1).date();
          formattedPrevMonth = this._formatDate(new Date(this._state.year, this._state.month - 1, d));
          html[6 - i + 1] = "<td class=\"wdp-calendar-othermonth js-wdp-calendar-cell\" data-date=\"" + formattedPrevMonth + "\">" + d + "</td>";
          paddingStart++;
        }
      }
      currMonth = new Date(this._state.year, this._state.month, 1);
      for (i = _j = 1; 1 <= daysInMonth ? _j <= daysInMonth : _j >= daysInMonth; i = 1 <= daysInMonth ? ++_j : --_j) {
        currMonth.setDate(i);
        formatted = this._formatDate(currMonth);
        if ((index++) % 7 === 0) {
          html.push('</tr><tr class="wdp-calendar-row">');
        }
        html.push("<td class=\"js-wdp-calendar-cell\" data-date=\"" + formatted + "\">" + i + "</td>");
      }
      nextMonth = endOfMonth.clone();
      while (index < 42) {
        d = nextMonth.add('days', 1).date();
        formattedNextMonth = this._formatDate(new Date(this._state.year, this._state.month + 1, d));
        if ((index++) % 7 === 0) {
          html.push('</tr><tr class="wdp-calendar-row">');
        }
        html.push("<td class=\"wdp-calendar-othermonth js-wdp-calendar-cell\" data-date=\"" + formattedNextMonth + "\">" + d + "</td>");
      }
      html.push('</tr>');
      this.$calendarYear.hide();
      this.$calendarMonth.hide();
      this.$calendarTbody.html(html.join(''));
      return this.$calendar.show();
    };

    WaveDatepicker.prototype._cancelEvent = function(e) {
      e.stopPropagation();
      return e.preventDefault();
    };

    WaveDatepicker.prototype._onInputKeydown = function(e) {
      var date, fn, offset;
      switch (e.keyCode) {
        case WDP.Keys.DOWN:
        case WDP.Keys.J:
          this._cancelEvent(e);
          fn = this.shortcuts.selectNext;
          offset = 7;
          this.show();
          break;
        case WDP.Keys.RETURN:
          this.show();
          break;
        case WDP.Keys.UP:
        case WDP.Keys.K:
          this._cancelEvent(e);
          fn = this.shortcuts.selectPrev;
          offset = -7;
          break;
        case WDP.Keys.LEFT:
        case WDP.Keys.H:
          this._cancelEvent(e);
          offset = -1;
          break;
        case WDP.Keys.RIGHT:
        case WDP.Keys.L:
          this._cancelEvent(e);
          offset = 1;
          break;
        case WDP.Keys.ESC:
          this.hide();
      }
      if (e.shiftKey) {
        return typeof fn === "function" ? fn() : void 0;
      } else if (offset != null) {
        date = new Date(this.date.getFullYear(), this.date.getMonth(), this.date.getDate() + offset);
        this.shortcuts.resetClass();
        return this.setDate(date);
      }
    };

    WaveDatepicker.prototype._updateSelection = function() {
      var dateStr;
      dateStr = this._formatDate(this.date);
      this.$calendarTbody.find('.wdp-selected').removeClass('wdp-selected');
      return this.$calendarTbody.find("td[data-date=" + dateStr + "]").addClass('wdp-selected');
    };

    WaveDatepicker.prototype._selectDate = function(e) {
      var date;
      this.$calendarMonth.hide();
      this.$calendar.show();
      this.shortcuts.resetClass();
      date = this._parseDate($(e.target).data('date'));
      return this.setDate(date);
    };

    return WaveDatepicker;

  })();
  $.fn.datepicker = function() {
    var args, options, widget;
    options = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (options == null) {
      options = {};
    }
    if (typeof options === 'string' && options[0] !== '_' && options !== 'render') {
      widget = $(this).data('datepicker');
      return widget != null ? widget[options].apply(widget, args) : void 0;
    }
    return this.each(function() {
      var $this;
      $this = $(this);
      widget = $this.data('datepicker');
      $.extend(options, {
        el: this
      });
      if (!widget) {
        return $this.data('datepicker', (widget = new WDP.WaveDatepicker(options).render()));
      }
    });
  };
  return WDP;
});
