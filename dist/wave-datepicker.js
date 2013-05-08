(function() {
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
    var WDP, _oldDatepicker;

    WDP = {};
    WDP.$ = $;
    WDP.template = "<div class=\"wdp dropdown-menu\">  <div class=\"row-fluid\">    <div class=\"wdp-shortcuts span5\"></div>    <div class=\"wdp-main\">      <table class=\"table-condensed wdp-calendar\">        <thead>          <tr>              <th class=\"wdp-prev\">                <a href=\"javascript:void(0)\" class=\"js-wdp-prev\">◀</a>              </th>              <th colspan=\"5\" class=\"wdp-month-and-year js-wdp-set-month-year\"></th>              <th class=\"wdp-next\">                <a href=\"javascript:void(0)\" class=\"js-wdp-next\">▶</a>              </th>          </tr>        </thead>        <tbody></tbody>      </table>      <table class=\"table-condensed wdp-year-calendar\">      <tbody></tbody>      </table>      <table class=\"table-condensed wdp-month-calendar\">      <tbody></tbody>      </table>    </div>  </div></div>";
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
      TAB: 9,
      H: 72,
      J: 74,
      K: 75,
      L: 76
    };
    WDP.defaultOptions = {
      hideOnSelect: true
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
        this.baseDate = this.options.baseDate;
      }

      Shortcuts.prototype.render = function() {
        var extraAttributes, k, name, options, shortcuts, v, _ref, _ref1;

        shortcuts = [];
        this.numShortcuts = 0;
        _ref = this.options;
        for (name in _ref) {
          options = _ref[name];
          extraAttributes = [];
          if (options.attrs) {
            _ref1 = options.attrs;
            for (k in _ref1) {
              v = _ref1[k];
              extraAttributes.push("" + k + "=\"" + v + "\"");
            }
          }
          shortcuts.push("<li><a          data-days=\"" + (options.days || 0) + "\"           data-months=\"" + (options.months || 0) + "\"          data-years=\"" + (options.years || 0) + "\"          data-shortcut-num=\"" + this.numShortcuts + "\"          " + (extraAttributes.join('')) + "          class=\"wdp-shortcut js-wdp-shortcut\"           href=\"javascript:void(0)\">" + name + "</a></li>");
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
        wrapper = moment(this.baseDate).clone();
        offset = {
          days: data.days,
          months: data.months,
          years: data.years
        };
        wrapper.add(offset);
        this.resetClass();
        $target.addClass('wdp-shortcut-active');
        if (wrapper.isValid()) {
          return $target.trigger('dateselect', wrapper.toDate());
        }
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
    WDP.activeDatepicker = null;
    WDP.datepickers = [];
    WDP.WaveDatepicker = (function() {
      WaveDatepicker.prototype._defaultFormat = 'YYYY-MM-DD';

      WaveDatepicker.prototype._state = null;

      function WaveDatepicker(options) {
        var format, shortcutOptions, _ref, _ref1, _ref2,
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
        this.toggle = __bind(this.toggle, this);
        this.hide = __bind(this.hide, this);
        this.show = __bind(this.show, this);
        this.render = __bind(this.render, this);
        this.el = this.options.el;
        this.$el = WDP.$(this.el);
        this.options = $.extend({}, WDP.defaultOptions, options);
        format = this.options.format || this.$el.data('dateFormat');
        this.dateFormat = format || this._defaultFormat;
        this._state = {};
        this.allowClear = this.options.allowClear || this.$el.data('dateAllowClear');
        this.allowClear = (_ref = this.allowClear) === 'yes' || _ref === 'true' || _ref === true;
        this._updateFromInput(null, null, {
          update: !this.allowClear
        });
        this._initPicker();
        this._initElements();
        this._initEvents();
        this.baseDate = this.options.baseDate || new Date();
        if (options.shortcuts != null) {
          if (typeof options.shortcuts === 'object') {
            shortcutOptions = options.shortcuts;
          } else {
            shortcutOptions = null;
          }
          this.shortcuts = new WDP.Shortcuts(shortcutOptions).render();
          this.$shortcuts.append(this.shortcuts.$el);
          if ((_ref1 = this.shortcuts) != null) {
            _ref1.resetClass();
          }
          this.shortcuts.baseDate = this.baseDate;
          if ((_ref2 = this.shortcuts) != null) {
            _ref2.resetClass();
          }
          this.$shortcuts.on('dateselect', function(e, date) {
            return _this.setDate(date);
          });
        }
        WDP.datepickers.push(this);
      }

      WaveDatepicker.prototype.render = function() {
        this._updateMonthAndYear();
        this._fill();
        if (this.date) {
          this._updateSelection();
        }
        if (this.shortcuts != null) {
          this.$datepicker.addClass('wdp-has-shortcuts');
          this.$datepicker.find('.wdp-main').addClass('span7').removeClass('span12');
          this.$shortcuts.insertBefore(this.$main);
        } else {
          this.$datepicker.removeClass('wdp-has-shortcuts');
          this.$datepicker.find('.wdp-main').addClass('span12').removeClass('span7');
          this.$shortcuts.detach();
        }
        return this;
      };

      WaveDatepicker.prototype._isShown = false;

      WaveDatepicker.prototype.hideInactive = function() {
        var picker, _i, _len, _ref, _results;

        _ref = WDP.datepickers;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          picker = _ref[_i];
          if (picker !== WDP.activeDatepicker) {
            _results.push(picker.hide());
          }
        }
        return _results;
      };

      WaveDatepicker.prototype.show = function() {
        if (!(this._isShown || this.$el.is(':not(:visible)'))) {
          WDP.activeDatepicker = this;
          this.hideInactive();
          this._isShown = true;
          this.$calendar.show();
          this.$datepicker.addClass('show');
          this.height = this.$el.outerHeight();
          this._place();
          this.$window.on('resize', this._place);
          return this.$document.on('click', this.hide);
        }
      };

      WaveDatepicker.prototype.hide = function() {
        if (this._isShown) {
          this._isShown = false;
          this.$calendarYear.hide();
          this.$calendarMonth.hide();
          this.$datepicker.removeClass('show');
          this.$window.off('resize', this._place);
          return this.$document.off('click', this.hide);
        }
      };

      WaveDatepicker.prototype.toggle = function() {
        if (this._isShown) {
          return this.hide();
        } else {
          return this.show();
        }
      };

      WaveDatepicker.prototype.setDate = function(date, options) {
        var today;

        if (typeof date === 'string') {
          date = WDP.DateUtils.parse(date);
        }
        if (!(date instanceof Date)) {
          if (this.allowClear) {
            today = new Date();
            this._state.month = today.getMonth();
            this._state.year = today.getFullYear();
          }
          return;
        }
        this.date = date;
        this._state.month = this.date.getMonth();
        this._state.year = this.date.getFullYear();
        if ((options != null ? options.update : void 0) !== false) {
          this.$el.val(this._formatDate(date));
        }
        if ((options != null ? options.silent : void 0) !== true) {
          this.$el.trigger('change', [
            this.date, $.extend({
              silent: true
            }, options)
          ]);
        }
        if (this.options.hideOnSelect && ((options != null ? options.hide : void 0) || (options != null ? options.hide : void 0) === void 0)) {
          return this.hide();
        }
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
        var picker;

        this.$datepicker.remove();
        this.$el.removeData('datepicker');
        return WDP.datepickers = (function() {
          var _i, _len, _ref, _results;

          _ref = WDP.datepickers;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            picker = _ref[_i];
            if (picker !== this) {
              _results.push(picker);
            }
          }
          return _results;
        }).call(this);
      };

      WaveDatepicker.prototype.setBaseDate = function(date) {
        var _ref;

        return this.baseDate = (_ref = this.shortcuts) != null ? _ref.baseDate = date : void 0;
      };

      WaveDatepicker.prototype.getBaseDate = function() {
        return this.baseDate;
      };

      WaveDatepicker.prototype._initElements = function() {
        if (this.options.className) {
          this.$el.addClass(this.options.className);
        }
        this.$shortcuts = this.$datepicker.find('.wdp-shortcuts');
        this.$main = this.$datepicker.find('.wdp-main');
        this.$calendar = this.$main.find('.wdp-calendar');
        this.$calendarTbody = this.$calendar.find('tbody');
        this.$calendarYear = this.$datepicker.find('.wdp-year-calendar');
        this.$calendarYearTbody = this.$calendarYear.find('tbody');
        this.$calendarMonth = this.$datepicker.find('.wdp-month-calendar');
        this.$calendarMonthTbody = this.$calendarMonth.find('tbody');
        this.$monthAndYear = this.$calendar.find('.wdp-month-and-year');
        this.$window = $(window);
        return this.$document = $(document);
      };

      WaveDatepicker.prototype._initPicker = function() {
        var weekdays, weekdaysMin;

        this.$datepicker = $(WDP.template);
        this.$datepicker.appendTo(document.body);
        weekdaysMin = moment.weekdaysMin || moment.langData()._weekdaysMin;
        weekdays = weekdaysMin.join('</th><th>');
        return this.$datepicker.find('thead').append("<tr class=\"wdp-weekdays\"><th>" + weekdays + "</th></tr>");
      };

      WaveDatepicker.prototype._initEvents = function() {
        var showAndFocus,
          _this = this;

        if ((this.$icon = this.$el.siblings('.add-on')).length) {
          showAndFocus = function(e) {
            _this._cancelEvent(e);
            if (_this._isShown) {
              _this.$el.focus();
            }
            return _this.toggle();
          };
          this.$icon.on('click', showAndFocus);
        } else {
          this.$el.on('focus click mousedown', this.show);
        }
        this.$el.on('blur', this.hide);
        this.$el.on('change', this._updateFromInput);
        this.$el.on('change', this.render);
        this.$el.on('keydown', this._onInputKeydown);
        this.$el.on('click', this._cancelEvent);
        this.$datepicker.on('click', '.js-wdp-calendar-cell', this._selectDate);
        this.$datepicker.on('click', '.js-wdp-prev', this.prev);
        this.$datepicker.on('click', '.js-wdp-next', this.next);
        this.$datepicker.on('click', this._cancelEvent);
        this.$datepicker.on('click', '.js-wdp-set-month-year', this._showYearGrid);
        this.$datepicker.on('click', '.js-wdp-year-calendar-cell', this._showMonthGrid);
        return this.$datepicker.on('mousedown', this._cancelEvent);
      };

      WaveDatepicker.prototype._updateFromInput = function(e, date, options) {
        var dateStr;

        if ((dateStr = this.$el.val())) {
          this.date = this._parseDate(dateStr);
        }
        if (this.allowClear) {
          if (!dateStr) {
            this.date = null;
          }
        } else {
          this.date || (this.date = new Date());
        }
        options = $.extend({
          silent: true
        }, options);
        return this.setDate(this.date, options);
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
        var d, wrapped;

        if ((wrapped = WDP.DateUtils.parse(str, this.dateFormat)).isValid()) {
          d = wrapped.toDate();
          if (d.getFullYear() === 0) {
            d.setFullYear(new Date().getFullYear());
          }
          return d;
        }
        return this.date;
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
        html.push('<tr class="wdp-calendar-row">');
        for (i = _i = 1; _i <= 20; i = ++_i) {
          currentClass = m.year() === this._state.year ? 'wdp-selected' : '';
          html.push("<td class=\"js-wdp-year-calendar-cell " + currentClass + "\" data-date=\"" + (m.format("YYYY-MM-DD")) + "\">" + (m.format("YYYY")) + "</td>");
          if (i % 5 === 0) {
            html.push('</tr>');
            if (i !== 20) {
              html.push('<tr class"wdp-calendar-row">');
            }
          }
          m.add('years', 1);
        }
        this.$calendarYearTbody.html(html.join(''));
        this.$calendar.hide();
        return this.$calendarYear.show();
      };

      WaveDatepicker.prototype._showMonthGrid = function(e) {
        var currentClass, date, html, i, m, _i;

        html = [];
        date = moment(this._parseDate($(e.target).data('date')));
        m = moment(new Date(date.year(), 0, 1));
        html.push('<tr class="wdp-calendar-row">');
        for (i = _i = 1; _i <= 12; i = ++_i) {
          currentClass = m.month() === this._state.month ? 'wdp-selected' : '';
          html.push("<td class=\"js-wdp-calendar-cell " + currentClass + "\" data-date=\"" + (m.format("YYYY-MM-DD")) + "\">" + (m.format("MMM")) + "</td>");
          if (i % 3 === 0) {
            html.push('</tr>');
            if (i !== 12) {
              html.push('<tr class="wdp-calendar-row">');
            }
          }
          m.add('months', 1);
        }
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
        var date, fn, offset, _ref, _ref1, _ref2;

        if (e.metaKey) {
          return;
        }
        switch (e.keyCode) {
          case WDP.Keys.DOWN:
          case WDP.Keys.J:
            if (this._isShown) {
              this._cancelEvent(e);
              fn = (_ref = this.shortcuts) != null ? _ref.selectNext : void 0;
              offset = 7;
            }
            this.show();
            break;
          case WDP.Keys.RETURN:
            if (this._isShown) {
              this.hide();
            } else {
              this.show();
            }
            break;
          case WDP.Keys.UP:
          case WDP.Keys.K:
            if (this._isShown) {
              this._cancelEvent(e);
              fn = (_ref1 = this.shortcuts) != null ? _ref1.selectPrev : void 0;
              offset = -7;
            }
            break;
          case WDP.Keys.LEFT:
          case WDP.Keys.H:
            if (this._isShown) {
              this._cancelEvent(e);
              offset = -1;
            }
            break;
          case WDP.Keys.RIGHT:
          case WDP.Keys.L:
            if (this._isShown) {
              this._cancelEvent(e);
              offset = 1;
            }
            break;
          case WDP.Keys.ESC:
          case WDP.Keys.TAB:
            this.hide();
        }
        if (e.shiftKey) {
          return typeof fn === "function" ? fn() : void 0;
        } else if (offset != null) {
          date = new Date(this.date.getFullYear(), this.date.getMonth(), this.date.getDate() + offset);
          if ((_ref2 = this.shortcuts) != null) {
            _ref2.resetClass();
          }
          return this.setDate(date, {
            hide: false
          });
        }
      };

      WaveDatepicker.prototype._updateSelection = function() {
        var dateStr;

        dateStr = this._formatDate(this.date);
        this.$calendarTbody.find('.wdp-selected').removeClass('wdp-selected');
        return this.$calendarTbody.find("td[data-date='" + dateStr + "']").addClass('wdp-selected');
      };

      WaveDatepicker.prototype._selectDate = function(e) {
        var date, _ref;

        this.$calendarMonth.hide();
        this.$calendar.show();
        if ((_ref = this.shortcuts) != null) {
          _ref.resetClass();
        }
        date = this._parseDate($(e.target).data('date'));
        this.$el.trigger('shortcutclear');
        return this.setDate(date);
      };

      return WaveDatepicker;

    })();
    _oldDatepicker = $.fn.datepicker;
    WDP.init = function() {
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
    $.fn.datepicker = WDP.init;
    WDP.noConflict = function() {
      return $.fn.datepicker = _oldDatepicker;
    };
    return WDP;
  });

}).call(this);
