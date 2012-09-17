describe 'Wave Datepicker', ->
  beforeEach ->
    # The input box to test on.
    @$input = $('<input id="Date">').appendTo(document.body)

    @stubWaveDatepicker = ->
      @_WaveDatepicker =
        render: sinon.stub()
        destroy: sinon.stub()
      @_WaveDatepicker.render.returns @_WaveDatepicker
      @_WaveDatepickerStub = sinon.stub WDP, 'WaveDatepicker'
      @_WaveDatepickerStub.returns @_WaveDatepicker

    @restoreWaveDatepicker = ->
      @_WaveDatepickerStub.restore()


  afterEach ->
    @$input.datepicker('destroy')
    @$input.remove()


  describe '$.fn.datepicker', ->
    it 'should be defined on jQuery object', ->
      expect(@$input.datepicker).toEqual(jasmine.any(Function))

    it 'should instantiate the WaveDatepicker call', ->
      @stubWaveDatepicker()

      @$input.datepicker()

      expect(@_WaveDatepickerStub).toHaveBeenCalledOnce()

      @restoreWaveDatepicker()

    it 'should not instantiate datepicker twice on same element', ->
      @stubWaveDatepicker()

      # Called twice
      @$input.datepicker()
      @$input.datepicker()

      # But only instantiated twice
      expect(@_WaveDatepickerStub).toHaveBeenCalledOnce()

      @restoreWaveDatepicker()

    it 'should set the datepicker widget as data on the <input>', ->
      @stubWaveDatepicker()
      @$input.datepicker()
      expect(@$input.data('datepicker')).toEqual(@_WaveDatepicker)
      @restoreWaveDatepicker()

    it 'should use the value attribute to set default date', ->
      @$input.val('2012-08-01').datepicker()
      date = @$input.data('datepicker').date
      expect(date).toBeDefined()
      expect(date.getFullYear()).toEqual(2012)
      expect(date.getMonth()).toEqual(7)
      expect(date.getDate()).toEqual(1)

    it 'should set today as the default is value not set on <input>', ->
      @$input.datepicker()
      date = @$input.data('datepicker').date
      today = new Date()
      expect(date).toBeDefined()
      expect(date.getFullYear()).toEqual(today.getFullYear())
      expect(date.getMonth()).toEqual(today.getMonth())
      expect(date.getDate()).toEqual(today.getDate())


    describe 'Shortcuts', ->
      it 'should by default provide the Today shortcut', ->
        @$input.datepicker()
        widget = @$input.data('datepicker')
        expect(widget.$datepicker).toContain('.wdp-shortcut')
        today = widget.$datepicker.find('.wdp-shortcut')
        expect($.trim(today.text())).toEqual('Today')

      describe 'When a shortcut is clicked', ->
        it 'should add the corresponding offset to the widget date', ->
          @$input.datepicker(
            'shortcuts': {
              'Foo': {days: 5, months: 1, years: -1}
            })
          today = new Date()
          # Date and month can overflow, which JavaScript will handle for us.
          expected = new Date(today.getFullYear() - 1, today.getMonth() + 1, today.getDate() + 5)
          widget = @$input.data('datepicker')

          widget.$datepicker.find('.wdp-shortcut').click()

          expect(widget.date.getFullYear()).toEqual(expected.getFullYear())
          expect(widget.date.getMonth()).toEqual(expected.getMonth())
          expect(widget.date.getDate()).toEqual(expected.getDate())


    describe 'On input change', ->
      it 'should update the date of the the widget', ->
        @$input.val('2012-08-01').datepicker()
        date = new Date 2012, 7, 1  # 7 is Aug
        widget = @$input.data('datepicker')
        expect(widget.date.getFullYear()).toEqual(date.getFullYear())
        expect(widget.date.getMonth()).toEqual(date.getMonth())
        expect(widget.date.getDate()).toEqual(date.getDate())

        @$input.val('2011-04-13').trigger('change')
        date = new Date 2011, 3, 13  # 7 is Aug
        expect(widget.date.getFullYear()).toEqual(date.getFullYear())
        expect(widget.date.getMonth()).toEqual(date.getMonth())
        expect(widget.date.getDate()).toEqual(date.getDate())


    describe 'Rendered calendar', ->
      it 'should draw the calendar with current month and fill start/end with prev/next month', ->
        # Aug 2012
        @$input.val('2012-08-01').datepicker()
        $cells = @$input.data('datepicker').$calendar.find('td')
        expected = [29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
          20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8]
        array = []
        $cells.each -> array.push parseInt($.trim($(this).text()), 10)
        expect(array).toEqual(expected)

        # Nov 2014
        @$input.val('2014-11-13').trigger('change')
        $cells = @$input.data('datepicker').$calendar.find('td')
        expected = [26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
          20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 1, 2, 3, 4, 5, 6]
        array = []
        $cells.each -> array.push parseInt($.trim($(this).text()), 10)
        expect(array).toEqual(expected)

        # Jan 1900
        @$input.val('1900-01-01').trigger('change')
        $cells = @$input.data('datepicker').$calendar.find('td')
        expected = [31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
          20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        array = []
        $cells.each -> array.push parseInt($.trim($(this).text()), 10)
        expect(array).toEqual(expected)

        # Jul 2996
        @$input.val('2996-07-12').trigger('change')
        $cells = @$input.data('datepicker').$calendar.find('td')
        expected = [26, 27, 28, 29, 30, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
          20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6]
        array = []
        $cells.each -> array.push parseInt($.trim($(this).text()), 10)
        expect(array).toEqual(expected)

      it 'should have weekday names in table header', ->
        @$input.val('2012-08-01').datepicker()
        $cells = @$input.data('datepicker').$calendar.find('.wdp-weekdays > th')
        array = []
        $cells.each -> array.push $.trim($(this).text())
        expect(array).toEqual(['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'])

      it 'should have month and year in table header', ->
        @$input.val('2012-08-01').datepicker()
        monthAndYear = $.trim @$input.data('datepicker').$calendar.find('.wdp-month-and-year').text()
        expect(monthAndYear).toEqual('August 2012')


    # Tests for next and prev arrows for navigating through months.
    describe 'Navigation', ->
      beforeEach ->
        @$input.val('2012-08-01').datepicker()
        @widget = @$input.data 'datepicker'

      describe 'When next arrow is clicked', ->
        beforeEach ->
          @$next = @widget.$datepicker.find('.js-wdp-next')
          @$next.click()

        it 'should set the month and year of state', ->
          @$next.click()
          expect(@widget._state.month).toEqual(9)
          expect(@widget._state.year).toEqual(2012)

          # Brings calendar to Jan 2013
          @$next.click().click().click().click()
          expect(@widget._state.month).toEqual(1)
          expect(@widget._state.year).toEqual(2013)

      describe 'When prev arrow is clicked', ->
        beforeEach ->
          @$input.val('2012-03-01').trigger('change')
          @$prev = @widget.$datepicker.find('.js-wdp-prev')

        it 'should set the month and year of state', ->
          @$prev.click()
          expect(@widget._state.month).toEqual(1)
          expect(@widget._state.year).toEqual(2012)

          # Brings calendar to Jan 2013
          @$prev.click().click()
          expect(@widget._state.month).toEqual(11)
          expect(@widget._state.year).toEqual(2011)


    describe 'Unit tests', ->
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
