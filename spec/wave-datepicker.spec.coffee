describe 'Wave Datepicker', ->
  beforeEach ->
    # The input box to test on.
    @$input = $('<input id="Date">').appendTo(document.body)

  afterEach ->
    @$input.remove()

  describe '$.fn.datepicker', ->
    it 'should be defined on jQuery object', ->
      expect(@$input.datepicker).toEqual(jasmine.any(Function))

    it 'should instantiate the WaveDatepicker call', ->
      _WaveDatepicker = sinon.stub WDP, 'WaveDatepicker'

      @$input.datepicker()

      expect(_WaveDatepicker).toHaveBeenCalledOnce()

      _WaveDatepicker.restore()

    it 'should not instantiate datepicker twice on same element', ->
      _WaveDatepicker = sinon.stub WDP, 'WaveDatepicker'

      # Called twice
      @$input.datepicker()
      @$input.datepicker()

      # But only instantiated twice
      expect(_WaveDatepicker).toHaveBeenCalledOnce()

      _WaveDatepicker.restore()

    it 'should set the datepicker widget as data on the <input>', ->
      _WaveDatepicker = sinon.stub WDP, 'WaveDatepicker'
      @$input.datepicker()
      expect(@$input.data('datepicker')).toEqual(jasmine.any(_WaveDatepicker))
      _WaveDatepicker.restore()

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
