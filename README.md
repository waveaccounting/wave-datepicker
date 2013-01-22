Datepicker widget for jQuery that uses Bootstrap styles.

Supports shortcuts on the left-side of the picker.

**Latest Version**: 0.2.2


## Getting Started

**Dependencies:**

* [jQuery](http://jquery.com/) (1.7+)
* [moment.js](http://momentjs.com/)
* [Bootstrap CSS](http://twitter.github.com/bootstrap/)


**Including on website:**

You can either use `dist/wave-datepicker.js` or the minified version `dist/wave-datepicker.min.js`.

You will also need the stylesheet `dist/wave-datepicker.css`.


## Usage:

**Basic usage:**

    // Given an existing <input id="MyInput"/> element.
    $('#MyInput').datepicker();

    // May also pass in an options object.
    $('#MyInput').datepicker(options);


### Options:

* hideOnSelect - If `true` then date selection will automatically hide the datepicker. Default is `false`



### Methods:

Methods are called via the `.datepicker(method, args...)` function.

* **.datepicker('setDate', date)**

  Updates the widget's selected date to the `Date` object.

* **.datepicker('getDate')**

  Returns the current `Date` object of the widget.

* **.datepicker('destroy')**
  
  Destroys the widget, removing any created elements and events from DOM.


### Events:

* **datechange**

  Notifies of any date changes on the widget. Passes the `Date` object
  as the first argument.


### Examples:

**Basic usage:**

    $('#MyInput').datepicker('setDate', new Date());


**Custom shortcuts:**

    $('#MyInput').datepicker({
      shortcuts: {
        'Today': {
          days: 0
        },
        'In 15 days': {
          days: 15
        },
        'In 30 days': {
          days: 30
        },
        'In 60 days': {
          days: 60
        },
        'In 90 days': {
          days: 90
        }
      }
    });

The offset key can be anything supported in the [add function of moment.js](http://momentjs.com/docs/#/manipulating/add/).

e.g. `years`, `months`, `days`


**Listening on datechange events:**

    $('#MyInput').on('datechange', function (e, date) {
      console.log(date);
    });


**Destroying widget:**

    $('#MyInput').datepicker('destroy');


## Keyboard navigation:

Keyboard shortcuts can be used when focus in on the `<input>` element.

The `Up`, `Down`, `Left`, `Right` keys will navigate the seleted date in the calendar. (HJKL Vim bindings are supported as well!)

When the `Shift` key is held down, then the `Up` and `Down` keys will navigate the shortcuts instead of the calendar.


## Development

**Installing dependencies:**

    npm install
    

**Building file:**

Run the local `grunt` binary.

    ./node_modules/grunt/bin/grunt

If you have grunt installed globally via the `npm install -g` switch, simply run `grunt`.

This will generate the `dist/wave-datepicker.js` file that can be included on the page via `<script>` node or AMD.


**Testing:**

Run the `test` task:

    ./node_modules/grunt/bin/grunt test


##Changelog

**0.2.2:**

- Added `allowClear` option to allow user to unset the date

**0.2.1:**

- Fixed issues with keyboard navigation when using `{hideOnSelect: true}`

**0.2.0:**

- Added support for `.add-on` icon to show/hide the datepicker
