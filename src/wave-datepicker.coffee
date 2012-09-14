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
                  <th class="wdp-prev span1">
                    <button class="btn btn-small js-wdp-prev"><i class="icon-arrow-left"/></button>
                  </th>
                  <th colspan="5" class="wdp-month-and-year span10">
                  </th>
                  <th class="wdp-next span1">
                    <button class="btn btn-small js-wdp-next"><i class="icon-arrow-right"/></button>
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

    # State our picker is currently in.
    # Month and year affect the calendar.
    _state: null

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

      @_initState()
      @_initPicker()
      @_initElements()
      @_initShortcuts()
      @_initEvents()

    render: =>
      @_updateMonthAndYear()
      @_fill()
      @_updateSelection()
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

    _initState: ->
      @_state = {}
      @setDate @date

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
      @$el.on 'datechange', @render

      @$datepicker.on 'mousedown', @_cancelEvent
      @$datepicker.on 'click', '.js-wdp-calendar-cell', @_selectDate
      @$datepicker.on 'click', '.js-wdp-prev', @prev
      @$datepicker.on 'click', '.js-wdp-prev-select', @prevSelect
      @$datepicker.on 'click', '.js-wdp-next', @next
      @$datepicker.on 'click', '.js-wdp-next-select', @nextSelect
      @$datepicker.on 'click', '.js-wdp-shortcut', @_onShortcutClick

    # Updates the picker with the current date.
    _updateMonthAndYear: =>
      date = new Date(@_state.year, @_state.month, 1)
      monthAndYear = moment(date).format('MMMM YYYY')
      @$monthAndYear.text monthAndYear

    # Sets the Date object for this widget and update `<input>` field.
    setDate: (date) =>
      @date = date
      @_state.month = @date.getMonth()
      @_state.year = @date.getFullYear()
      @$el.val @_formatDate(date)
      @$el.trigger 'datechange', @date

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

    # Fills in calendar based on month and year we're currently viewing.
    _fill: ->
      # Set to the year and month from state, and the day is the first of the month.
      date = new Date(@_state.year, @_state.month, 1)

      index = 0  # Current index for the calendar cells.

      html = []  # array for holding HTML of the calendar

      wrapped = moment date
      daysInMonth = wrapped.daysInMonth()

      startOfMonth = wrapped.clone().startOf('month')
      endOfMonth = wrapped.clone().endOf('month')

      # 0 == Sun, 1 == Mon, ..., 6 == Sat
      firstDateDay = startOfMonth.day() - 1
      lastDateDay = endOfMonth.day() - 1
      paddingStart = 0

      # If start date is not Sun then padd beginning of calendar.
      if firstDateDay isnt 0
        prevMonth = startOfMonth.clone()

        for i in [0..firstDateDay]
          if (index++) is 0
            html.push '<tr class="wdp-calendar-row">'
          d = prevMonth.add('days', -1).date()
          formattedPrevMonth = @_formatDate new Date(@_state.year, @_state.month - 1, d)
          # + 1 because element at index zero is the <tr>
          html[6 - i + 1] = "<td class=\"wdp-calendar-othermonth js-wdp-prev-select\" data-date=\"#{formattedPrevMonth}\">#{d}</td>"
          paddingStart++

      # For formatting purposes in the following loop.
      currMonth = new Date(@_state.year, @_state.month, 1)

      # Fill in dates for this month.
      for i in [1..daysInMonth]
        currMonth.setDate(i)
        formatted = @_formatDate currMonth
        if (index++) % 7 is 0
          html.push '</tr><tr class="wdp-calendar-row">'
        html.push "<td class=\"js-wdp-calendar-cell\" data-date=\"#{formatted}\">#{i}</td>"

      # If end date is not Sat then padd the end of calendar.
      if lastDateDay isnt 6
        nextMonth = endOfMonth.clone()
        n = paddingStart + daysInMonth
        while (n++) % 7 isnt 0
          d = nextMonth.add('days', 1).date()
          formattedNextMonth = @_formatDate new Date(@_state.year, @_state.month + 1, d)
          if (index++) % 7 is 0
            html.push '</tr><tr class="wdp-calendar-row">'
          html.push "<td class=\"wdp-calendar-othermonth js-wdp-next-select\" data-date=\"#{formattedNextMonth}\">#{d}</td>"

      html.push '</tr>'

      @$tbody.html html.join ''

    # Navigate to prev month.
    prev: =>
      if @_state.month is 1
        @_state.month = 12
        @_state.year -= 1
      else
        @_state.month -= 1
      @render()

    # Navigate to the previous month and select the date clicked
    prevSelect: (e) =>
      @prev
      @_selectDate e

    # Navigate to next month.
    next: =>
      if @_state.month is 12
        @_state.month = 1
        @_state.year += 1
      else
        @_state.month += 1
      @render()

    # Navigate to the next month and select the date clicked
    nextSelect: (e) =>
      @next
      @_selectDate e

    _cancelEvent: (e) => e.stopPropagation(); e.preventDefault()

    _onShortcutClick: (e) =>
      name = $(e.target).data('shortcut')
      offset = @shortcuts[name]
      wrapper = moment(new Date())

      # Go through each offset and set on date.
      for k, v of offset
        wrapper.add(k, v)

      @setDate wrapper.toDate()

    _updateSelection: ->
      # Update selection
      dateStr = @_formatDate @date
      @$tbody.find('.wdp-selected').removeClass('wdp-selected')
      @$tbody.find("td[data-date=#{dateStr}]").addClass('wdp-selected')

    _selectDate: (e) =>
      date = @_parseDate $(e.target).data('date')
      @setDate date


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
