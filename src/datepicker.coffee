((root, factory) ->
  # Define AMD module if AMD support exists.
  if typeof define is 'function' and define.amd
    define ['jquery', 'underscore', 'backbone'], ($, _, Backbone) ->
      root.amdWebGlobal = factory($, _, Backbone)
  # Otherwise attach module to root.
  else
    root.amdWebGlobal = factory(root.$, root._, root.Backbone)

)(this, ($, _, Backbone) ->

  class Datepicker extends Backbone.View
    initialize: (options) ->


  return Datepicker
)
