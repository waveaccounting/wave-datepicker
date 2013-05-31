(function() {
  describe('Wave Datepicker unit tests', function() {
    it('_cancelEvent', function() {
      var e;

      e = {
        stopPropagation: sinon.spy(),
        preventDefault: sinon.spy()
      };
      WDP.WaveDatepicker.prototype._cancelEvent.call(null, e);
      expect(e.stopPropagation.calledOnce).to.be["true"];
      return expect(e.preventDefault.calledOnce).to.be["true"];
    });
    describe('_initEvents', function() {
      beforeEach(function() {
        this.context = {
          $datepicker: {
            on: sinon.spy()
          },
          $el: {
            on: sinon.stub(),
            is: sinon.stub(),
            siblings: sinon.stub()
          },
          _cancelEvent: 'FUNCTION',
          prev: 'FUNCTION',
          next: 'FUNCTION',
          _onShortcutClick: 'FUNCTION',
          _selectDate: 'FUNCTION',
          render: 'FUNCTION',
          _updateFromInput: 'FUNCTION',
          _onInputKeydown: 'FUNCTION',
          show: 'FUNCTION',
          hide: 'FUNCTION',
          _dateWithinRange: function() {
            return true;
          }
        };
        this.context.$el.on.returns(this.context.$el);
        this.context.$el.is.returns(true);
        this.$icon = {
          length: 0,
          on: sinon.spy()
        };
        return this.context.$el.siblings.withArgs('.add-on').returns(this.$icon);
      });
      it('should bind cancel events to click on datepicker', function() {
        WDP.WaveDatepicker.prototype._initEvents.call(this.context);
        return expect(this.context.$datepicker.on.calledWith('click', this.context._cancelEvent)).to.be["true"];
      });
      it('should bind the prev/next callbacks to their corresponding elements', function() {
        WDP.WaveDatepicker.prototype._initEvents.call(this.context);
        expect(this.context.$datepicker.on.calledWith('click', '.js-wdp-prev', this.context.prev)).to.be["true"];
        return expect(this.context.$datepicker.on.calledWith('click', '.js-wdp-next', this.context.next)).to.be["true"];
      });
      it('should bind change event to render method', function() {
        WDP.WaveDatepicker.prototype._initEvents.call(this.context);
        return expect(this.context.$el.on.calledWith('change', this.context.render)).to.be["true"];
      });
      it('should bind input change event to update method', function() {
        WDP.WaveDatepicker.prototype._initEvents.call(this.context);
        return expect(this.context.$el.on.calledWith('change', this.context._updateFromInput)).to.be["true"];
      });
      it('should bind show to focus, click, and mousedown events', function() {
        WDP.WaveDatepicker.prototype._initEvents.call(this.context);
        return expect(this.context.$el.on.calledWith('focus click mousedown', this.context.show)).to.be["true"];
      });
      return it('should bind keydown event of <input> to the _onInputKeydown handler', function() {
        WDP.WaveDatepicker.prototype._initEvents.call(this.context);
        return expect(this.context.$el.on.calledWith('keydown', this.context._onInputKeydown)).to.be["true"];
      });
    });
    describe('setDate', function() {
      it('should update the date, state, and <input> of the widget', function() {
        var context, date;

        context = {
          _formatDate: sinon.stub(),
          $el: {
            val: sinon.spy(),
            trigger: sinon.spy()
          },
          _state: {},
          options: {
            hideOnSelect: false
          },
          _dateWithinRange: function() {
            return true;
          }
        };
        context._formatDate.returns('FORMATTED');
        date = new Date(2012, 7, 1, 0, 0, 0, 0);
        WDP.WaveDatepicker.prototype.setDate.call(context, date);
        expect(context.date).to.eql(date);
        expect(context._state.month).to.eql(7);
        expect(context._state.year).to.eql(2012);
        return expect(context.$el.trigger.calledWith('change', [
          date, {
            silent: true
          }
        ])).to.be["true"];
      });
      return describe('when hideOnSelect is true', function() {
        beforeEach(function() {
          this.context = {
            _formatDate: sinon.stub(),
            $el: {
              val: sinon.spy(),
              trigger: sinon.spy()
            },
            _state: {},
            options: {
              hideOnSelect: true
            },
            hide: sinon.spy(),
            _dateWithinRange: function() {
              return true;
            }
          };
          this.context._formatDate.returns('FORMATTED');
          return this.date = new Date(2012, 7, 1, 0, 0, 0, 0);
        });
        it('should call hide', function() {
          WDP.WaveDatepicker.prototype.setDate.call(this.context, this.date);
          return expect(this.context.hide.calledOnce).to.be["true"];
        });
        return describe('when {hide: false} is passed', function() {
          return it('should not call hide', function() {
            WDP.WaveDatepicker.prototype.setDate.call(this.context, this.date, {
              hide: false
            });
            return expect(this.context.hide.called).to.be["false"];
          });
        });
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
        expect(context._state.month).to.equal(8);
        return expect(context.render.calledOnce).to.be["true"];
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
        expect(context._state.month).to.equal(1);
        return expect(context._state.year).to.equal(2013);
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
        expect(context._state.month).to.equal(6);
        return expect(context.render.calledOnce).to.be["true"];
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
        expect(context._state.month).to.equal(12);
        return expect(context._state.year).to.equal(2011);
      });
    });
    describe('getDate', function() {
      return it('should return widget date', function() {
        var context, date;

        context = {
          date: 'DATE'
        };
        date = WDP.WaveDatepicker.prototype.getDate.call(context);
        return expect(date).to.equal(context.date);
      });
    });
    describe('show', function() {
      beforeEach(function() {
        this.context = {
          $datepicker: {
            addClass: sinon.spy()
          },
          $calendar: {
            show: sinon.spy()
          },
          $el: {
            outerHeight: sinon.stub(),
            is: sinon.stub()
          },
          _place: sinon.spy(),
          $window: {
            on: sinon.spy()
          },
          $document: {
            on: sinon.spy()
          },
          hide: 'FUNCTION',
          _isShown: false,
          hideInactive: sinon.spy()
        };
        this.context.$el.outerHeight.returns('HEIGHT');
        return this.context.$el.is.returns(false);
      });
      it('should place datepicker and show it', function() {
        WDP.WaveDatepicker.prototype.show.call(this.context);
        expect(this.context.$datepicker.addClass.calledWith('show')).to.be["true"];
        expect(this.context.height).to.equal('HEIGHT');
        expect(this.context._place.calledOnce).to.be["true"];
        expect(this.context.$window.on.calledWith('resize', this.context._place)).to.be["true"];
        return expect(this.context._isShown).to.be["true"];
      });
      it('should bind document click to hide method', function() {
        WDP.WaveDatepicker.prototype.show.call(this.context);
        return expect(this.context.$document.on.calledWith('click', this.context.hide)).to.be["true"];
      });
      return it('should hide inactive datepickers', function() {
        WDP.WaveDatepicker.prototype.show.call(this.context);
        return expect(this.context.hideInactive.calledOnce).to.be["true"];
      });
    });
    describe('hide', function() {
      beforeEach(function() {
        return this.context = {
          $datepicker: {
            removeClass: sinon.spy()
          },
          $calendarYear: {
            hide: sinon.spy()
          },
          $calendarMonth: {
            hide: sinon.spy()
          },
          _place: 'PLACE',
          $window: {
            off: sinon.spy()
          },
          $document: {
            off: sinon.spy()
          },
          _isShown: true,
          hide: 'FUNCTION'
        };
      });
      it('should hide datepicker and unbind place callback from window resize', function() {
        WDP.WaveDatepicker.prototype.hide.call(this.context);
        expect(this.context.$datepicker.removeClass.calledWith('show')).to.be["true"];
        expect(this.context.$window.off.calledWith('resize', this.context._place)).to.be["true"];
        return expect(this.context._isShown).to.be["false"];
      });
      return it('should unbind the hide method from document click event', function() {
        WDP.WaveDatepicker.prototype.hide.call(this.context);
        return expect(this.context.$document.off.calledWith('click', this.context.hide)).to.be["true"];
      });
    });
    return describe('_onInputKeydown', function() {
      beforeEach(function() {
        this.context = {
          shortcuts: {
            selectNext: sinon.spy(),
            selectPrev: sinon.spy(),
            resetClass: sinon.spy()
          },
          _cancelEvent: sinon.spy(),
          date: new Date(2012, 7, 1, 0, 0, 0, 0),
          setDate: sinon.spy(),
          show: sinon.spy(),
          hide: sinon.spy(),
          _isShown: true
        };
        return this.e = {};
      });
      describe('When DOWN or J pressed', function() {
        it('should cancel event', function() {
          this.e.keyCode = WDP.Keys.DOWN;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          this.e.keyCode = WDP.Keys.J;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          return expect(this.context._cancelEvent.calledTwice).to.be["true"];
        });
        it('should increment date by seven days', function() {
          var date, diff;

          this.e.keyCode = WDP.Keys.DOWN;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          date = this.context.setDate.args[0][0];
          diff = date.getTime() - this.context.date.getTime();
          expect(diff).to.eql(7 * 24 * 60 * 60 * 1000);
          this.e.keyCode = WDP.Keys.J;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          date = this.context.setDate.args[0][0];
          diff = date.getTime() - this.context.date.getTime();
          return expect(diff).to.eql(7 * 24 * 60 * 60 * 1000);
        });
        it('should show the datepicker if not already shown', function() {
          this.e.keyCode = WDP.Keys.DOWN;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          expect(this.context.show.calledOnce).to.be["true"];
          this.e.keyCode = WDP.Keys.J;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          return expect(this.context.show.calledTwice).to.be["true"];
        });
        return describe('When Shift is pressed', function() {
          return it('should call selectNext on Shortcuts', function() {
            this.e.shiftKey = true;
            this.e.keyCode = WDP.Keys.DOWN;
            WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
            this.e.keyCode = WDP.Keys.J;
            WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
            return expect(this.context.shortcuts.selectNext.calledTwice).to.be["true"];
          });
        });
      });
      describe('When UP or K pressed', function() {
        it('should cancel event', function() {
          this.e.keyCode = WDP.Keys.UP;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          this.e.keyCode = WDP.Keys.K;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          return expect(this.context._cancelEvent.calledTwice).to.be["true"];
        });
        it('should decrement date by seven days', function() {
          var date, diff;

          this.e.keyCode = WDP.Keys.UP;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          date = this.context.setDate.args[0][0];
          diff = date.getTime() - this.context.date.getTime();
          expect(diff).to.eql(-7 * 24 * 60 * 60 * 1000);
          this.e.keyCode = WDP.Keys.K;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          date = this.context.setDate.args[0][0];
          diff = date.getTime() - this.context.date.getTime();
          return expect(diff).to.eql(-7 * 24 * 60 * 60 * 1000);
        });
        return describe('When Shift is pressed', function() {
          return it('should call selectPrev on Shortcuts', function() {
            this.e.shiftKey = true;
            this.e.keyCode = WDP.Keys.UP;
            WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
            this.e.keyCode = WDP.Keys.K;
            WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
            return expect(this.context.shortcuts.selectPrev.calledTwice).to.be["true"];
          });
        });
      });
      describe('When RIGHT or L pressed', function() {
        it('should cancel event', function() {
          this.e.keyCode = WDP.Keys.RIGHT;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          this.e.keyCode = WDP.Keys.L;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          return expect(this.context._cancelEvent.calledTwice).to.be["true"];
        });
        return it('should decrement date by one day', function() {
          var date, diff;

          this.e.keyCode = WDP.Keys.RIGHT;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          date = this.context.setDate.args[0][0];
          diff = date.getTime() - this.context.date.getTime();
          expect(diff).to.eql(1 * 24 * 60 * 60 * 1000);
          this.e.keyCode = WDP.Keys.L;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          date = this.context.setDate.args[0][0];
          diff = date.getTime() - this.context.date.getTime();
          return expect(diff).to.eql(1 * 24 * 60 * 60 * 1000);
        });
      });
      describe('When LEFT or H pressed', function() {
        it('should cancel event', function() {
          this.e.keyCode = WDP.Keys.LEFT;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          this.e.keyCode = WDP.Keys.H;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          return expect(this.context._cancelEvent.calledTwice).to.be["true"];
        });
        return it('should decrement date by one day', function() {
          var date, diff;

          this.e.keyCode = WDP.Keys.LEFT;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          date = this.context.setDate.args[0][0];
          diff = date.getTime() - this.context.date.getTime();
          expect(diff).to.eql(-1 * 24 * 60 * 60 * 1000);
          this.e.keyCode = WDP.Keys.H;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          date = this.context.setDate.args[0][0];
          diff = date.getTime() - this.context.date.getTime();
          return expect(diff).to.eql(-1 * 24 * 60 * 60 * 1000);
        });
      });
      describe('When Esc if pressed', function() {
        return it('should hide the datepicker', function() {
          this.e.keyCode = WDP.Keys.ESC;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          return expect(this.context.hide.calledOnce).to.be["true"];
        });
      });
      return describe('When Return is pressed', function() {
        return it('should show the datepicker', function() {
          this.context._isShown = false;
          this.e.keyCode = WDP.Keys.RETURN;
          WDP.WaveDatepicker.prototype._onInputKeydown.call(this.context, this.e);
          return expect(this.context.show.calledOnce).to.be["true"];
        });
      });
    });
  });

  describe('Shortcuts', function() {
    beforeEach(function() {
      return this.context = {
        currSelectedIndex: -1,
        numShortcuts: 3,
        _updateSelected: sinon.spy()
      };
    });
    describe('selectNext', function() {
      it('should increment the selected index', function() {
        WDP.Shortcuts.prototype.selectNext.call(this.context);
        expect(this.context.currSelectedIndex).to.eql(0);
        return expect(this.context._updateSelected.calledOnce).to.be["true"];
      });
      return it('should wrap to first shortcut if index is out of bounds', function() {
        this.context.currSelectedIndex = 2;
        WDP.Shortcuts.prototype.selectNext.call(this.context);
        return expect(this.context.currSelectedIndex).to.eql(0);
      });
    });
    describe('selectPrev', function() {
      it('should decrement the selected index', function() {
        WDP.Shortcuts.prototype.selectPrev.call(this.context);
        expect(this.context.currSelectedIndex).to.eql(2);
        return expect(this.context._updateSelected.calledOnce).to.be["true"];
      });
      return it('should wrap to last shortcut if index is negative', function() {
        this.context.currSelectedIndex = 0;
        WDP.Shortcuts.prototype.selectPrev.call(this.context);
        return expect(this.context.currSelectedIndex).to.eql(2);
      });
    });
    return describe('_onShortcutClick', function() {
      return it('should call select method on the target element', function() {
        var e, _$;

        this.context.select = sinon.spy();
        _$ = sinon.stub(WDP, '$');
        _$.returns('OBJECT');
        e = {
          target: 'TARGET'
        };
        WDP.Shortcuts.prototype._onShortcutClick.call(this.context, e);
        expect(_$.calledWith(e.target)).to.be["true"];
        expect(this.context.select.calledWith('OBJECT')).to.be["true"];
        return _$.restore();
      });
    });
  });

}).call(this);
