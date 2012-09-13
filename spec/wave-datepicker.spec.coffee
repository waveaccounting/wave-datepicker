describe 'Wave Datepicker', ->
  beforeEach ->
    # The input box to test on.
    @$input = $('<input id="Date">').appendTo(document.body)

  afterEach ->
    @$input.remove()

  describe '$.fn.datepicker', ->
    it 'should instantiate the WaveDatepicker call', ->
