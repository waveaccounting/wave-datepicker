(function() {
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
        return expect(this.$input.datepicker).to.be["instanceof"](Function);
      });
      it('should instantiate the WaveDatepicker call', function() {
        this.stubWaveDatepicker();
        this.$input.datepicker();
        expect(this._WaveDatepickerStub.calledOnce).to.be["true"];
        return this.restoreWaveDatepicker();
      });
      it('should not instantiate datepicker twice on same element', function() {
        this.stubWaveDatepicker();
        this.$input.datepicker();
        this.$input.datepicker();
        expect(this._WaveDatepickerStub.calledOnce).to.be["true"];
        return this.restoreWaveDatepicker();
      });
      it('should set the datepicker widget as data on the <input>', function() {
        this.stubWaveDatepicker();
        this.$input.datepicker();
        expect(this.$input.data('datepicker')).to.eql(this._WaveDatepicker);
        return this.restoreWaveDatepicker();
      });
      it('should use the value attribute to set default date', function() {
        var date;

        this.$input.val('2012-08-01').datepicker();
        date = this.$input.data('datepicker').date;
        expect(date).to.be.defined;
        expect(date.getFullYear()).to.eql(2012);
        expect(date.getMonth()).to.eql(7);
        return expect(date.getDate()).to.eql(1);
      });
      it('should set today as the default is value not set on <input>', function() {
        var date, today;

        this.$input.datepicker();
        date = this.$input.data('datepicker').date;
        today = new Date();
        expect(date).to.be.defined;
        expect(date.getFullYear()).to.eql(today.getFullYear());
        expect(date.getMonth()).to.eql(today.getMonth());
        return expect(date.getDate()).to.eql(today.getDate());
      });
      describe('Shortcuts', function() {
        it('should by default not have shortcuts', function() {
          var widget;

          this.$input.datepicker();
          widget = this.$input.data('datepicker');
          return expect(widget.$datepicker.find('.wdp-shortcut').length === 0).to.be["true"];
        });
        it('should provide default options if `shortcuts` is passed as true', function() {
          var today, widget;

          this.$input.datepicker({
            shortcuts: true
          });
          widget = this.$input.data('datepicker');
          expect(widget.$datepicker.find('.wdp-shortcut').length === 0).to.be["false"];
          today = widget.$datepicker.find('.wdp-shortcut');
          return expect($.trim(today.text())).to.eql('Today');
        });
        it('should attach extra element attributes if they are provided', function() {
          var widget;

          this.$input.datepicker({
            shortcuts: {
              'Foo': {
                days: 1,
                attrs: {
                  'data-bar': 'abc'
                }
              }
            }
          });
          widget = this.$input.data('datepicker');
          return expect(widget.shortcuts.$el.find('[data-bar=abc]').length > 0).to.be["true"];
        });
        return describe('When a shortcut is clicked', function() {
          return it('should add the corresponding offset to the widget date', function() {
            var expected, offsets, today, widget;

            offsets = {
              days: 5,
              months: 1,
              years: -1
            };
            this.$input.datepicker({
              'shortcuts': {
                'Foo': offsets
              }
            });
            today = new Date();
            expected = moment(new Date()).add(offsets).toDate();
            widget = this.$input.data('datepicker');
            widget.$datepicker.find('.wdp-shortcut').click();
            expect(widget.date.getFullYear()).to.equal(expected.getFullYear());
            expect(widget.date.getMonth()).to.equal(expected.getMonth());
            return expect(widget.date.getDate()).to.equal(expected.getDate());
          });
        });
      });
      describe('On input change', function() {
        it('should update the date of the the widget', function() {
          var date, widget;

          this.$input.val('2012-08-01').datepicker();
          date = new Date(2012, 7, 1);
          widget = this.$input.data('datepicker');
          expect(widget.date.getFullYear()).to.eql(date.getFullYear());
          expect(widget.date.getMonth()).to.eql(date.getMonth());
          expect(widget.date.getDate()).to.eql(date.getDate());
          this.$input.val('2011-04-13').trigger('change');
          date = new Date(2011, 3, 13);
          expect(widget.date.getFullYear()).to.eql(date.getFullYear());
          expect(widget.date.getMonth()).to.eql(date.getMonth());
          return expect(widget.date.getDate()).to.eql(date.getDate());
        });
        return describe('when input value is bad', function() {
          return it('should not change the date', function() {
            var originalDate, widget;

            this.$input.val('2012-08-01').datepicker();
            widget = this.$input.data('datepicker');
            originalDate = widget.date;
            this.$input.val('some bad value').trigger('change');
            return expect(widget.date).to.equal(originalDate);
          });
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
          expect(array).to.eql(expected);
          this.$input.val('2014-11-13').trigger('change');
          $cells = this.$input.data('datepicker').$calendar.find('td');
          expected = [26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 1, 2, 3, 4, 5, 6];
          array = [];
          $cells.each(function() {
            return array.push(parseInt($.trim($(this).text()), 10));
          });
          expect(array).to.eql(expected);
          this.$input.val('1900-01-01').trigger('change');
          $cells = this.$input.data('datepicker').$calendar.find('td');
          expected = [31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
          array = [];
          $cells.each(function() {
            return array.push(parseInt($.trim($(this).text()), 10));
          });
          expect(array).to.eql(expected);
          this.$input.val('2996-07-12').trigger('change');
          $cells = this.$input.data('datepicker').$calendar.find('td');
          expected = [26, 27, 28, 29, 30, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6];
          array = [];
          $cells.each(function() {
            return array.push(parseInt($.trim($(this).text()), 10));
          });
          return expect(array).to.eql(expected);
        });
        it('should have weekday names in table header', function() {
          var $cells, array;

          this.$input.val('2012-08-01').datepicker();
          $cells = this.$input.data('datepicker').$calendar.find('.wdp-weekdays > th');
          array = [];
          $cells.each(function() {
            return array.push($.trim($(this).text()));
          });
          return expect(array).to.eql(['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']);
        });
        return it('should have month and year in table header', function() {
          var monthAndYear;

          this.$input.val('2012-08-01').datepicker();
          monthAndYear = $.trim(this.$input.data('datepicker').$calendar.find('.wdp-month-and-year').text());
          return expect(monthAndYear).to.eql('August 2012');
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
            expect(this.widget._state.month).to.eql(9);
            expect(this.widget._state.year).to.eql(2012);
            this.$next.click().click().click().click();
            expect(this.widget._state.month).to.eql(1);
            return expect(this.widget._state.year).to.eql(2013);
          });
        });
        return describe('When prev arrow is clicked', function() {
          beforeEach(function() {
            this.$input.val('2012-03-01').trigger('change');
            return this.$prev = this.widget.$datepicker.find('.js-wdp-prev');
          });
          return it('should set the month and year of state', function() {
            this.$prev.click();
            expect(this.widget._state.month).to.eql(1);
            expect(this.widget._state.year).to.eql(2012);
            this.$prev.click().click();
            expect(this.widget._state.month).to.eql(11);
            return expect(this.widget._state.year).to.eql(2011);
          });
        });
      });
      describe('Multiple pickers on page', function() {
        beforeEach(function() {
          this.$input.datepicker();
          this.$input2 = $('<input id="Date2">').appendTo(document.body).datepicker();
          this.$input3 = $('<input id="Date3">').appendTo(document.body).datepicker();
          this.picker1 = this.$input.data('datepicker');
          this.picker2 = this.$input2.data('datepicker');
          return this.picker3 = this.$input3.data('datepicker');
        });
        afterEach(function() {
          this.$input2.datepicker('destroy');
          this.$input2.remove();
          this.$input3.datepicker('destroy');
          return this.$input3.remove();
        });
        return describe('When a click is on a different picker than current active picker', function() {
          return it('should set new focus and hide inactive picker', function() {
            this.$input.focus();
            expect(this.picker1._isShown).to.be["true"];
            expect(this.picker2._isShown).to.be["false"];
            expect(this.picker3._isShown).to.be["false"];
            this.$input2.focus();
            expect(this.picker1._isShown).to.be["false"];
            expect(this.picker2._isShown).to.be["true"];
            expect(this.picker3._isShown).to.be["false"];
            this.$input3.focus();
            expect(this.picker1._isShown).to.be["false"];
            expect(this.picker2._isShown).to.be["false"];
            return expect(this.picker3._isShown).to.be["true"];
          });
        });
      });
      describe('Base date', function() {
        return it('should be used to calcualte shortcuts', function() {
          var expected, widget;

          expected = new Date(2012, 7, 1);
          this.$input.datepicker({
            baseDate: expected,
            shortcuts: {
              'Right away': {
                days: 1
              }
            }
          });
          widget = this.$input.data('datepicker');
          widget.$datepicker.find('.wdp-shortcut').click();
          expect(widget.date.getFullYear()).to.eql(expected.getFullYear());
          expect(widget.date.getMonth()).to.eql(expected.getMonth());
          return expect(widget.date.getDate()).to.eql(expected.getDate() + 1);
        });
      });
      describe('Add-on icon trigger', function() {
        beforeEach(function() {
          this.$box = $('<div class="input-append"><input id="Date2"><span class="add-on">*</span></div>').appendTo(document.body);
          return this.$box.find('input').datepicker();
        });
        afterEach(function() {
          this.$box.find('input').datepicker('destroy');
          return this.$box.remove();
        });
        return it('should open datepicker when the add-on icon is clicked', function() {
          var picker;

          this.$box.find('.add-on').click();
          picker = this.$box.find('input').data('datepicker');
          return expect(picker._isShown).to.be["true"];
        });
      });
      describe('Date format', function() {
        describe('when the format option is passed', function() {
          return it('should use that format string to parse and format dates', function() {
            var date;

            this.$input.val('2012/08/31');
            this.$input.datepicker({
              format: 'YYYY/MM/DD'
            });
            date = this.$input.data('datepicker').date;
            expect(date).to.be.defined;
            expect(date.getFullYear()).to.eql(2012);
            expect(date.getMonth()).to.eql(7);
            return expect(date.getDate()).to.eql(31);
          });
        });
        describe('when date data-date-format is set on the <input>', function() {
          return it('should use that format string to parse and format dates', function() {
            var date;

            this.$input.val('2012/08/31').attr('data-date-format', 'YYYY/MM/DD');
            this.$input.datepicker();
            date = this.$input.data('datepicker').date;
            expect(date).to.be.defined;
            expect(date.getFullYear()).to.eql(2012);
            expect(date.getMonth()).to.eql(7);
            return expect(date.getDate()).to.eql(31);
          });
        });
        return describe('when the date format does not include year', function() {
          return it('should use the current year', function() {
            var date;

            this.$input.val('12-31').attr('data-date-format', 'MM-DD');
            this.$input.datepicker();
            date = this.$input.data('datepicker').date;
            expect(date).to.be.defined;
            expect(date.getFullYear()).to.eql(new Date().getFullYear());
            expect(date.getMonth()).to.eql(11);
            return expect(date.getDate()).to.eql(31);
          });
        });
      });
      describe('Allow clear', function() {
        describe('when data-date-allow-clear is "yes" on the <input>', function() {
          return it('should allow user to null out the date', function() {
            this.$input.val('');
            this.$input.attr('data-date-allow-clear', 'yes');
            this.$input.datepicker();
            return expect(this.$input.datepicker('getDate')).to.be["null"];
          });
        });
        describe('when data-date-allow-clear is "true" on the <input>', function() {
          return it('should allow user to null out the date', function() {
            this.$input.val('');
            this.$input.attr('data-date-allow-clear', 'true');
            this.$input.datepicker();
            return expect(this.$input.datepicker('getDate')).to.be["null"];
          });
        });
        return describe('when allowClear is passed inside the options', function() {
          beforeEach(function() {
            this.$input.val('');
            return this.$input.datepicker({
              allowClear: true
            });
          });
          it('should allow user to null out the date', function() {
            return expect(this.$input.datepicker('getDate')).to.be["null"];
          });
          return describe('when user clears out the <input> after setting it', function() {
            return it('should null out the date', function() {
              this.$input.val('2013-01-01').trigger('change');
              expect(this.$input.datepicker('getDate')).not.to.be["null"];
              this.$input.val('').trigger('change');
              return expect(this.$input.datepicker('getDate')).to.be["null"];
            });
          });
        });
      });
      describe('Min date', function() {
        return describe('when dateMin is set in the options', function() {
          it('should disable all dates before the min', function() {
            var $cells, baseDate;

            baseDate = new Date(2013, 4, 10, 0, 0, 0, 0);
            this.$input.val('2013-05-15').datepicker({
              dateMin: new Date(2013, 4, 10)
            });
            $cells = this.$input.data('datepicker').$calendar.find('td');
            return $cells.each(function(i, cell) {
              var $cell, date;

              $cell = $(cell);
              date = moment($cell.data('date'), 'YYYY-MM-DD').toDate();
              if (date.valueOf() < baseDate.valueOf()) {
                return expect($cell.hasClass('wdp-disabled')).to.be["true"];
              }
            });
          });
          describe('when a cell is clicked outside of max date', function() {
            return it('should not select it', function() {
              var origVal;

              this.$input.val('2013-05-15').datepicker({
                dateMin: new Date(2013, 4, 20)
              });
              origVal = this.$input.val();
              this.$input.find('.wdp-disabled').eq(0).click();
              return expect(this.$input.val()).to.equal(origVal);
            });
          });
          return describe('when setDate is called with a date that is < min', function() {
            return it('should not set it', function() {
              var origVal;

              this.$input.val('2013-05-15').datepicker({
                dateMin: new Date(2013, 4, 20)
              });
              origVal = this.$input.val();
              this.$input.datepicker('setDate', new Date(2012, 0, 1));
              return expect(this.$input.val()).to.equal(origVal);
            });
          });
        });
      });
      return describe('Max date', function() {
        return describe('when dateMax is set in the options', function() {
          it('should disable all dates before the max', function() {
            var $cells, baseDate;

            baseDate = new Date(2013, 4, 20, 0, 0, 0, 0);
            this.$input.val('2013-05-15').datepicker({
              dateMax: new Date(2013, 4, 20)
            });
            $cells = this.$input.data('datepicker').$calendar.find('td');
            return $cells.each(function(i, cell) {
              var $cell, date;

              $cell = $(cell);
              date = moment($cell.data('date'), 'YYYY-MM-DD').toDate();
              if (date.valueOf() > baseDate.valueOf()) {
                return expect($cell.hasClass('wdp-disabled')).to.be["true"];
              }
            });
          });
          describe('when a cell is clicked outside of max date', function() {
            return it('should not select it', function() {
              var origVal;

              this.$input.val('2013-05-15').datepicker({
                dateMax: new Date(2013, 4, 20)
              });
              origVal = this.$input.val();
              this.$input.find('.wdp-disabled').eq(0).click();
              return expect(this.$input.val()).to.equal(origVal);
            });
          });
          return describe('when setDate is called with a date that is > hax', function() {
            return it('should not set it', function() {
              var origVal;

              this.$input.val('2013-05-15').datepicker({
                dateMax: new Date(2013, 4, 20)
              });
              origVal = this.$input.val();
              this.$input.datepicker('setDate', new Date(3000, 0, 1));
              return expect(this.$input.val()).to.equal(origVal);
            });
          });
        });
      });
    });
  });

}).call(this);
