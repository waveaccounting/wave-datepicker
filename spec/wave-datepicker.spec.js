
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
    it('should instantiate the WaveDatepicker call', function() {
      var _WaveDatepicker;
      _WaveDatepicker = sinon.stub(WDP, 'WaveDatepicker');
      this.$input.datepicker();
      expect(_WaveDatepicker).toHaveBeenCalledOnce();
      return _WaveDatepicker.restore();
    });
    it('should not instantiate datepicker twice on same element', function() {
      var _WaveDatepicker;
      _WaveDatepicker = sinon.stub(WDP, 'WaveDatepicker');
      this.$input.datepicker();
      this.$input.datepicker();
      expect(_WaveDatepicker).toHaveBeenCalledOnce();
      return _WaveDatepicker.restore();
    });
    it('should set the datepicker widget as data on the <input>', function() {
      var _WaveDatepicker;
      _WaveDatepicker = sinon.stub(WDP, 'WaveDatepicker');
      this.$input.datepicker();
      expect(this.$input.data('datepicker')).toEqual(jasmine.any(_WaveDatepicker));
      return _WaveDatepicker.restore();
    });
    it('should use the value attribute to set default date', function() {
      var date;
      this.$input.val('2012-08-01').datepicker();
      date = this.$input.data('datepicker').date;
      expect(date).toBeDefined();
      expect(date.getFullYear()).toEqual(2012);
      expect(date.getMonth()).toEqual(7);
      return expect(date.getDate()).toEqual(1);
    });
    return it('should set today as the default is value not set on <input>', function() {
      var date, today;
      this.$input.datepicker();
      date = this.$input.data('datepicker').date;
      today = new Date();
      expect(date).toBeDefined();
      expect(date.getFullYear()).toEqual(today.getFullYear());
      expect(date.getMonth()).toEqual(today.getMonth());
      return expect(date.getDate()).toEqual(today.getDate());
    });
  });
});
