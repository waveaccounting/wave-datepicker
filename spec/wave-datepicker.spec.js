
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
      return it('should draw the calendar with current month and fill start/end with prev/next month', function() {
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
      return describe('_cancelEvent', function() {
        var e;
        e = {
          stopPropagation: sinon.spy(),
          preventDefault: sinon.spy()
        };
        WDP.WaveDatepicker.prototype._cancelEvent.call(null, e);
        expect(e.stopPropagation.callCount).not.toEqual(0);
        return expect(e.preventDefault.callCount).not.toEqual(0);
      });
    });
  });
});
