describe 'Wave Datepicker unit tests', ->
  it '_cancelEvent', ->
    e =
      stopPropagation: sinon.spy()
      preventDefault: sinon.spy()

    WDP.WaveDatepicker.prototype._cancelEvent.call null, e

    expect(e.stopPropagation).toHaveBeenCalledOnce()
    expect(e.preventDefault).toHaveBeenCalledOnce()

  describe '_initEvents', ->
    beforeEach ->
      @context =
        $datepicker:
          on: sinon.spy()
        $el:
          on: sinon.stub()  # Stub because we need to return $el
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

    it 'should bind cancel events to click on datepicker', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$datepicker.on).toHaveBeenCalledWith('click', @context._cancelEvent)

    it 'should bind the prev/next callbacks to their corresponding elements', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$datepicker.on).toHaveBeenCalledWith('click', '.js-wdp-prev', @context.prev)
      expect(@context.$datepicker.on).toHaveBeenCalledWith('click', '.js-wdp-next', @context.next)

    it 'should bind datechange event to render method', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$el.on).toHaveBeenCalledWith('datechange', @context.render)

    it 'should bind input change event to update method', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$el.on).toHaveBeenCalledWith('change', @context._updateFromInput)

    it 'should bind show to focus event', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$el.on).toHaveBeenCalledWith('focus', @context.show)

    it 'should bind keydown event of <input> to the _onInputKeydown handler', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$el.on).toHaveBeenCalledWith('keydown', @context._onInputKeydown)


  describe 'setDate', ->
    it 'should update the date, state, and <input> of the widget', ->
      context =
        _formatDate: sinon.stub()
        $el:
          val: sinon.spy()
          trigger: sinon.spy()
        _state: {}
      context._formatDate.returns 'FORMATTED'

      date =
        getMonth: -> 'MONTH'
        getFullYear: -> 'YEAR'

      WDP.WaveDatepicker.prototype.setDate.call context, date

      expect(context.date).toEqual(date)
      expect(context._state.month).toEqual('MONTH')
      expect(context._state.year).toEqual('YEAR')
      expect(context.$el.trigger).toHaveBeenCalledWith('datechange', date)

  describe 'next', ->
    it 'should increment month then call render method', ->
      context =
        _state:
          month: 7
        render: sinon.spy()

      WDP.WaveDatepicker.prototype.next.call context

      expect(context._state.month).toBe(8)
      expect(context.render).toHaveBeenCalledOnce()

    it 'should go to next year if month is 12', ->
      context =
        _state:
          month: 12
          year: 2012
        render: sinon.spy()

      WDP.WaveDatepicker.prototype.next.call context

      expect(context._state.month).toBe(1)
      expect(context._state.year).toBe(2013)

  describe 'prev', ->
    it 'should decrement month then call render method', ->
      context =
        _state:
          month: 7
        render: sinon.spy()

      WDP.WaveDatepicker.prototype.prev.call context

      expect(context._state.month).toBe(6)
      expect(context.render).toHaveBeenCalledOnce()

    it 'should go to prev year if month is 1', ->
      context =
        _state:
          month: 1
          year: 2012
        render: sinon.spy()

      WDP.WaveDatepicker.prototype.prev.call context

      expect(context._state.month).toBe(12)
      expect(context._state.year).toBe(2011)

  describe 'getDate', ->
    it 'should return widget date', ->
      context =
        date: 'DATE'
      date = WDP.WaveDatepicker.prototype.getDate.call context
      expect(date).toBe(context.date)


  describe 'show', ->
    beforeEach ->
      @context =
        $datepicker:
          addClass: sinon.spy()
        $el:
          outerHeight: sinon.stub()
        _place: sinon.spy()
        $window:
          on: sinon.spy()
        $document:
          on: sinon.spy()
        hide: 'FUNCTION'
        _isShown: false
      @context.$el.outerHeight.returns 'HEIGHT'

    it 'should place datepicker and show it', ->
      WDP.WaveDatepicker.prototype.show.call @context
      expect(@context.$datepicker.addClass).toHaveBeenCalledWith('show')
      expect(@context.height).toBe('HEIGHT')
      expect(@context._place).toHaveBeenCalledOnce()
      expect(@context.$window.on).toHaveBeenCalledWith('resize', @context._place)
      expect(@context._isShown).toBeTruthy()

    it 'should bind document click to hide method', ->
      WDP.WaveDatepicker.prototype.show.call @context
      expect(@context.$document.on).toHaveBeenCalledWith('click', @context.hide)


  describe 'hide', ->
    beforeEach ->
      @context =
        $datepicker:
          removeClass: sinon.spy()
        _place: 'PLACE'
        $window:
          off: sinon.spy()
        $document:
          off: sinon.spy()
        _isShown: true
        hide: 'FUNCTION'

    it 'should hide datepicker and unbind place callback from window resize', ->
      WDP.WaveDatepicker.prototype.hide.call @context
      expect(@context.$datepicker.removeClass).toHaveBeenCalledWith('show')
      expect(@context.$window.off).toHaveBeenCalledWith('resize', @context._place)
      expect(@context._isShown).not.toBeTruthy()

    it 'should unbind the hide method from document click event', ->
      WDP.WaveDatepicker.prototype.hide.call @context
      expect(@context.$document.off).toHaveBeenCalledWith('click', @context.hide)


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

      @e = {}

    describe 'When DOWN or J pressed', ->
      it 'should cancel event', ->
        @e.keyCode = WDP.Keys.DOWN
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        @e.keyCode = WDP.Keys.J
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context._cancelEvent).toHaveBeenCalledTwice()

      it 'should increment date by seven days', ->
        @e.keyCode = WDP.Keys.DOWN
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).toEqual(7 * 24 * 60 * 60 * 1000)

        @e.keyCode = WDP.Keys.J
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).toEqual(7 * 24 * 60 * 60 * 1000)

      it 'should show the datepicker if not already shown', ->
        @e.keyCode = WDP.Keys.DOWN
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context.show).toHaveBeenCalledOnce()

        @e.keyCode = WDP.Keys.J
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context.show).toHaveBeenCalledTwice()


      describe 'When Shift is pressed', ->
        it 'should call selectNext on Shortcuts', ->
          @e.shiftKey = true
          @e.keyCode = WDP.Keys.DOWN
          WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
          @e.keyCode = WDP.Keys.J
          WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
          expect(@context.shortcuts.selectNext).toHaveBeenCalledTwice()


    describe 'When UP or K pressed', ->
      it 'should cancel event', ->
        @e.keyCode = WDP.Keys.UP
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        @e.keyCode = WDP.Keys.K
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context._cancelEvent).toHaveBeenCalledTwice()

      it 'should decrement date by seven days', ->
        @e.keyCode = WDP.Keys.UP
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).toEqual(-7 * 24 * 60 * 60 * 1000)

        @e.keyCode = WDP.Keys.K
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).toEqual(-7 * 24 * 60 * 60 * 1000)


      describe 'When Shift is pressed', ->
        it 'should call selectPrev on Shortcuts', ->
          @e.shiftKey = true
          @e.keyCode = WDP.Keys.UP
          WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
          @e.keyCode = WDP.Keys.K
          WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
          expect(@context.shortcuts.selectPrev).toHaveBeenCalledTwice()


    describe 'When RIGHT or L pressed', ->
      it 'should cancel event', ->
        @e.keyCode = WDP.Keys.RIGHT
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        @e.keyCode = WDP.Keys.L
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context._cancelEvent).toHaveBeenCalledTwice()

      it 'should decrement date by one day', ->
        @e.keyCode = WDP.Keys.RIGHT
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).toEqual(1 * 24 * 60 * 60 * 1000)

        @e.keyCode = WDP.Keys.L
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).toEqual(1 * 24 * 60 * 60 * 1000)


    describe 'When LEFT or H pressed', ->
      it 'should cancel event', ->
        @e.keyCode = WDP.Keys.LEFT
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        @e.keyCode = WDP.Keys.H
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context._cancelEvent).toHaveBeenCalledTwice()

      it 'should decrement date by one day', ->
        @e.keyCode = WDP.Keys.LEFT
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).toEqual(-1 * 24 * 60 * 60 * 1000)

        @e.keyCode = WDP.Keys.H
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        date = @context.setDate.args[0][0]
        diff = date.getTime() - @context.date.getTime()
        expect(diff).toEqual(-1 * 24 * 60 * 60 * 1000)


    describe 'When Esc if pressed', ->
      it 'should hide the datepicker', ->
        @e.keyCode = WDP.Keys.ESC
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context.hide).toHaveBeenCalledOnce()


    describe 'When Return if pressed', ->
      it 'should show the datepicker', ->
        @e.keyCode = WDP.Keys.RETURN
        WDP.WaveDatepicker.prototype._onInputKeydown.call @context, @e
        expect(@context.show).toHaveBeenCalledOnce()


