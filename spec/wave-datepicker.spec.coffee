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
      stub = sinon.stub WDP,'Datepicker'

      @$input.datepicker()

      expect(stub).toHaveBeenCalledOnce()

      stub.restore()
