Datepicker widget for jQuery that uses Bootstrap styles.

Supports shortcuts on the left-side of the picker.


## Getting Started

**Installing dependencies:**

    npm install
    
**Dependencies:**

* [jQuery](http://jquery.com/) (1.7+)
* [moment.js](http://momentjs.com/)
* [Bootstrap CSS](http://twitter.github.com/bootstrap/)


**Building file:**

Run the local `grunt` binary.

    ./node_modules/grunt/bin/grunt

If you have grunt installed globally via the `npm install -g` switch, simply run `grunt`.

This will generate the `dist/wave-datepicker.js` file that can be included on the page via `<script>` node or AMD.


**Testing:**

Run the `test` task:

    ./node_modules/grunt/bin/grunt test


## Usage:

**Basic usage:**

    // Given an existing <input id="MyInput"/> element.
    $('#MyInput').datepicker();



### Methods:

Methods are called via the `.datepicker(method, args...)` function.

**.datepicker('setDate', date)**

Updates the widget's selected date to the `Date` object.

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


**Destroying widget:**

    $('#MyInput').datepicker('destroy');


## Keyboard navigation:

Keyboard shortcuts can be used when focus in on the `<input>` element.

The `Up`, `Down`, `Left`, `Right` keys will navigate the seleted date in the calendar. (HJKL Vim bindings are supported as well!)

When the `Shift` key is held down, then the `Up` and `Down` keys will navigate the shortcuts instead of the calendar.