describe 'Shortcuts', ->
  beforeEach ->
    @context =
      currSelectedIndex: -1
      numShortcuts: 3
      _updateSelected: sinon.spy()


  describe 'selectNext', ->
    it 'should increment the selected index', ->
      WDP.Shortcuts.prototype.selectNext.call @context

      expect(@context.currSelectedIndex).toEqual(0)
      expect(@context._updateSelected).toHaveBeenCalledOnce()

    it 'should wrap to first shortcut if index is out of bounds', ->
      @context.currSelectedIndex = 2
      WDP.Shortcuts.prototype.selectNext.call @context
      expect(@context.currSelectedIndex).toEqual(0)


  describe 'selectPrev', ->
    it 'should decrement the selected index', ->
      WDP.Shortcuts.prototype.selectPrev.call @context

      expect(@context.currSelectedIndex).toEqual(2)
      expect(@context._updateSelected).toHaveBeenCalledOnce()

    it 'should wrap to last shortcut if index is negative', ->
      @context.currSelectedIndex = 0
      WDP.Shortcuts.prototype.selectPrev.call @context
      expect(@context.currSelectedIndex).toEqual(2)


  describe '_onShortcutClick', ->
    it 'should call select method on the target element', ->
      @context.select = sinon.spy()
      _$ = sinon.stub WDP, '$'
      _$.returns 'OBJECT'
      e = {target: 'TARGET'}
      WDP.Shortcuts.prototype._onShortcutClick.call @context, e
      expect(_$).toHaveBeenCalledWith(e.target)
      expect(@context.select).toHaveBeenCalledWith('OBJECT')
      _$.restore()
