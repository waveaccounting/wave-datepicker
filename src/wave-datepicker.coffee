((root, factory) ->
  # Define AMD module if AMD support exists.
  if typeof define is 'function' and define.amd
    define ['jquery'], ($) -> root.WDP = factory($)
  else  # Otherwise attach module to root.
    root.WDP = factory(root.$)
)(this, ($) ->

  # Namespace to export
  WDP = {}

  # Hold reference for testing purposes (so we can stub out if needed).
  WDP.$ = $

  # Default template
  # .dropdown-menu is hidden by default
  WDP.template = "<div class=\"wdp dropdown-menu\">
  <div class=\"row-fluid\">
    <div class=\"span5 wdp-shortcuts\"></div>
    <div class=\"span7\">
      <table class=\"table-condensed wdp-calendar\">
        <thead>
          <tr>
              <th class=\"wdp-prev\">
                <a href=\"javascript:void(0)\" class=\"js-wdp-prev\"><i class=\"icon-arrow-left\"/></a>
              </th>
              <th colspan=\"5\" class=\"wdp-month-and-year\"></th>
              <th class=\"wdp-next\">
                <a href=\"javascript:void(0)\" class=\"js-wdp-next\"><i class=\"icon-arrow-right\"/></a>
              </th>
          </tr>
        </thead>
        <tbody></tbody>
      </table>
    </div>
  </div>
</div>"


  # Date parsing and formatting utils
  WDP.DateUtils =
    format: (date, format) -> moment(date).format(format)
    parse: (str, format) -> moment(str, format)


  # Allow users to set their own template and date functions
  WDP.configure = (options) ->
    WDP.template = options.template or WDP.template
    WDP.DateUtils.format = options.dateFormat or WDP.DateUtils.format
    WDP.DateUtils.parse = options.dateParse or WDP.DateUtils.parse


  # For keydown event handler
  WDP.Keys =
    RETURN: 13
    ESC: 27
    LEFT: 37
    UP: 38
    RIGHT: 39
    DOWN: 40
    TAB: 9

    # For Vim bindings
    H: 72
    J: 74
    K: 75
    L: 76

  # Class for handling shortcuts on the datepicker.
  class WDP.Shortcuts
    # Shortcut key shows as links on left side of picker.
    #
    # The value is an object representing offsets from today's date.
    #
    # Offsets are processed using the `add` function from
    # [moment.js](http://momentjs.com/docs/#/manipulating/add/).
    _defaults:
      'Today':
        days: 0

    currSelectedIndex: -1 # Nothing selected by default

    constructor: (@options) ->
      @options or= @_defaults
      @$el = WDP.$ '<ul>'
      @$el.on 'click', @_onShortcutClick
      @baseDate = @options.baseDate

    render: ->
      shortcuts = []
      @numShortcuts = 0
      for name, options of @options
        extraAttributes = []

        if options.attrs
          for k, v of options.attrs
            extraAttributes.push "#{k}=\"#{v}\""

        shortcuts.push "<li><a
          data-days=\"#{options.days or 0}\" 
          data-months=\"#{options.months or 0}\"
          data-years=\"#{options.years or 0}\"
          data-shortcut-num=\"#{@numShortcuts}\"
          #{extraAttributes.join('')}
          class=\"wdp-shortcut js-wdp-shortcut\" 
          href=\"javascript:void(0)\">#{name}</a></li>"
        @numShortcuts++
      @$el.html shortcuts.join ''
      return this

    # Removes all active class names from shortcuts.
    resetClass: ->
      @$el.find('.wdp-shortcut-active').removeClass('wdp-shortcut-active')

    # Increments the currently selected shortcut index and updates class names.
    selectNext: =>
      @currSelectedIndex = (@currSelectedIndex + 1) % @numShortcuts
      @_updateSelected()

    # Decrements the currently selected shortcut index and updates class names.
    selectPrev: =>
      @currSelectedIndex = (@currSelectedIndex - 1) % @numShortcuts
      # modulo doesn't work on negative numbers :(
      if @currSelectedIndex < 0
        @currSelectedIndex = @numShortcuts - 1
      @_updateSelected()

    # Selects the target shortcut `<a>` element.
    #
    # Event:
    #
    # * dateselect - Passes the `Date` object as the second argument to callback.
    select: ($target) ->
      data = $target.data()
      # Clone so we don't modify exist date.
      wrapper = moment(@baseDate).clone()
      offset =
        days: data.days
        months: data.months
        years: data.years
      wrapper.add offset

      @resetClass()
      $target.addClass 'wdp-shortcut-active'

      $target.trigger 'dateselect', wrapper.toDate()

    # Calls select for any clicks on shortcut `<a>` elements.
    _onShortcutClick: (e) => @select WDP.$(e.target)
    

    # Updates the class names to reflect the currently selected shortcut.
    #
    # Calls select method on the shortcut `<a>` element.
    _updateSelected: =>
      @resetClass()
      $target = @$el.find(".wdp-shortcut[data-shortcut-num=#{@currSelectedIndex}]").addClass 'wdp-shortcut-active'
      @select $target


  WDP.activeDatepicker = null
  
  # Keep track of datepickers in memory.
  WDP.datepickers = []

  # Main datepicker widget.
  class WDP.WaveDatepicker
    # Format is as specified in [moment.js](http://momentjs.com/).
    _defaultFormat: 'YYYY-MM-DD'

    # State our picker is currently in.
    # Month and year affect the calendar.
    _state: null

    constructor: (@options) ->
      @el = @options.el
      @$el = WDP.$ @el

      @dateFormat = @options.format or @_defaultFormat

      @_state = {}

      @_updateFromInput()

      @_initPicker()
      @_initElements()
      @_initEvents()

      @baseDate = @options.baseDate or new Date()

      # e.g. 'today' -> sets calendar value to today's date
      @shortcuts = new WDP.Shortcuts(options.shortcuts).render()
      @$shortcuts.append @shortcuts.$el
      # Setting date clears any selected shortcuts
      @shortcuts?.resetClass()
      @shortcuts.baseDate = @baseDate


      # Setting date clears any selected shortcuts
      @shortcuts?.resetClass()

      @$shortcuts.on 'dateselect', (e, date) => @setDate(date)

      # Keep track of this instance
      WDP.datepickers.push this

    render: =>
      @_updateMonthAndYear()
      @_fill()
      @_updateSelection()
      return this

    hideInactive: ->
      picker.hide() for picker in WDP.datepickers when picker isnt WDP.activeDatepicker

    # Shows the widget if not shown already.
    show: =>
      unless @_isShown
        # Mark current picker as the active one.
        # Hide all others.
        WDP.activeDatepicker = this
        @hideInactive()

        @_isShown = true
        @$datepicker.addClass 'show'
        @height = @$el.outerHeight()
        @_place()
        @$window.on 'resize', @_place
        @$document.on 'click', @hide

    # Hides the widget if it is shown.
    hide: (e) =>
      if @_isShown
        @_isShown = false
        @$datepicker.removeClass 'show'
        @$window.off 'resize', @_place
        @$document.off 'click', @hide

    # Sets the Date object for this widget and update `<input>` field.
    setDate: (date) =>
      @date = date
      @_state.month = @date.getMonth()
      @_state.year = @date.getFullYear()
      @$el.val @_formatDate(date)
      @$el.trigger 'datechange', @date

    getDate: -> @date

    # Navigate to prev month.
    prev: =>
      if @_state.month is 1
        @_state.month = 12
        @_state.year -= 1
      else
        @_state.month -= 1
      @render()

    # Navigate to next month.
    next: =>
      if @_state.month is 12
        @_state.month = 1
        @_state.year += 1
      else
        @_state.month += 1
      @render()

    # Cleanup method.
    destroy: =>
      @$datepicker.remove()
      @$el.removeData('datepicker')

      # Remove this instance
      WDP.datepickers = (picker for picker in WDP.datepickers when picker isnt this)

    # Base date is used to calculate shortcuts.
    setBaseDate: (date) ->
      @basedate = @shortcuts.baseDate = date

    getBaseDate: -> @baseDate

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
      @$document = $ document

    # Renders the widget and append to the `<body>`
    _initPicker: ->
      @$datepicker = $ WDP.template
      @$datepicker.appendTo document.body

      weekdays = moment.weekdaysMin.join '</th><th>'

      @$datepicker.find('thead').append "<tr class=\"wdp-weekdays\"><th>#{weekdays}</th></tr>"

    _initEvents: ->
      # Show and hide picker
      @$el.on 'focus', @show
      @$el.on 'change', @_updateFromInput
      @$el.on 'datechange', @render
      @$el.on 'keydown', @_onInputKeydown
      # Also show on click (it might be hidden but focused)
      @$el.on 'click', @show
      @$el.on 'click', @_cancelEvent

      @$datepicker.on 'click', '.js-wdp-calendar-cell', @_selectDate
      @$datepicker.on 'click', '.js-wdp-prev', @prev
      @$datepicker.on 'click', '.js-wdp-next', @next
      @$datepicker.on 'click', @_cancelEvent
      @$datepicker.on 'mousedown', @_cancelEvent

    _updateFromInput: =>
      # Reads the value of the `<input>` field and set it as the date.
      if (dateStr = @$el.val())
        @date = @_parseDate dateStr

      # If date could not be set from @$el.val() then set to today.
      @date or= new Date()

      @setDate @date

    # Updates the picker with the current date.
    _updateMonthAndYear: =>
      date = new Date(@_state.year, @_state.month, 1)
      monthAndYear = moment(date).format('MMMM YYYY')
      @$monthAndYear.text monthAndYear

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
      firstDateDay = startOfMonth.day()
      lastDateDay = endOfMonth.day()
      paddingStart = 0

      # If start date is not Sun then padd beginning of calendar.
      if firstDateDay isnt 0
        prevMonth = startOfMonth.clone()

        for i in [0..firstDateDay-1]
          if (index++) is 0
            html.push '<tr class="wdp-calendar-row">'
          d = prevMonth.add('days', -1).date()
          formattedPrevMonth = @_formatDate new Date(@_state.year, @_state.month - 1, d)
          # + 1 because element at index zero is the <tr>
          html[6 - i + 1] = "<td class=\"wdp-calendar-othermonth js-wdp-calendar-cell\" data-date=\"#{formattedPrevMonth}\">#{d}</td>"
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

      # Fill out the rest of the calendar (six rows).
      nextMonth = endOfMonth.clone()
      while index < 42  # 7 * 6 = 42
        d = nextMonth.add('days', 1).date()
        formattedNextMonth = @_formatDate new Date(@_state.year, @_state.month + 1, d)
        if (index++) % 7 is 0
          html.push '</tr><tr class="wdp-calendar-row">'
        html.push "<td class=\"wdp-calendar-othermonth js-wdp-calendar-cell\" data-date=\"#{formattedNextMonth}\">#{d}</td>"

      html.push '</tr>'

      @$tbody.html html.join ''

    _cancelEvent: (e) =>
      e.stopPropagation()
      e.preventDefault()

    _onInputKeydown: (e) =>
      # Prevent overriding meta key behaviour in browser.
      if e.metaKey
        return

      switch e.keyCode
        when WDP.Keys.DOWN, WDP.Keys.J
          @_cancelEvent e
          fn = @shortcuts.selectNext
          offset = 7

          @show()

        when WDP.Keys.RETURN
          @show()

        when WDP.Keys.UP, WDP.Keys.K
          @_cancelEvent e
          fn = @shortcuts.selectPrev
          offset = -7

        when WDP.Keys.LEFT, WDP.Keys.H
          @_cancelEvent e
          offset = -1

        when WDP.Keys.RIGHT, WDP.Keys.L
          @_cancelEvent e
          offset = 1

        when WDP.Keys.ESC, WDP.Keys.TAB
          @hide()

      if e.shiftKey
        fn?()
      else if offset?
        date = new Date(@date.getFullYear(), @date.getMonth(), @date.getDate() + offset)
        @shortcuts.resetClass()  # Clear ay selected shortcuts
        @setDate date

    _updateSelection: ->
      # Update selection
      dateStr = @_formatDate @date
      @$tbody.find('.wdp-selected').removeClass('wdp-selected')
      @$tbody.find("td[data-date=#{dateStr}]").addClass('wdp-selected')

    _selectDate: (e) =>
      @shortcuts.resetClass()
      date = @_parseDate $(e.target).data('date')
      @$el.trigger 'shortcutclear'
      @setDate date

      if @options.hideOnSelect
        @hide()


  # Hold reference to old function in case it exists
  _oldDatepicker = $.fn.datepicker
    
  # Init function for jQuery widget
  WDP.init = (options = {}, args...) ->
    # Calling a method on widget.
    # Prevent methods beginning with _ to be called because they are private
    if typeof options is 'string' and options[0] isnt '_' and options isnt 'render'
      widget = $(this).data('datepicker')
      return widget?[options].apply widget, args

    @each ->
      $this = $ this
      widget = $this.data('datepicker')
      $.extend options, {el: this}

      unless widget
        $this.data 'datepicker', (widget = new WDP.WaveDatepicker(options).render())

  # Add jQuery widget
  $.fn.datepicker = WDP.init

  # Restore function to support previous datepicker
  WDP.noConflict = -> $.fn.datepicker = _oldDatepicker


  return WDP
)
