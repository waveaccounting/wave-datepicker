
describe('Wave Datepicker', function() {
  beforeEach(function() {
    return this.$input = $('<input id="Date">').appendTo(document.body);
  });
  afterEach(function() {
    return this.$input.remove();
  });
  return describe('$.fn.datepicker', function() {
    it('should be defined on jQuery object', function() {
      return expect(this.$input.datepicker).toEqual(jasmine.any(Function));
    });
    return it('should instantiate the WaveDatepicker call', function() {
      var stub;
      stub = sinon.stub(WDP, 'Datepicker');
      this.$input.datepicker();
      expect(stub).toHaveBeenCalledOnce();
      return stub.restore();
    });
  });
});
