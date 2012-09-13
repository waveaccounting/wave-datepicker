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
    <div class="wdp dropdown-menu">
      <div class="row-fluid">
        <div class="span5" wdp-shortcuts>
        </div>
        <div class="span7 wdp-calendar">
          <table class="table-condensed">
            <thead>
              <tr>
                  <th class="wdp-prev js-wdp-prev span1">
                    <i class="icon-arrow-left"/>
                  </th>
                  <th colspan="5" class="wdp-month-and-year span10">
                  </th>
                  <th class="wdp-next js-wdp-next span1">
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

      @dateFormat = @options.format or @_defaultFormat

      @updateDate()

      # If date could not be set from @$el.val() then set to today.
      @date or= new Date()

      @initPicker()
      @initElements()
      @initEvents()

    initElements: ->
      if @options.className
        @$el.addClass(@options.className)

      # Set initial date value
      @$el.val @formatDate(@date)

      # Set up elements cache
      @$shortcuts = @$datepicker.find '.wdp-shortcuts'
      @$calendar = @$datepicker.find '.wdp-calendar'
      @$tbody = @$calendar.find 'tbody'
      @$window = $ window

    # Renders the widget and append to the `<body>`
    initPicker: ->
      @$datepicker = $ WDP.template
      @$datepicker.appendTo document.body

    initEvents: ->
      @$datepicker.on 'click', @onClick
      @$datepicker.on 'mousedown', @cancelEvent
      @$el.on('focus', @show).on('blur', @hide)

    # Reads the value of the `<input>` field and set it as the date.
    updateDate: ->
      if (dateStr = @$el.val())
        @date = @parseDate dateStr

    render: ->
      calendarHTML= 
      @$tbody.html calendarHTML

    formatDate: (date) -> WDP.DateUtils.format(date, @dateFormat)

    parseDate: (str) -> WDP.DateUtils.parse(str, @dateFormat).toDate()

    # Places the datepicker below the input box
    place: =>
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
      @$window.on 'resize', @place

    hide: =>
      @$datepicker.removeClass 'show'
      @$window.off 'resize', @place

    onClick: (e) =>

    cancelEvent: (e) =>
      e.stopPropagation()
      e.preventDefault()

    bindWindowResize: ->


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
