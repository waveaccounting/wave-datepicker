describe 'Wave Datepicker unit tests', ->
  it '_cancelEvent', ->
    e =
      stopPropagation: sinon.spy()
      preventDefault: sinon.spy()

    WDP.WaveDatepicker.prototype._cancelEvent.call null, e

    expect(e.stopPropagation.calledOnce).to.be.true
    expect(e.preventDefault.calledOnce).to.be.true

  describe '_initEvents', ->
    beforeEach ->
      @context =
        $datepicker:
          on: sinon.spy()
        $el:
          on: sinon.stub()  # Stub because we need to return $el
          is: sinon.stub()
          siblings: sinon.stub()  # For finding add-on icon
        _cancelEvent: 'FUNCTION'
        prev: 'FUNCTION'
        next: 'FUNCTION'
        _onShortcutClick: 'FUNCTION'
        _selectDate: 'FUNCTION'
        render: 'FUNCTION'
        _updateFromInput: 'FUNCTION'
        _onInputKeydown: 'FUNCTION'
        show: 'FUNCTION'
        hide: 'FUNCTION'
      @context.$el.on.returns @context.$el
      @context.$el.is.returns true
      @$icon =
        length: 0
        on: sinon.spy()
      @context.$el.siblings.withArgs('.add-on').returns @$icon

    it 'should bind cancel events to click on datepicker', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$datepicker.on.calledWith('click', @context._cancelEvent)).to.be.true

    it 'should bind the prev/next callbacks to their corresponding elements', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$datepicker.on.calledWith('click', '.js-wdp-prev', @context.prev)).to.be.true
      expect(@context.$datepicker.on.calledWith('click', '.js-wdp-next', @context.next)).to.be.true

    it 'should bind change event to render method', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$el.on.calledWith('change', @context.render)).to.be.true

    it 'should bind input change event to update method', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$el.on.calledWith('change', @context._updateFromInput)).to.be.true

    it 'should bind show to focus, click, and mousedown events', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$el.on.calledWith('focus click mousedown', @context.show)).to.be.true

    it 'should bind keydown event of <input> to the _onInputKeydown handler', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$el.on.calledWith('keydown', @context._onInputKeydown)).to.be.true


  describe 'setDate', ->
    it 'should update the date, state, and <input> of the widget', ->
      context =
        _formatDate: sinon.stub()
        $el:
          val: sinon.spy()
          trigger: sinon.spy()
        _state: {}
        options:
          hideOnSelect: false
      context._formatDate.returns 'FORMATTED'

      date = new Date(2012, 7, 1, 0, 0, 0, 0)

      WDP.WaveDatepicker.prototype.setDate.call context, date

      expect(context.date).to.eql(date)
      expect(context._state.month).to.eql(7)
      expect(context._state.year).to.eql(2012)
      expect(context.$el.trigger.calledWith('change', [date, {silent: true}])).to.be.true

    describe 'when hideOnSelect is true', ->
      beforeEach ->
        @context =
          _formatDate: sinon.stub()
          $el:
            val: sinon.spy()
            trigger: sinon.spy()
          _state: {}
          options:
            hideOnSelect: true
          hide: sinon.spy()

        @context._formatDate.returns 'FORMATTED'

        @date = new Date(2012, 7, 1, 0, 0, 0, 0)

      it 'should call hide', ->
        WDP.WaveDatepicker.prototype.setDate.call @context, @date
        expect(@context.hide.calledOnce).to.be.true

      describe 'when {hide: false} is passed', ->
        it 'should not call hide', ->
          WDP.WaveDatepicker.prototype.setDate.call @context, @date, {hide: false}
          expect(@context.hide.called).to.be.false

  describe 'next', ->
    it 'should increment month then call render method', ->
      context =
        _state:
          month: 7
        render: sinon.spy()

      WDP.WaveDatepicker.prototype.next.call context

      expect(context._state.month).to.equal(8)
      expect(context.render.calledOnce).to.be.true

    it 'should go to next year if month is 12', ->
      context =
        _state:
          month: 12
          year: 2012
        render: sinon.spy()

      WDP.WaveDatepicker.prototype.next.call context

      expect(context._state.month).to.equal(1)
      expect(context._state.year).to.equal(2013)

  describe 'prev', ->
    it 'should decrement month then call render method', ->
      context =
        _state:
          month: 7
        render: sinon.spy()

      WDP.WaveDatepicker.prototype.prev.call context

      expect(context._state.month).to.equal(6)
      expect(context.render.calledOnce).to.be.true

    it 'should go to prev year if month is 1', ->
      context =
        _state:
          month: 1
          year: 2012
        render: sinon.spy()

      WDP.WaveDatepicker.prototype.prev.call context

      expect(context._state.month).to.equal(12)
      expect(context._state.year).to.equal(2011)

  describe 'getDate', ->
    it 'should return widget date', ->
      context =
        date: 'DATE'
      date = WDP.WaveDatepicker.prototype.getDate.call context
      expect(date).to.equal(context.date)


  describe 'show', ->
    beforeEach ->
      @context =
        $datepicker:
          addClass: sinon.spy()
        $calendar:
          show: sinon.spy()
        $el:
          outerHeight: sinon.stub()
          is: sinon.stub()
        _place: sinon.spy()
        $window:
          on: sinon.spy()
        $document:
          on: sinon.spy()
        hide: 'FUNCTION'
        _isShown: false
        hideInactive: sinon.spy()
      @context.$el.outerHeight.returns 'HEIGHT'
      # false means it's visible
      @context.$el.is.returns false

    it 'should place datepicker and show it', ->
      WDP.WaveDatepicker.prototype.show.call @context
      expect(@context.$datepicker.addClass.calledWith('show')).to.be.true
      expect(@context.height).to.equal('HEIGHT')
      expect(@context._place.calledOnce).to.be.true
      expect(@context.$window.on.calledWith('resize', @context._place)).to.be.true
      expect(@context._isShown).to.be.true

    it 'should bind document click to hide method', ->
      WDP.WaveDatepicker.prototype.show.call @context
      expect(@context.$document.on.calledWith('click', @context.hide)).to.be.true

    it 'should hide inactive datepickers', ->
      WDP.WaveDatepicker.prototype.show.call @context
      expect(@context.hideInactive.calledOnce).to.be.true


  describe 'hide', ->
    beforeEach ->
      @context =
        $datepicker:
          removeClass: sinon.spy()
        $calendarYear:
          hide: sinon.spy()
        $calendarMonth:
          hide: sinon.spy()
        _place: 'PLACE'
        $window:
          off: sinon.spy()
        $document:
          off: sinon.spy()
        _isShown: true
        hide: 'FUNCTION'

    it 'should hide datepicker and unbind place callback from window resize', ->
      WDP.WaveDatepicker.prototype.hide.call @context
      expect(@context.$datepicker.removeClass.calledWith('show')).to.be.true
      expect(@context.$window.off.calledWith('resize', @context._place)).to.be.true
      expect(@context._isShown).to.be.false

    it 'should unbind the hide method from document click event', ->
      WDP.WaveDatepicker.prototype.hide.call @context
      expect(@context.$document.off.calledWith('click', @context.hide)).to.be.true


  describe '_onInputKeydown', ->
    beforeEach ->
      @context =
        shortcuts:
          selectNext: sinon.spy()
          selectPrev: sinon.spy()
          resetClass: sinon.spy()
        _cancelEvent: sinon.spy()
        date: new  Date(2012, 7, 1, 0, 0, 0, 0)
        setDate: sinon.spy()
        show: sinon.spy()
        hide: sinon.spy()
        _isShown: true

      @e = {}

    describe 'When DOWN or J pressed', ->
      it 'should cancel event', ->
        @e.keyCode = WDP.Keys.DOWN
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        @e.keyCode = WDP.Keys.J
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context._cancelEvent.calledTwice).to.be.true

      it 'should increment date by seven days', ->
        @e.keyCode = WDP.Keys.DOWN
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).to.eql(7 * 24 * 60 * 60 * 1000)

        @e.keyCode = WDP.Keys.J
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).to.eql(7 * 24 * 60 * 60 * 1000)

      it 'should show the datepicker if not already shown', ->
        @e.keyCode = WDP.Keys.DOWN
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context.show.calledOnce).to.be.true

        @e.keyCode = WDP.Keys.J
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context.show.calledTwice).to.be.true


      describe 'When Shift is pressed', ->
        it 'should call selectNext on Shortcuts', ->
          @e.shiftKey = true
          @e.keyCode = WDP.Keys.DOWN
          WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
          @e.keyCode = WDP.Keys.J
          WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
          expect(@context.shortcuts.selectNext.calledTwice).to.be.true


    describe 'When UP or K pressed', ->
      it 'should cancel event', ->
        @e.keyCode = WDP.Keys.UP
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        @e.keyCode = WDP.Keys.K
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context._cancelEvent.calledTwice).to.be.true

      it 'should decrement date by seven days', ->
        @e.keyCode = WDP.Keys.UP
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).to.eql(-7 * 24 * 60 * 60 * 1000)

        @e.keyCode = WDP.Keys.K
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).to.eql(-7 * 24 * 60 * 60 * 1000)


      describe 'When Shift is pressed', ->
        it 'should call selectPrev on Shortcuts', ->
          @e.shiftKey = true
          @e.keyCode = WDP.Keys.UP
          WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
          @e.keyCode = WDP.Keys.K
          WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
          expect(@context.shortcuts.selectPrev.calledTwice).to.be.true


    describe 'When RIGHT or L pressed', ->
      it 'should cancel event', ->
        @e.keyCode = WDP.Keys.RIGHT
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        @e.keyCode = WDP.Keys.L
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context._cancelEvent.calledTwice).to.be.true

      it 'should decrement date by one day', ->
        @e.keyCode = WDP.Keys.RIGHT
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).to.eql(1 * 24 * 60 * 60 * 1000)

        @e.keyCode = WDP.Keys.L
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).to.eql(1 * 24 * 60 * 60 * 1000)


    describe 'When LEFT or H pressed', ->
      it 'should cancel event', ->
        @e.keyCode = WDP.Keys.LEFT
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        @e.keyCode = WDP.Keys.H
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context._cancelEvent.calledTwice).to.be.true

      it 'should decrement date by one day', ->
        @e.keyCode = WDP.Keys.LEFT
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).to.eql(-1 * 24 * 60 * 60 * 1000)

        @e.keyCode = WDP.Keys.H
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).to.eql(-1 * 24 * 60 * 60 * 1000)


    describe 'When Esc if pressed', ->
      it 'should hide the datepicker', ->
        @e.keyCode = WDP.Keys.ESC
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context.hide.calledOnce).to.be.true


    describe 'When Return is pressed', ->
      it 'should show the datepicker', ->
        @context._isShown = false
        @e.keyCode = WDP.Keys.RETURN
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context.show.calledOnce).to.be.true


