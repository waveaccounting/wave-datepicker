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
      describe '_cancelEvent', ->
        e =
          stopPropagation: sinon.spy()
          preventDefault: sinon.spy()
        WDP.WaveDatepicker.prototype._cancelEvent.call null, e
        # TODO: Get jasmine-sinon to work then we can change these to `toHaveBeenCalledOnce`
        expect(e.stopPropagation.callCount).not.toEqual(0)
        expect(e.preventDefault.callCount).not.toEqual(0)
