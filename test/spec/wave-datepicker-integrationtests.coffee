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
      expect(@$input.datepicker).to.be.instanceof Function

    it 'should instantiate the WaveDatepicker call', ->
      @stubWaveDatepicker()

      @$input.datepicker()

      expect(@_WaveDatepickerStub.calledOnce).to.be.true

      @restoreWaveDatepicker()

    it 'should not instantiate datepicker twice on same element', ->
      @stubWaveDatepicker()

      # Called twice
      @$input.datepicker()
      @$input.datepicker()

      # But only instantiated twice
      expect(@_WaveDatepickerStub.calledOnce).to.be.true

      @restoreWaveDatepicker()

    it 'should set the datepicker widget as data on the <input>', ->
      @stubWaveDatepicker()
      @$input.datepicker()
      expect(@$input.data('datepicker')).to.eql @_WaveDatepicker
      @restoreWaveDatepicker()

    it 'should use the value attribute to set default date', ->
      @$input.val('2012-08-01').datepicker()
      date = @$input.data('datepicker').date
      expect(date).to.be.defined
      expect(date.getFullYear()).to.eql 2012
      expect(date.getMonth()).to.eql 7
      expect(date.getDate()).to.eql 1

    it 'should set today as the default is value not set on <input>', ->
      @$input.datepicker()
      date = @$input.data('datepicker').date
      today = new Date()
      expect(date).to.be.defined
      expect(date.getFullYear()).to.eql(today.getFullYear())
      expect(date.getMonth()).to.eql(today.getMonth())
      expect(date.getDate()).to.eql(today.getDate())


    describe 'Shortcuts', ->
      it 'should by default not have shortcuts', ->
        @$input.datepicker()
        widget = @$input.data('datepicker')
        expect(widget.$datepicker.find('.wdp-shortcut').length is 0).to.be.true

      it 'should provide default options if `shortcuts` is passed as true', ->
        @$input.datepicker({shortcuts: true})
        widget = @$input.data('datepicker')
        expect(widget.$datepicker.find('.wdp-shortcut').length is 0).to.be.false
        today = widget.$datepicker.find('.wdp-shortcut')
        expect($.trim(today.text())).to.eql('Today')

      it 'should attach extra element attributes if they are provided', ->
        @$input.datepicker(
          shortcuts: {
            'Foo': {days: 1, attrs: {'data-bar': 'abc'}}
          })

        widget = @$input.data('datepicker')

        expect(widget.shortcuts.$el.find('[data-bar=abc]').length > 0).to.be.true

      describe 'When a shortcut is clicked', ->
        it 'should add the corresponding offset to the widget date', ->
          offsets = {days: 5, months: 1, years: -1} 
          @$input.datepicker(
            'shortcuts': {
              'Foo': offsets
            })
          today = new Date()
          # Date and month can overflow, which JavaScript will handle for us.
          expected = moment(new Date()).add(offsets).toDate()
          widget = @$input.data('datepicker')

          widget.$datepicker.find('.wdp-shortcut').click()

          expect(widget.date.getFullYear()).to.equal(expected.getFullYear())
          expect(widget.date.getMonth()).to.equal(expected.getMonth())
          expect(widget.date.getDate()).to.equal(expected.getDate())


    describe 'On input change', ->
      it 'should update the date of the the widget', ->
        @$input.val('2012-08-01').datepicker()
        date = new Date 2012, 7, 1  # 7 is Aug
        widget = @$input.data('datepicker')
        expect(widget.date.getFullYear()).to.eql(date.getFullYear())
        expect(widget.date.getMonth()).to.eql(date.getMonth())
        expect(widget.date.getDate()).to.eql(date.getDate())

        @$input.val('2011-04-13').trigger('change')
        date = new Date 2011, 3, 13  # 7 is Aug
        expect(widget.date.getFullYear()).to.eql(date.getFullYear())
        expect(widget.date.getMonth()).to.eql(date.getMonth())
        expect(widget.date.getDate()).to.eql(date.getDate())

      describe 'when input value is bad', ->
        it 'should not change the date', ->
          @$input.val('2012-08-01').datepicker()
          widget = @$input.data('datepicker')
          originalDate = widget.date

          # This should not change widget's date.
          @$input.val('some bad value').trigger('change')

          expect(widget.date).to.equal(originalDate)


    describe 'Rendered calendar', ->
      it 'should draw the calendar with current month and fill start/end with prev/next month', ->
        # Aug 2012
        @$input.val('2012-08-01').datepicker()
        $cells = @$input.data('datepicker').$calendar.find('td')
        expected = [29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
          20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8]
        array = []
        $cells.each -> array.push parseInt($.trim($(this).text()), 10)
        expect(array).to.eql(expected)

        # Nov 2014
        @$input.val('2014-11-13').trigger('change')
        $cells = @$input.data('datepicker').$calendar.find('td')
        expected = [26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
          20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 1, 2, 3, 4, 5, 6]
        array = []
        $cells.each -> array.push parseInt($.trim($(this).text()), 10)
        expect(array).to.eql(expected)

        # Jan 1900
        @$input.val('1900-01-01').trigger('change')
        $cells = @$input.data('datepicker').$calendar.find('td')
        expected = [31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
          20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        array = []
        $cells.each -> array.push parseInt($.trim($(this).text()), 10)
        expect(array).to.eql(expected)

        # Jul 2996
        @$input.val('2996-07-12').trigger('change')
        $cells = @$input.data('datepicker').$calendar.find('td')
        expected = [26, 27, 28, 29, 30, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
          20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6]
        array = []
        $cells.each -> array.push parseInt($.trim($(this).text()), 10)
        expect(array).to.eql(expected)

      it 'should have weekday names in table header', ->
        @$input.val('2012-08-01').datepicker()
        $cells = @$input.data('datepicker').$calendar.find('.wdp-weekdays > th')
        array = []
        $cells.each -> array.push $.trim($(this).text())
        expect(array).to.eql(['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'])

      it 'should have month and year in table header', ->
        @$input.val('2012-08-01').datepicker()
        monthAndYear = $.trim @$input.data('datepicker').$calendar.find('.wdp-month-and-year').text()
        expect(monthAndYear).to.eql('August 2012')


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
          expect(@widget._state.month).to.eql(9)
          expect(@widget._state.year).to.eql(2012)

          # Brings calendar to Jan 2013
          @$next.click().click().click().click()
          expect(@widget._state.month).to.eql(1)
          expect(@widget._state.year).to.eql(2013)

      describe 'When prev arrow is clicked', ->
        beforeEach ->
          @$input.val('2012-03-01').trigger('change')
          @$prev = @widget.$datepicker.find('.js-wdp-prev')

        it 'should set the month and year of state', ->
          @$prev.click()
          expect(@widget._state.month).to.eql(1)
          expect(@widget._state.year).to.eql(2012)

          # Brings calendar to Jan 2013
          @$prev.click().click()
          expect(@widget._state.month).to.eql(11)
          expect(@widget._state.year).to.eql(2011)


    describe 'Multiple pickers on page', ->
      beforeEach ->
        @$input.datepicker()
        @$input2 = $('<input id="Date2">').appendTo(document.body).datepicker()
        @$input3 = $('<input id="Date3">').appendTo(document.body).datepicker()

        @picker1 = @$input.data('datepicker')
        @picker2 = @$input2.data('datepicker')
        @picker3 = @$input3.data('datepicker')

      afterEach ->
        @$input2.datepicker('destroy')
        @$input2.remove()

        @$input3.datepicker('destroy')
        @$input3.remove()

      describe 'When a click is on a different picker than current active picker', ->
        it 'should set new focus and hide inactive picker', ->
          @$input.focus()
          expect(@picker1._isShown).to.be.true
          expect(@picker2._isShown).to.be.false
          expect(@picker3._isShown).to.be.false

          @$input2.focus()
          expect(@picker1._isShown).to.be.false
          expect(@picker2._isShown).to.be.true
          expect(@picker3._isShown).to.be.false

          @$input3.focus()
          expect(@picker1._isShown).to.be.false
          expect(@picker2._isShown).to.be.false
          expect(@picker3._isShown).to.be.true


    describe 'Base date', ->
      it 'should be used to calcualte shortcuts', ->
        expected = new Date(2012, 7, 1) 

        @$input.datepicker(
          baseDate: expected
          shortcuts:
            'Right away':
              days: 1
        )
        widget = @$input.data('datepicker')

        widget.$datepicker.find('.wdp-shortcut').click()

        expect(widget.date.getFullYear()).to.eql(expected.getFullYear())
        expect(widget.date.getMonth()).to.eql(expected.getMonth())
        expect(widget.date.getDate()).to.eql(expected.getDate() + 1)


    describe 'Add-on icon trigger', ->
      beforeEach ->
        # The input box to test on.
        @$box = $('<div class="input-append"><input id="Date2"><span class="add-on">*</span></div>').appendTo(document.body)
        @$box.find('input').datepicker()

      afterEach ->
        @$box.find('input').datepicker('destroy')
        @$box.remove()

      it 'should open datepicker when the add-on icon is clicked', ->
        @$box.find('.add-on').click()
        picker = @$box.find('input').data('datepicker')
        expect(picker._isShown).to.be.true
        

    describe 'Date format', ->
      describe 'when the format option is passed', ->
        it 'should use that format string to parse and format dates', ->
          @$input.val('2012/08/31')
          @$input.datepicker(format: 'YYYY/MM/DD')
          date = @$input.data('datepicker').date
          expect(date).to.be.defined
          expect(date.getFullYear()).to.eql(2012)
          expect(date.getMonth()).to.eql(7)
          expect(date.getDate()).to.eql(31)

      describe 'when date data-date-format is set on the <input>', ->
        it 'should use that format string to parse and format dates', ->
          @$input.val('2012/08/31').attr('data-date-format', 'YYYY/MM/DD')
          @$input.datepicker()
          date = @$input.data('datepicker').date
          expect(date).to.be.defined
          expect(date.getFullYear()).to.eql(2012)
          expect(date.getMonth()).to.eql(7)
          expect(date.getDate()).to.eql(31)

      describe 'when the date format does not include year', ->
        it 'should use the current year', ->
          @$input.val('12-31').attr('data-date-format', 'MM-DD')
          @$input.datepicker()
          date = @$input.data('datepicker').date
          expect(date).to.be.defined
          expect(date.getFullYear()).to.eql(new Date().getFullYear())
          expect(date.getMonth()).to.eql(11)
          expect(date.getDate()).to.eql(31)


    describe 'Allow clear', ->
      describe 'when data-date-allow-clear is "yes" on the <input>', ->
        it 'should allow user to null out the date', ->
          @$input.val('')
          @$input.attr('data-date-allow-clear', 'yes')
          @$input.datepicker()
          expect(@$input.datepicker('getDate')).to.be.null

      describe 'when data-date-allow-clear is "true" on the <input>', ->
        it 'should allow user to null out the date', ->
          @$input.val('')
          @$input.attr('data-date-allow-clear', 'true')
          @$input.datepicker()
          expect(@$input.datepicker('getDate')).to.be.null

      describe 'when allowClear is passed inside the options', ->
        beforeEach ->
          @$input.val('')
          @$input.datepicker(allowClear: true)

        it 'should allow user to null out the date', ->
          expect(@$input.datepicker('getDate')).to.be.null

        describe 'when user clears out the <input> after setting it', ->
          it 'should null out the date', ->
            # First set it and check the date is set.
            @$input.val('2013-01-01').trigger('change')
            expect(@$input.datepicker('getDate')).not.to.be.null

            # Now unset it and check date is null.
            @$input.val('').trigger('change')
            expect(@$input.datepicker('getDate')).to.be.null
