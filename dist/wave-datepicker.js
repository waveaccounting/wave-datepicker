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
  WDP.template = '\
    <div class="wdp dropdown-menu">\
      <div class="row-fluid">\
        <div class="span4">\
          <ul class="wdp-shortcuts"></ul>\
        </div>\
        <div class="span8">\
          <table class="table-condensed wdp-calendar">\
            <thead>\
              <tr>\
                  <th class="wdp-prev">\
                    <a href="javascript:void(0)" class="js-wdp-prev"><i class="icon-arrow-left"/></a>\
                  </th>\
                  <th colspan="5" class="wdp-month-and-year">\
                  </th>\
                  <th class="wdp-next">\
                    <a href="javascript:void(0)" class="js-wdp-next"><i class="icon-arrow-right"/></a>\
                  </th>\
              </tr>\
            </thead>\
            <tbody>\
            </tbody>\
          </table>\
        </div>\
      </div>\
    </div>';
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
  WDP.WaveDatepicker = (function() {

    WaveDatepicker.prototype._defaultFormat = 'YYYY-MM-DD';

    WaveDatepicker.prototype._defaultShortcuts = {
      'Today': {
        days: 0
      }
    };

    WaveDatepicker.prototype._state = null;

    function WaveDatepicker(options) {
      var dateStr;
      this.options = options;
      this._selectDate = __bind(this._selectDate, this);

      this._onShortcutClick = __bind(this._onShortcutClick, this);

      this._cancelEvent = __bind(this._cancelEvent, this);

      this._place = __bind(this._place, this);

      this._updateMonthAndYear = __bind(this._updateMonthAndYear, this);

      this.destroy = __bind(this.destroy, this);

      this.nextSelect = __bind(this.nextSelect, this);

      this.next = __bind(this.next, this);

      this.prevSelect = __bind(this.prevSelect, this);

      this.prev = __bind(this.prev, this);

      this.setDate = __bind(this.setDate, this);

      this.hide = __bind(this.hide, this);

      this.show = __bind(this.show, this);

      this.render = __bind(this.render, this);

      this.el = this.options.el;
      this.$el = $(this.el);
      this.dateFormat = this.options.format || this._defaultFormat;
      if ((dateStr = this.$el.val())) {
        this.date = this._parseDate(dateStr);
      }
      this.date || (this.date = new Date());
      this.shortcuts = options.shortcuts || this._defaultShortcuts;
      this._initState();
      this._initPicker();
      this._initElements();
      this._initShortcuts();
      this._initEvents();
    }

    WaveDatepicker.prototype.render = function() {
      this._updateMonthAndYear();
      this._fill();
      this._updateSelection();
      return this;
    };

    WaveDatepicker.prototype.show = function() {
      this.$datepicker.addClass('show');
      this.height = this.$el.outerHeight();
      this._place();
      return this.$window.on('resize', this._place);
    };

    WaveDatepicker.prototype.hide = function() {
      this.$datepicker.removeClass('show');
      return this.$window.off('resize', this._place);
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

    WaveDatepicker.prototype.prevSelect = function(e) {
      this.prev;
      return this._selectDate(e);
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

    WaveDatepicker.prototype.nextSelect = function(e) {
      this.next;
      return this._selectDate(e);
    };

    WaveDatepicker.prototype.destroy = function() {
      return this.$datepicker.remove();
    };

    WaveDatepicker.prototype._initElements = function() {
      if (this.options.className) {
        this.$el.addClass(this.options.className);
      }
      this.$el.val(this._formatDate(this.date));
      this.$shortcuts = this.$datepicker.find('.wdp-shortcuts');
      this.$calendar = this.$datepicker.find('.wdp-calendar');
      this.$tbody = this.$calendar.find('tbody');
      this.$monthAndYear = this.$calendar.find('.wdp-month-and-year');
      return this.$window = $(window);
    };

    WaveDatepicker.prototype._initState = function() {
      this._state = {};
      return this.setDate(this.date);
    };

    WaveDatepicker.prototype._initPicker = function() {
      this.$datepicker = $(WDP.template);
      return this.$datepicker.appendTo(document.body);
    };

    WaveDatepicker.prototype._initShortcuts = function() {
      var name, offset, shortcuts, _ref;
      shortcuts = [];
      _ref = this.shortcuts;
      for (name in _ref) {
        offset = _ref[name];
        shortcuts.push("<li><a data-shortcut=\"" + name + "\" class=\"wdp-shortcut js-wdp-shortcut\" href=\"javascript:void(0)\">          " + name + "</a></li>");
      }
      return this.$shortcuts.html(shortcuts.join(''));
    };

    WaveDatepicker.prototype._initEvents = function() {
      this.$el.on('focus', this.show).on('blur', this.hide);
      this.$el.on('datechange', this.render);
      this.$datepicker.on('mousedown', this._cancelEvent);
      this.$datepicker.on('click', '.js-wdp-calendar-cell', this._selectDate);
      this.$datepicker.on('click', '.js-wdp-prev', this.prev);
      this.$datepicker.on('click', '.js-wdp-prev-select', this.prevSelect);
      this.$datepicker.on('click', '.js-wdp-next', this.next);
      this.$datepicker.on('click', '.js-wdp-next-select', this.nextSelect);
      return this.$datepicker.on('click', '.js-wdp-shortcut', this._onShortcutClick);
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

    WaveDatepicker.prototype._fill = function() {
      var currMonth, d, date, daysInMonth, endOfMonth, firstDateDay, formatted, formattedNextMonth, formattedPrevMonth, html, i, index, lastDateDay, n, nextMonth, paddingStart, prevMonth, startOfMonth, wrapped, _i, _j;
      date = new Date(this._state.year, this._state.month, 1);
      index = 0;
      html = [];
      wrapped = moment(date);
      daysInMonth = wrapped.daysInMonth();
      startOfMonth = wrapped.clone().startOf('month');
      endOfMonth = wrapped.clone().endOf('month');
      firstDateDay = startOfMonth.day() - 1;
      lastDateDay = endOfMonth.day() - 1;
      paddingStart = 0;
      if (firstDateDay !== 0) {
        prevMonth = startOfMonth.clone();
        for (i = _i = 0; 0 <= firstDateDay ? _i <= firstDateDay : _i >= firstDateDay; i = 0 <= firstDateDay ? ++_i : --_i) {
          if ((index++) === 0) {
            html.push('<tr class="wdp-calendar-row">');
          }
          d = prevMonth.add('days', -1).date();
          formattedPrevMonth = this._formatDate(new Date(this._state.year, this._state.month - 1, d));
          html[6 - i + 1] = "<td class=\"wdp-calendar-othermonth js-wdp-prev-select\" data-date=\"" + formattedPrevMonth + "\">" + d + "</td>";
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
      n = paddingStart + daysInMonth;
      while (index < 42) {
        d = nextMonth.add('days', 1).date();
        formattedNextMonth = this._formatDate(new Date(this._state.year, this._state.month + 1, d));
        if ((index++) % 7 === 0) {
          html.push('</tr><tr class="wdp-calendar-row">');
        }
        html.push("<td class=\"wdp-calendar-othermonth js-wdp-next-select\" data-date=\"" + formattedNextMonth + "\">" + d + "</td>");
      }
      html.push('</tr>');
      return this.$tbody.html(html.join(''));
    };

    WaveDatepicker.prototype._cancelEvent = function(e) {
      e.stopPropagation();
      return e.preventDefault();
    };

    WaveDatepicker.prototype._onShortcutClick = function(e) {
      var $shortcut, k, name, offset, v, wrapper;
      $shortcut = $(e.target);
      name = $shortcut.data('shortcut');
      offset = this.shortcuts[name];
      wrapper = moment(new Date());
      for (k in offset) {
        v = offset[k];
        wrapper.add(k, v);
      }
      this._clearActiveShortcutClass();
      $shortcut.addClass('wdp-shortcut-active');
      return this.setDate(wrapper.toDate());
    };

    WaveDatepicker.prototype._clearActiveShortcutClass = function() {
      return this.$shortcuts.find('.wdp-shortcut-active').removeClass('wdp-shortcut-active');
    };

    WaveDatepicker.prototype._updateSelection = function() {
      var dateStr;
      dateStr = this._formatDate(this.date);
      this.$tbody.find('.wdp-selected').removeClass('wdp-selected');
      return this.$tbody.find("td[data-date=" + dateStr + "]").addClass('wdp-selected');
    };

    WaveDatepicker.prototype._selectDate = function(e) {
      var date;
      this._clearActiveShortcutClass();
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
