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
          on: sinon.stub()
        _cancelEvent: sinon.spy()
        prev: sinon.spy()
        next: sinon.spy()
        _prevSelect: sinon.spy()
        _nextSelect: sinon.spy()
        _onShortcutClick: sinon.spy()
        _selectDate: sinon.spy()
        render: sinon.spy()
        _updateFromInput: sinon.spy()
        show: sinon.spy()
        hide: sinon.spy()
      @context.$el.on.returns @context.$el

    it 'should bind cancel events to mousedown on datepicker', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$datepicker.on).toHaveBeenCalledWith('mousedown', @context._cancelEvent)

    it 'should bind the prev/next callbacks to their corresponding elements', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$datepicker.on).toHaveBeenCalledWith('click', '.js-wdp-prev', @context.prev)
      expect(@context.$datepicker.on).toHaveBeenCalledWith('click', '.js-wdp-next', @context.next)
      expect(@context.$datepicker.on).toHaveBeenCalledWith('click', '.js-wdp-prev-select', @context._prevSelect)
      expect(@context.$datepicker.on).toHaveBeenCalledWith('click', '.js-wdp-next-select', @context._nextSelect)

    it 'should bind datechange event to render method', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$el.on).toHaveBeenCalledWith('datechange', @context.render)

    it 'should bind input change event to update method', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$el.on).toHaveBeenCalledWith('change', @context._updateFromInput)

    it 'should bind show/hide to focus/blur event', ->
      WDP.WaveDatepicker.prototype._initEvents.call @context
      expect(@context.$el.on).toHaveBeenCalledWith('focus', @context.show)
      expect(@context.$el.on).toHaveBeenCalledWith('blur', @context.hide)

  describe 'setDate', ->
    it 'should update the date, state, and <inpput> of the widget', ->
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
    it 'should place datepicker and show it', ->
      context =
        $datepicker:
          addClass: sinon.spy()
        $el:
          outerHeight: sinon.stub()
        _place: sinon.spy()
        $window:
          on: sinon.spy()
      context.$el.outerHeight.returns 'HEIGHT'

      date = WDP.WaveDatepicker.prototype.show.call context

      expect(context.$datepicker.addClass).toHaveBeenCalledWith('show')
      expect(context.height).toBe('HEIGHT')
      expect(context._place).toHaveBeenCalledOnce()
      expect(context.$window.on).toHaveBeenCalledWith('resize', context._place)


  describe 'hide', ->
    it 'should hide datepicker and unbind place callback from window resize', ->
      context =
        $datepicker:
          removeClass: sinon.spy()
        _place: 'PLACE'
        $window:
          off: sinon.spy()

      date = WDP.WaveDatepicker.prototype.hide.call context

      expect(context.$datepicker.removeClass).toHaveBeenCalledWith('show')
      expect(context.$window.off).toHaveBeenCalledWith('resize', context._place)