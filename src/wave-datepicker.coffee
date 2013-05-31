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
    <div class=\"wdp-shortcuts span5\"></div>
    <div class=\"wdp-main\">
      <table class=\"table-condensed wdp-calendar\">
        <thead>
          <tr>
              <th class=\"wdp-prev\">
                <a href=\"javascript:void(0)\" class=\"js-wdp-prev\">◀</a>
              </th>
              <th colspan=\"5\" class=\"wdp-month-and-year js-wdp-set-month-year\"></th>
              <th class=\"wdp-next\">
                <a href=\"javascript:void(0)\" class=\"js-wdp-next\">▶</a>
              </th>
          </tr>
        </thead>
        <tbody></tbody>
      </table>
      <table class=\"table-condensed wdp-year-calendar\">
      <tbody></tbody>
      </table>
      <table class=\"table-condensed wdp-month-calendar\">
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

  WDP.defaultOptions =
    hideOnSelect: true

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

      # Only set if string was valid
      if wrapper.isValid()
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

      @options = $.extend {}, WDP.defaultOptions, options

      @_state = {}

      @setOptionsFromDataAttr()

      @normalizeOptions()

      @_updateFromInput(null, null, {update: not @options.allowClear})

      @_initPicker()
      @_initElements()
      @_initEvents()

      @baseDate = @options.baseDate or new Date()

      # Check if we want to show shortcuts or not.
      if options.shortcuts?
        if typeof options.shortcuts is 'object'
          shortcutOptions = options.shortcuts
        # If option pass is just `true` then we should the default shortcuts.
        else shortcutOptions = null

        # e.g. 'today' -> sets calendar value to today's date
        @shortcuts = new WDP.Shortcuts(shortcutOptions).render()
        @$shortcuts.append @shortcuts.$el
        # Setting date clears any selected shortcuts
        @shortcuts?.resetClass()
        @shortcuts.baseDate = @baseDate


        # Setting date clears any selected shortcuts
        @shortcuts?.resetClass()

        @$shortcuts.on 'dateselect', (e, date) => @setDate(date)

      # Keep track of this instance
      WDP.datepickers.push this

    setOptionsFromDataAttr: ->
      @$el.data()

      # For each 'data-date-*' attribute, set it on our option.
      for k, v of @$el.data()
        if k.substr(0, 4) is 'date'
          @options[k] = v

    normalizeOptions: ->
      @options.dateFormat or= @_defaultFormat

      @options.allowClear or= @options.dateAllowClear
      @options.allowClear = @options.allowClear in ['yes', 'true', true] 

      if @options.dateMin and not(@options.dateMin instanceof Date)
        @options.dateMin = @_parseDate @options.dateMin

      if @options.dateMax and not(@options.dateMax instanceof Date)
        @options.dateMax = @_parseDate @options.dateMax

    render: =>
      @_updateMonthAndYear()
      @_fill()

      @_updateSelection() if @date

      if @shortcuts?
        @$datepicker.addClass('wdp-has-shortcuts')
        @$datepicker.find('.wdp-main').addClass('span7').removeClass('span12')
        @$shortcuts.insertBefore @$main
      else
        @$datepicker.removeClass('wdp-has-shortcuts')
        @$datepicker.find('.wdp-main').addClass('span12').removeClass('span7')
        @$shortcuts.detach()

      return this

    _isShown: false

    hideInactive: ->
      picker.hide() for picker in WDP.datepickers when picker isnt WDP.activeDatepicker

    # Shows the widget if not shown already.
    show: =>
      unless @_isShown or @$el.is(':not(:visible)')
        # Mark current picker as the active one.
        # Hide all others.
        WDP.activeDatepicker = this
        @hideInactive()

        @_isShown = true
        @$calendar.show()
        @$datepicker.addClass 'show'
        @height = @$el.outerHeight()
        @_place()
        @$window.on 'resize', @_place
        @$document.on 'click', @hide

    # Hides the widget if it is shown.
    hide: =>
      if @_isShown
        @_isShown = false
        @$calendarYear.hide()
        @$calendarMonth.hide()
        @$datepicker.removeClass 'show'
        @$window.off 'resize', @_place
        @$document.off 'click', @hide

    toggle: =>
      if @_isShown
        @hide()
      else
        @show()

    # Sets the Date object for this widget and update `<input>` field.
    setDate: (date, options) =>
      # If we're setting a string, then parse it first.
      if typeof date is 'string'
        date = WDP.DateUtils.parse date

      # Cannot set non-dates
      unless date instanceof Date
        if @options.allowClear
          today = new Date()
          @_state.month = today.getMonth()
          @_state.year = today.getFullYear()
        return

      # Should not set a date that falls outside of min/max range.
      unless @_dateWithinRange(date)
        return

      @date = date
      @_state.month = @date.getMonth()
      @_state.year = @date.getFullYear()

      unless options?.update is false
        @$el.val @_formatDate(date)

      unless options?.silent is true
        @$el.trigger 'change', [@date, $.extend({silent: true}, options)]

      if @options.hideOnSelect and (options?.hide or options?.hide is undefined)
        @hide()

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
      @baseDate = @shortcuts?.baseDate = date

    getBaseDate: -> @baseDate

    _initElements: ->
      if @options.className
        @$el.addClass(@options.className)

      # Set up elements cache
      @$shortcuts = @$datepicker.find '.wdp-shortcuts'
      @$main = @$datepicker.find '.wdp-main'
      @$calendar = @$main.find '.wdp-calendar'
      @$calendarTbody = @$calendar.find 'tbody'
      @$calendarYear = @$datepicker.find '.wdp-year-calendar'
      @$calendarYearTbody = @$calendarYear.find 'tbody'
      @$calendarMonth = @$datepicker.find '.wdp-month-calendar'
      @$calendarMonthTbody = @$calendarMonth.find 'tbody'
      @$monthAndYear = @$calendar.find '.wdp-month-and-year'
      @$window = $ window
      @$document = $ document

    # Renders the widget and append to the `<body>`
    _initPicker: ->
      @$datepicker = $ WDP.template
      @$datepicker.appendTo document.body

      # Support for older moment.js versions.
      weekdaysMin = moment.weekdaysMin or moment.langData()._weekdaysMin
      weekdays = weekdaysMin.join '</th><th>'

      @$datepicker.find('thead').append "<tr class=\"wdp-weekdays\"><th>#{weekdays}</th></tr>"

    _initEvents: ->

      # Show picker...
      #
      # If this input has an add-on icon attached to it, then we want to trigger show only when
      # the icon is clicked on. The `<input>` box is also focused when icon is clicked.
      if (@$icon = @$el.siblings('.add-on')).length
        showAndFocus = (e) =>
          @_cancelEvent e
          if @_isShown
            @$el.focus()
          @toggle()

        @$icon.on 'click', showAndFocus

      # Otherwise we just show datepicker when `<input>` is focused.
      else
        # Also show on click (it might be hidden but focused).
        @$el.on 'focus click mousedown', @show

      # Hide picker
      @$el.on 'blur', @hide

      @$el.on 'change', @_updateFromInput
      @$el.on 'change', @render
      @$el.on 'keydown', @_onInputKeydown

      # Cancel all click events so we don't hide the picker unnecessarily.
      @$el.on 'click', @_cancelEvent

      @$datepicker.on 'click', '.js-wdp-calendar-cell:not(.wdp-disabled)', @_selectDate
      @$datepicker.on 'click', '.js-wdp-prev', @prev
      @$datepicker.on 'click', '.js-wdp-next', @next
      @$datepicker.on 'click', @_cancelEvent
      @$datepicker.on 'click', '.js-wdp-set-month-year', @_showYearGrid
      @$datepicker.on 'click', '.js-wdp-year-calendar-cell', @_showMonthGrid
      @$datepicker.on 'mousedown', @_cancelEvent

    _updateFromInput: (e, date, options) =>
      # Reads the value of the `<input>` field and set it as the date.
      if (dateStr = @$el.val())
        @date = @_parseDate dateStr

      # If date could not be set from @$el.val() then set to today.
      if @options.allowClear
        unless dateStr
          @date = null
      else
        @date or= new Date()

      # In case other options were passed down.
      options = $.extend {silent: true}, options

      @setDate @date, options

    # Updates the picker with the current date.
    _updateMonthAndYear: =>
      date = new Date(@_state.year, @_state.month, 1)
      monthAndYear = moment(date).format('MMMM YYYY')
      @$monthAndYear.text monthAndYear

    _formatDate: (date) -> WDP.DateUtils.format(date, @options.dateFormat)

    _parseDate: (str) ->
      # If the string is formatted properly, return its date value.
      if (wrapped = WDP.DateUtils.parse(str, @options.dateFormat)).isValid()
        d = wrapped.toDate()

        # If the year is zero then it is invalid. This can happen if the dateFormat does
        # not include the year. e.g. "MM-DD"
        if d.getFullYear() is 0
          # Set to current year
          d.setFullYear(new Date().getFullYear())

        return d

      # Otherwise return current date
      return @date

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

    _showYearGrid: =>
      html = []

      m = moment(new Date(@_state.year - 9, 0, 1))
      html.push '<tr class="wdp-calendar-row">'
      for i in [1..20]
        currentClass = if m.year() is @_state.year then 'wdp-selected' else ''
        html.push "<td class=\"js-wdp-year-calendar-cell #{currentClass}\" data-date=\"#{m.format("YYYY-MM-DD")}\">#{m.format("YYYY")}</td>"

        if i % 5 is 0
          html.push '</tr>'
          if i isnt 20
            html.push '<tr class"wdp-calendar-row">'

        m.add 'years', 1

      @$calendarYearTbody.html html.join ''
      @$calendar.hide()
      @$calendarYear.show()

    _showMonthGrid: (e) =>
      html = []
      date = moment(@_parseDate $(e.target).data('date'))

      m = moment(new Date(date.year(), 0, 1))
      html.push '<tr class="wdp-calendar-row">'
      for i in [1..12]
        currentClass = if m.month() is @_state.month then 'wdp-selected' else ''
        html.push "<td class=\"js-wdp-calendar-cell #{currentClass}\" data-date=\"#{m.format("YYYY-MM-DD")}\">#{m.format("MMM")}</td>"

        if i % 3 is 0
          html.push '</tr>'
          if i isnt 12
            html.push '<tr class="wdp-calendar-row">'

        m.add 'months', 1

      @$calendarMonthTbody.html html.join ''

      @$calendarYear.hide()
      @$calendarMonth.show()

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
          currDate = new Date(@_state.year, @_state.month - 1, d)
          formattedPrevMonth = @_formatDate currDate
          # + 1 because element at index zero is the <tr>
          html[6 - i + 1] = "<td class=\"wdp-calendar-othermonth js-wdp-calendar-cell #{@_getExtraClassNamesForDate(currDate)}\" data-date=\"#{formattedPrevMonth}\">#{d}</td>"
          paddingStart++

      # For formatting purposes in the following loop.
      currDate = new Date(@_state.year, @_state.month, 1)

      # Fill in dates for this month.
      for i in [1..daysInMonth]
        currDate.setDate(i)
        formatted = @_formatDate currDate
        if (index++) % 7 is 0
          html.push '</tr><tr class="wdp-calendar-row">'
        html.push "<td class=\"js-wdp-calendar-cell #{@_getExtraClassNamesForDate(currDate)}\" data-date=\"#{formatted}\">#{i}</td>"

      # Fill out the rest of the calendar (six rows).
      nextMonth = endOfMonth.clone()
      while index < 42  # 7 * 6 = 42
        d = nextMonth.add('days', 1).date()
        currDate = new Date(@_state.year, @_state.month + 1, d)
        formattedNextMonth = @_formatDate currDate
        if (index++) % 7 is 0
          html.push '</tr><tr class="wdp-calendar-row">'
        html.push "<td class=\"wdp-calendar-othermonth js-wdp-calendar-cell #{@_getExtraClassNamesForDate(currDate)}\" data-date=\"#{formattedNextMonth}\">#{d}</td>"

      html.push '</tr>'

      @$calendarYear.hide()
      @$calendarMonth.hide()
      @$calendarTbody.html html.join ''
      @$calendar.show()

    _cancelEvent: (e) =>
      e.stopPropagation()
      e.preventDefault()

    _onInputKeydown: (e) =>
      # Prevent overriding meta key behaviour in browser.
      if e.metaKey
        return

      switch e.keyCode
        when WDP.Keys.DOWN, WDP.Keys.J
          if @_isShown
            @_cancelEvent e
            fn = @shortcuts?.selectNext
            offset = 7

          @show()

        when WDP.Keys.RETURN
          if @_isShown
            @hide()
          else
            @show()

        when WDP.Keys.UP, WDP.Keys.K
          if @_isShown
            @_cancelEvent e
            fn = @shortcuts?.selectPrev
            offset = -7

        when WDP.Keys.LEFT, WDP.Keys.H
          if @_isShown
            @_cancelEvent e
            offset = -1

        when WDP.Keys.RIGHT, WDP.Keys.L
          if @_isShown
            @_cancelEvent e
            offset = 1

        when WDP.Keys.ESC, WDP.Keys.TAB
          @hide()

      if e.shiftKey
        fn?()
      else if offset?
        date = new Date(@date.getFullYear(), @date.getMonth(), @date.getDate() + offset)
        @shortcuts?.resetClass()  # Clear any selected shortcuts
        @setDate date, {hide: false}

    _updateSelection: ->
      # Update selection
      dateStr = @_formatDate @date
      @$calendarTbody.find('.wdp-selected').removeClass('wdp-selected')
      @$calendarTbody.find("td[data-date='#{dateStr}']").addClass('wdp-selected')

    _selectDate: (e) =>
      @$calendarMonth.hide()
      @$calendar.show()
      @shortcuts?.resetClass()
      date = @_parseDate $(e.target).data('date')
      @$el.trigger 'shortcutclear'
      @setDate date

    _dateWithinRange: (date) =>
      if @options.dateMin and date.valueOf() < @options.dateMin.valueOf()
        return false

      if @options.dateMax and date.valueOf() > @options.dateMax.valueOf()
        return false

      return true

    _getExtraClassNamesForDate: (date) =>
      classNames = []

      classNames.push('wdp-disabled') unless @_dateWithinRange(date)

      return classNames.join(' ')

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
