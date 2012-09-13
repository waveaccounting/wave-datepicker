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
  WDP = {}

  # Default template
  # .dropdown-menu is hidden by default
  WDP.template = '
    <div class="wave-datepicker dropdown-menu">
      <div class="row-fluid">
        <div class="span5" wave-datepicker-shortcuts>
        </div>
        <div class="span7 wave-datepicker-calendar">
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


  # Date parsing and formatting utils
  WDP.DateUtils =
    format: (date, format) -> moment(date).format(format)
    parse: (str, format) -> moment(str, format)


  # Allow users to set their own template and date functions
  WDP.configure = (options) ->
    WDP.template = options.template or WDP.template
    WDP.DateUtils.format = options.dateFormat or WDP.DateUtils.format
    WDP.DateUtils.parse = options.dateParse or WDP.DateUtils.parse


  class WDP.WaveDatepicker
    _defaultFormat: 'YYYY-MM-DD'

    constructor: (@options) ->
      @el = @options.el
      @$el = $(@el)

      @date = @options.date or new Date()
      @dateFormat = @options.format or @_defaultFormat

      @initElement()
      @initPicker()
      @initEvents()

    initElement: ->
      if @options.className
        @$el.addClass(@options.className)

      @$el.val @formatDate(@date)

    # Renders the widget and sets elements cache.
    initPicker: ->
      @$datepicker = $ WDP.template
      @$shortcuts = @$datepicker.find '.wave-datepicker-shortcuts'
      @$calendar = @$datepicker.find '.wave-datepicker-calendar'
      @$tbody = @$calender.find 'tbody'

      # Put at the end of <body>
      @$datepicker.appendTo document.body

    initEvents: ->
      @$datepicker.on 'click', @onClick
      @$datepicker.on 'mousedown', @cancelEvent
      @$el.on('focus', @show).on('blur', @hide)

    render: ->
      calendarHTML= 
      @$tbody.html calendarHTML

    formatDate: (date) -> WDP.DateUtils.format(date, @dateFormat)

    parseDate: (str) -> WDP.DateUtils.parse(date, @dateFormat)

    # Places the datepicker below the input box
    place: ->
      zIndex = parseInt(
        @$el.parents().filter(-> $(this).css('z-index') isnt 'auto').first().css('z-index')
        , 10) + 10

      offset = @$el.offset()

      @$datepicker.css(
        top: offset.top + @height
        left: offset.left
        zIndex: zIndex
      )

    show: =>
      @$datepicker.addClass 'show'
      @height = @$el.outerHeight()
      @place()

    hide: =>
      @$datepicker.removeClass 'show'

    onClick: (e) =>

    cancelEvent: (e) =>
      e.stopPropagation()
      e.preventDefault()


  # Add jQuery widget
  $.fn.datepicker = (options = {}) ->
    @each ->
      $this = $ this
      widget = $this.data('datepicker')
      $.extend options, {el: this}

      unless widget
        $this.data 'datepicker', (widget = new WDP.WaveDatepicker(options))


  return WDP
)
