var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

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
    <div class="wave-datepicker dropdown-menu">\
      <div class="row-fluid">\
        <div class="span5" wave-datepicker-shortcuts>\
        </div>\
        <div class="span7 wave-datepicker-calendar">\
          <table class="table-condensed">\
            <thead>\
              <tr>\
                  <th class="prev">\
                    <i class="icon-arrow-left"/>\
                  </th>\
                  <th colspan="5" class="switch"></th>\
                  <th class="next">\
                    <i class="icon-arrow-right"/>\
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

    function WaveDatepicker(options) {
      this.options = options;
      this.cancelEvent = __bind(this.cancelEvent, this);

      this.onClick = __bind(this.onClick, this);

      this.hide = __bind(this.hide, this);

      this.show = __bind(this.show, this);

      this.el = this.options.el;
      this.$el = $(this.el);
      this.date = this.options.date || new Date();
      this.dateFormat = this.options.format || this._defaultFormat;
      this.initElement();
      this.initPicker();
      this.initEvents();
    }

    WaveDatepicker.prototype.initElement = function() {
      if (this.options.className) {
        this.$el.addClass(this.options.className);
      }
      return this.$el.val(this.formatDate(this.date));
    };

    WaveDatepicker.prototype.initPicker = function() {
      this.$datepicker = $(WDP.template);
      this.$shortcuts = this.$datepicker.find('.wave-datepicker-shortcuts');
      this.$calendar = this.$datepicker.find('.wave-datepicker-calendar');
      this.$tbody = this.$calender.find('tbody');
      return this.$datepicker.appendTo(document.body);
    };

    WaveDatepicker.prototype.initEvents = function() {
      this.$datepicker.on('click', this.onClick);
      this.$datepicker.on('mousedown', this.cancelEvent);
      return this.$el.on('focus', this.show).on('blur', this.hide);
    };

    WaveDatepicker.prototype.render = function() {
      var calendarHTML;
      return calendarHTML = this.$tbody.html(calendarHTML);
    };

    WaveDatepicker.prototype.formatDate = function(date) {
      return WDP.DateUtils.format(date, this.dateFormat);
    };

    WaveDatepicker.prototype.parseDate = function(str) {
      return WDP.DateUtils.parse(date, this.dateFormat);
    };

    WaveDatepicker.prototype.place = function() {
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

    WaveDatepicker.prototype.show = function() {
      this.$datepicker.addClass('show');
      this.height = this.$el.outerHeight();
      return this.place();
    };

    WaveDatepicker.prototype.hide = function() {
      return this.$datepicker.removeClass('show');
    };

    WaveDatepicker.prototype.onClick = function(e) {};

    WaveDatepicker.prototype.cancelEvent = function(e) {
      e.stopPropagation();
      return e.preventDefault();
    };

    return WaveDatepicker;

  })();
  $.fn.datepicker = function(options) {
    if (options == null) {
      options = {};
    }
    return this.each(function() {
      var $this, widget;
      $this = $(this);
      widget = $this.data('datepicker');
      $.extend(options, {
        el: this
      });
      if (!widget) {
        return $this.data('datepicker', (widget = new WDP.WaveDatepicker(options)));
      }
    });
  };
  return WDP;
});
