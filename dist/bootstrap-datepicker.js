var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

(function(root, factory) {
  if (typeof define === 'function' && define.amd) {
    return define(['jquery', 'underscore', 'backbone'], function($, _, Backbone) {
      return root.Datepicker = factory($, _, Backbone);
    });
  } else {
    return root.Datepicker = factory(root.$, root._, root.Backbone);
  }
})(this, function($, _, Backbone) {
  var Datepicker;
  Datepicker = (function(_super) {

    __extends(Datepicker, _super);

    function Datepicker() {
      return Datepicker.__super__.constructor.apply(this, arguments);
    }

    Datepicker.prototype.initialize = function(options) {};

    return Datepicker;

  })(Backbone.View);
  return Datepicker;
});
