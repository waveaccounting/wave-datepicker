((root, factory) ->
  # Define AMD module if AMD support exists.
  if typeof define is 'function' and define.amd
    define ['jquery'], ($) ->
      root.WDP = factory($)
  # Otherwise attach module to root.
  else
    root.WDP = factory(root.$)
)(this, ($) ->

  # Namespace to export
  WDP =
    Helpers: {}


  # Default templates
  WDP.Helpers.setTemplate = (template) ->
    WDP.template = tempalte

  WDP.template = '
    <div class="wave-datepicker dropdown-menu">
      <div class="row-fluid">
        <div class="span4" wave-datepicker-shortcuts>
        </div>
        <div class="span8 wave-datepicker-calendar">
          <table class="table-condensed">
            <thead>
              <tr>
                  <th class="prev">
                    <i class="icon-arrow-left"/>
                  </th>
                  <th colspan="5" class="switch"></th>
                  <th class="next">
                    <i class="icon-arrow-right"/>
                  </th>
              </tr>
            </thead>
            <tbody>
            </tbody>
          </table>
        </div>
      </div>
    </div>'   


  class WDP.WaveDatepicker
    constructor: (options) ->
      @el = options.el
      @$el = $(@el)

      if options.className
        @$el.addClass(options.className)

    # Renders the widget and sets elements cache.
    render: ->
      @$el.html WDP.Templates.widget
      @$shortcuts = @$el.find('.wave-datepicker-shortcuts')
      @$calendar = @$el.find('.wave-datepicker-calendar')


  return WDP
)
