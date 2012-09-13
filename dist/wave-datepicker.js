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
    <div class="wdp dropdown-menu">\
      <div class="row-fluid">\
        <div class="span5" wdp-shortcuts>\
        </div>\
        <div class="span7 wdp-calendar">\
          <table class="table-condensed">\
            <thead>\
              <tr>\
                  <th class="wdp-prev js-wdp-prev span1">\
                    <i class="icon-arrow-left"/>\
                  </th>\
                  <th colspan="5" class="wdp-month-and-year span10">\
                  </th>\
                  <th class="wdp-next js-wdp-next span1">\
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

      this.place = __bind(this.place, this);

      this.el = this.options.el;
      this.$el = $(this.el);
      this.dateFormat = this.options.format || this._defaultFormat;
      this.updateDate();
      this.date || (this.date = new Date());
      this.initPicker();
      this.initElements();
      this.initEvents();
    }

    WaveDatepicker.prototype.initElements = function() {
      if (this.options.className) {
        this.$el.addClass(this.options.className);
      }
      this.$el.val(this.formatDate(this.date));
      this.$shortcuts = this.$datepicker.find('.wdp-shortcuts');
      this.$calendar = this.$datepicker.find('.wdp-calendar');
      this.$tbody = this.$calendar.find('tbody');
      return this.$window = $(window);
    };

    WaveDatepicker.prototype.initPicker = function() {
      this.$datepicker = $(WDP.template);
      return this.$datepicker.appendTo(document.body);
    };

    WaveDatepicker.prototype.initEvents = function() {
      this.$datepicker.on('click', this.onClick);
      this.$datepicker.on('mousedown', this.cancelEvent);
      return this.$el.on('focus', this.show).on('blur', this.hide);
    };

    WaveDatepicker.prototype.updateDate = function() {
      var dateStr;
      if ((dateStr = this.$el.val())) {
        return this.date = this.parseDate(dateStr);
      }
    };

    WaveDatepicker.prototype.render = function() {
      var calendarHTML;
      return calendarHTML = this.$tbody.html(calendarHTML);
    };

    WaveDatepicker.prototype.formatDate = function(date) {
      return WDP.DateUtils.format(date, this.dateFormat);
    };

    WaveDatepicker.prototype.parseDate = function(str) {
      return WDP.DateUtils.parse(str, this.dateFormat);
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
      this.place();
      return this.$window.on('resize', this.place);
    };

    WaveDatepicker.prototype.hide = function() {
      this.$datepicker.removeClass('show');
      return this.$window.off('resize', this.place);
    };

    WaveDatepicker.prototype.onClick = function(e) {};

    WaveDatepicker.prototype.cancelEvent = function(e) {
      e.stopPropagation();
      return e.preventDefault();
    };

    WaveDatepicker.prototype.bindWindowResize = function() {};

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
