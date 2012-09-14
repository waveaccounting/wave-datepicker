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
