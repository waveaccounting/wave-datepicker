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
        <div class="span5">
          <ul class="wdp-shortcuts"></ul>
        </div>
        <div class="span7">
          <table class="table-condensed wdp-calendar">
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

    # Shortcut key shows as links on left side of picker.
    #
    # The value is an object representing offsets from today's date.
    #
    # Offsets are processed using the `add` function from
    # [moment.js](http://momentjs.com/docs/#/manipulating/add/).
    _defaultShortcuts:
      'Today':
        days: 0

    constructor: (@options) ->
      @el = @options.el
      @$el = $(@el)

      @dateFormat = @options.format or @_defaultFormat
    # Reads the value of the `<input>` field and set it as the date.
      if (dateStr = @$el.val())
        @date = @_parseDate dateStr

      # If date could not be set from @$el.val() then set to today.
      @date or= new Date()

      # e.g. 'today' -> sets calendar value to today's date
      @shortcuts = options.shortcuts or @_defaultShortcuts

      @_initPicker()
      @_initElements()
      @_initShortcuts()
      @_initEvents()

    render: ->
      calendarHTML = ''
      @$tbody.html calendarHTML
      @_updateDateInUI()

      return this

    show: =>
      @$datepicker.addClass 'show'
      @height = @$el.outerHeight()
      @_place()
      @$window.on 'resize', @_place

    hide: =>
      @$datepicker.removeClass 'show'
      @$window.off 'resize', @_place

    _initElements: ->
      if @options.className
        @$el.addClass(@options.className)

      # Set initial date value
      @$el.val @_formatDate(@date)

      # Set up elements cache
      @$shortcuts = @$datepicker.find '.wdp-shortcuts'
      @$calendar = @$datepicker.find '.wdp-calendar'
      @$tbody = @$calendar.find 'tbody'
      @$monthAndYear = @$calendar.find '.wdp-month-and-year'
      @$window = $ window

    # Renders the widget and append to the `<body>`
    _initPicker: ->
      @$datepicker = $ WDP.template
      @$datepicker.appendTo document.body

    _initShortcuts: ->
      shortcuts = []

      for name, offset of @shortcuts
        shortcuts.push "<li><a data-shortcut=\"#{name}\" class=\"wdp-shortcut js-wdp-shortcut\" href=\"javascript:void(0)\">
          #{name}</a></li>"
      @$shortcuts.html shortcuts.join ''

    _initEvents: ->
      # Show and hide picker
      @$el.on('focus', @show).on('blur', @hide)
      @$el.on 'datechange', @_updateDateInUI

      @$datepicker.on 'click', @_onClick
      @$datepicker.on 'mousedown', @_cancelEvent
      @$datepicker.on 'click', '.js-wdp-shortcut', @_onShortcutClick

    # Updates the picker with the current date.
    _updateDateInUI: =>
      monthAndYear = moment(@date).format('MMMM YYYY')
      @$el.val @_formatDate(@date)
      @$monthAndYear.text monthAndYear

    # Sets the Date object for this widget and update `<input>` field.
    _setDate: (date) ->
      @date = date
      @$el.trigger 'datechange', date

    _formatDate: (date) -> WDP.DateUtils.format(date, @dateFormat)

    _parseDate: (str) -> WDP.DateUtils.parse(str, @dateFormat).toDate()

    # Places the datepicker below the input box
    _place: =>
      zIndex = parseInt(
        @$el.parents().filter(-> $(this).css('z-index') isnt 'auto').first().css('z-index')
        , 10) + 10

      offset = @$el.offset()

      @$datepicker.css(
        top: offset.top + @height
        left: offset.left
        zIndex: zIndex
      )

    _onClick: (e) =>

    _cancelEvent: (e) =>
      e.stopPropagation()
      e.preventDefault()

    _onShortcutClick: (e) =>
      name = $(e.target).data('shortcut')
      offset = @shortcuts[name]
      wrapper = moment(new Date())

      # Go through each offset and set on date.
      for k, v of offset
        wrapper.add(k, v)

      @_setDate wrapper.toDate()


  # Add jQuery widget
  $.fn.datepicker = (options = {}, args...) ->
    @each ->
      $this = $ this
      widget = $this.data('datepicker')
      $.extend options, {el: this}

      unless widget
        $this.data 'datepicker', (widget = new WDP.WaveDatepicker(options).render())

      # Prevent methods beginning with _ to be called because they are private
      if typeof options is 'string' and options[0] isnt '_' and options isnt 'render'
        widget[options].apply widget, args


  return WDP
)