describe 'Shortcuts', ->
  beforeEach ->
    @context =
      currSelectedIndex: -1
      numShortcuts: 3
      _updateSelected: sinon.spy()


  describe 'selectNext', ->
    it 'should increment the selected index', ->
      WDP.Shortcuts.prototype.selectNext.call @context

      expect(@context.currSelectedIndex).to.eql(0)
      expect(@context._updateSelected.calledOnce).to.be.true

    it 'should wrap to first shortcut if index is out of bounds', ->
      @context.currSelectedIndex = 2
      WDP.Shortcuts.prototype.selectNext.call @context
      expect(@context.currSelectedIndex).to.eql(0)


  describe 'selectPrev', ->
    it 'should decrement the selected index', ->
      WDP.Shortcuts.prototype.selectPrev.call @context

      expect(@context.currSelectedIndex).to.eql(2)
      expect(@context._updateSelected.calledOnce).to.be.true

    it 'should wrap to last shortcut if index is negative', ->
      @context.currSelectedIndex = 0
      WDP.Shortcuts.prototype.selectPrev.call @context
      expect(@context.currSelectedIndex).to.eql(2)


  describe '_onShortcutClick', ->
    it 'should call select method on the target element', ->
      @context.select = sinon.spy()
      _$ = sinon.stub WDP, '$'
      _$.returns 'OBJECT'
      e = {target: 'TARGET'}
      WDP.Shortcuts.prototype._onShortcutClick.call @context, e
      expect(_$.calledWith(e.target)).to.be.true
      expect(@context.select.calledWith('OBJECT')).to.be.true
      _$.restore()
