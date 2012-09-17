
describe('Wave Datepicker', function() {
  beforeEach(function() {
    this.$input = $('<input id="Date">').appendTo(document.body);
    this.stubWaveDatepicker = function() {
      this._WaveDatepicker = {
        render: sinon.stub(),
        destroy: sinon.stub()
      };
      this._WaveDatepicker.render.returns(this._WaveDatepicker);
      this._WaveDatepickerStub = sinon.stub(WDP, 'WaveDatepicker');
      return this._WaveDatepickerStub.returns(this._WaveDatepicker);
    };
    return this.restoreWaveDatepicker = function() {
      return this._WaveDatepickerStub.restore();
    };
  });
  afterEach(function() {
    this.$input.datepicker('destroy');
    return this.$input.remove();
  });
  return describe('$.fn.datepicker', function() {
    it('should be defined on jQuery object', function() {
      return expect(this.$input.datepicker).toEqual(jasmine.any(Function));
    });
    it('should instantiate the WaveDatepicker call', function() {
      this.stubWaveDatepicker();
      this.$input.datepicker();
      expect(this._WaveDatepickerStub).toHaveBeenCalledOnce();
      return this.restoreWaveDatepicker();
    });
    it('should not instantiate datepicker twice on same element', function() {
      this.stubWaveDatepicker();
      this.$input.datepicker();
      this.$input.datepicker();
      expect(this._WaveDatepickerStub).toHaveBeenCalledOnce();
      return this.restoreWaveDatepicker();
    });
    it('should set the datepicker widget as data on the <input>', function() {
      this.stubWaveDatepicker();
      this.$input.datepicker();
      expect(this.$input.data('datepicker')).toEqual(this._WaveDatepicker);
      return this.restoreWaveDatepicker();
    });
    it('should use the value attribute to set default date', function() {
      var date;
      this.$input.val('2012-08-01').datepicker();
      date = this.$input.data('datepicker').date;
      expect(date).toBeDefined();
      expect(date.getFullYear()).toEqual(2012);
      expect(date.getMonth()).toEqual(7);
      return expect(date.getDate()).toEqual(1);
    });
    it('should set today as the default is value not set on <input>', function() {
      var date, today;
      this.$input.datepicker();
      date = this.$input.data('datepicker').date;
      today = new Date();
      expect(date).toBeDefined();
      expect(date.getFullYear()).toEqual(today.getFullYear());
      expect(date.getMonth()).toEqual(today.getMonth());
      return expect(date.getDate()).toEqual(today.getDate());
    });
    describe('Shortcuts', function() {
      return it('should by default provide the Today shortcut', function() {
        var today, widget;
        this.$input.datepicker();
        widget = this.$input.data('datepicker');
        expect(widget.$datepicker).toContain('.wdp-shortcut');
        today = widget.$datepicker.find('.wdp-shortcut');
        return expect($.trim(today.text())).toEqual('Today');
      });
    });
    describe('On input change', function() {
      return it('should update the date of the the widget', function() {
        var date, widget;
        this.$input.val('2012-08-01').datepicker();
        date = new Date(2012, 7, 1);
        widget = this.$input.data('datepicker');
        expect(widget.date.getFullYear()).toEqual(date.getFullYear());
        expect(widget.date.getMonth()).toEqual(date.getMonth());
        expect(widget.date.getDate()).toEqual(date.getDate());
        this.$input.val('2011-04-13').trigger('change');
        date = new Date(2011, 3, 13);
        expect(widget.date.getFullYear()).toEqual(date.getFullYear());
        expect(widget.date.getMonth()).toEqual(date.getMonth());
        return expect(widget.date.getDate()).toEqual(date.getDate());
      });
    });
    describe('Rendered calendar', function() {
      it('should draw the calendar with current month and fill start/end with prev/next month', function() {
        var $cells, array, expected;
        this.$input.val('2012-08-01').datepicker();
        $cells = this.$input.data('datepicker').$calendar.find('td');
        expected = [29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8];
        array = [];
        $cells.each(function() {
          return array.push(parseInt($.trim($(this).text()), 10));
        });
        expect(array).toEqual(expected);
        this.$input.val('2014-11-13').trigger('change');
        $cells = this.$input.data('datepicker').$calendar.find('td');
        expected = [26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 1, 2, 3, 4, 5, 6];
        array = [];
        $cells.each(function() {
          return array.push(parseInt($.trim($(this).text()), 10));
        });
        expect(array).toEqual(expected);
        this.$input.val('1900-01-01').trigger('change');
        $cells = this.$input.data('datepicker').$calendar.find('td');
        expected = [31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        array = [];
        $cells.each(function() {
          return array.push(parseInt($.trim($(this).text()), 10));
        });
        expect(array).toEqual(expected);
        this.$input.val('2996-07-12').trigger('change');
        $cells = this.$input.data('datepicker').$calendar.find('td');
        expected = [26, 27, 28, 29, 30, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6];
        array = [];
        $cells.each(function() {
          return array.push(parseInt($.trim($(this).text()), 10));
        });
        return expect(array).toEqual(expected);
      });
      it('should have weekday names in table header', function() {
        var $cells, array;
        this.$input.val('2012-08-01').datepicker();
        $cells = this.$input.data('datepicker').$calendar.find('.wdp-weekdays > th');
        array = [];
        $cells.each(function() {
          return array.push($.trim($(this).text()));
        });
        return expect(array).toEqual(['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']);
      });
      return it('should have month and year in table header', function() {
        var monthAndYear;
        this.$input.val('2012-08-01').datepicker();
        monthAndYear = $.trim(this.$input.data('datepicker').$calendar.find('.wdp-month-and-year').text());
        return expect(monthAndYear).toEqual('August 2012');
      });
    });
    describe('Navigation', function() {
      beforeEach(function() {
        this.$input.val('2012-08-01').datepicker();
        return this.widget = this.$input.data('datepicker');
      });
      describe('When next arrow is clicked', function() {
        beforeEach(function() {
          this.$next = this.widget.$datepicker.find('.js-wdp-next');
          return this.$next.click();
        });
        return it('should set the month and year of state', function() {
          this.$next.click();
          expect(this.widget._state.month).toEqual(9);
          expect(this.widget._state.year).toEqual(2012);
          this.$next.click().click().click().click();
          expect(this.widget._state.month).toEqual(1);
          return expect(this.widget._state.year).toEqual(2013);
        });
      });
      return describe('When prev arrow is clicked', function() {
        beforeEach(function() {
          this.$input.val('2012-03-01').trigger('change');
          return this.$prev = this.widget.$datepicker.find('.js-wdp-prev');
        });
        return it('should set the month and year of state', function() {
          this.$prev.click();
          expect(this.widget._state.month).toEqual(1);
          expect(this.widget._state.year).toEqual(2012);
          this.$prev.click().click();
          expect(this.widget._state.month).toEqual(11);
          return expect(this.widget._state.year).toEqual(2011);
        });
      });
    });
    return describe('Unit tests', function() {
      it('_cancelEvent', function() {
        var e;
        e = {
          stopPropagation: sinon.spy(),
          preventDefault: sinon.spy()
        };
        WDP.WaveDatepicker.prototype._cancelEvent.call(null, e);
        expect(e.stopPropagation).toHaveBeenCalledOnce();
        return expect(e.preventDefault).toHaveBeenCalledOnce();
      });
      describe('_initEvents', function() {
        beforeEach(function() {
          this.context = {
            $datepicker: {
              on: sinon.spy()
            },
            $el: {
              on: sinon.stub()
            },
            _cancelEvent: sinon.spy(),
            prev: sinon.spy(),
            next: sinon.spy(),
            _prevSelect: sinon.spy(),
            _nextSelect: sinon.spy(),
            _onShortcutClick: sinon.spy(),
            _selectDate: sinon.spy(),
            render: sinon.spy(),
            _updateFromInput: sinon.spy(),
            show: sinon.spy(),
            hide: sinon.spy()
          };
          return this.context.$el.on.returns(this.context.$el);
        });
        it('should bind cancel events to mousedown on datepicker', function() {
          WDP.WaveDatepicker.prototype._initEvents.call(this.context);
          return expect(this.context.$datepicker.on).toHaveBeenCalledWith('mousedown', this.context._cancelEvent);
        });
        it('should bind the prev/next callbacks to their corresponding elements', function() {
          WDP.WaveDatepicker.prototype._initEvents.call(this.context);
          expect(this.context.$datepicker.on).toHaveBeenCalledWith('click', '.js-wdp-prev', this.context.prev);
          expect(this.context.$datepicker.on).toHaveBeenCalledWith('click', '.js-wdp-next', this.context.next);
          expect(this.context.$datepicker.on).toHaveBeenCalledWith('click', '.js-wdp-prev-select', this.context._prevSelect);
          return expect(this.context.$datepicker.on).toHaveBeenCalledWith('click', '.js-wdp-next-select', this.context._nextSelect);
        });
        it('should bind datechange event to render method', function() {
          WDP.WaveDatepicker.prototype._initEvents.call(this.context);
          return expect(this.context.$el.on).toHaveBeenCalledWith('datechange', this.context.render);
        });
        it('should bind input change event to update method', function() {
          WDP.WaveDatepicker.prototype._initEvents.call(this.context);
          return expect(this.context.$el.on).toHaveBeenCalledWith('change', this.context._updateFromInput);
        });
        return it('should bind show/hide to focus/blur event', function() {
          WDP.WaveDatepicker.prototype._initEvents.call(this.context);
          expect(this.context.$el.on).toHaveBeenCalledWith('focus', this.context.show);
          return expect(this.context.$el.on).toHaveBeenCalledWith('blur', this.context.hide);
        });
      });
      describe('setDate', function() {
        return it('should update the date, state, and <inpput> of the widget', function() {
          var context, date;
          context = {
            _formatDate: sinon.stub(),
            $el: {
              val: sinon.spy(),
              trigger: sinon.spy()
            },
            _state: {}
          };
          context._formatDate.returns('FORMATTED');
          date = {
            getMonth: function() {
              return 'MONTH';
            },
            getFullYear: function() {
              return 'YEAR';
            }
          };
          WDP.WaveDatepicker.prototype.setDate.call(context, date);
          expect(context.date).toEqual(date);
          expect(context._state.month).toEqual('MONTH');
          expect(context._state.year).toEqual('YEAR');
          return expect(context.$el.trigger).toHaveBeenCalledWith('datechange', date);
        });
      });
      describe('next', function() {
        it('should increment month then call render method', function() {
          var context;
          context = {
            _state: {
              month: 7
            },
            render: sinon.spy()
          };
          WDP.WaveDatepicker.prototype.next.call(context);
          expect(context._state.month).toBe(8);
          return expect(context.render).toHaveBeenCalledOnce();
        });
        return it('should go to next year if month is 12', function() {
          var context;
          context = {
            _state: {
              month: 12,
              year: 2012
            },
            render: sinon.spy()
          };
          WDP.WaveDatepicker.prototype.next.call(context);
          expect(context._state.month).toBe(1);
          return expect(context._state.year).toBe(2013);
        });
      });
      describe('prev', function() {
        it('should decrement month then call render method', function() {
          var context;
          context = {
            _state: {
              month: 7
            },
            render: sinon.spy()
          };
          WDP.WaveDatepicker.prototype.prev.call(context);
          expect(context._state.month).toBe(6);
          return expect(context.render).toHaveBeenCalledOnce();
        });
        return it('should go to prev year if month is 1', function() {
          var context;
          context = {
            _state: {
              month: 1,
              year: 2012
            },
            render: sinon.spy()
          };
          WDP.WaveDatepicker.prototype.prev.call(context);
          expect(context._state.month).toBe(12);
          return expect(context._state.year).toBe(2011);
        });
      });
      describe('getDate', function() {
        return it('should return widget date', function() {
          var context, date;
          context = {
            date: 'DATE'
          };
          date = WDP.WaveDatepicker.prototype.getDate.call(context);
          return expect(date).toBe(context.date);
        });
      });
      describe('show', function() {
        return it('should place datepicker and show it', function() {
          var context, date;
          context = {
            $datepicker: {
              addClass: sinon.spy()
            },
            $el: {
              outerHeight: sinon.stub()
            },
            _place: sinon.spy(),
            $window: {
              on: sinon.spy()
            }
          };
          context.$el.outerHeight.returns('HEIGHT');
          date = WDP.WaveDatepicker.prototype.show.call(context);
          expect(context.$datepicker.addClass).toHaveBeenCalledWith('show');
          expect(context.height).toBe('HEIGHT');
          expect(context._place).toHaveBeenCalledOnce();
          return expect(context.$window.on).toHaveBeenCalledWith('resize', context._place);
        });
      });
      return describe('hide', function() {
        return it('should hide datepicker and unbind place callback from window resize', function() {
          var context, date;
          context = {
            $datepicker: {
              removeClass: sinon.spy()
            },
            _place: 'PLACE',
            $window: {
              off: sinon.spy()
            }
          };
          date = WDP.WaveDatepicker.prototype.hide.call(context);
          expect(context.$datepicker.removeClass).toHaveBeenCalledWith('show');
          return expect(context.$window.off).toHaveBeenCalledWith('resize', context._place);
        });
      });
    });
  });
});
