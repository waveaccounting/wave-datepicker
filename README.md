Datepicker widget for jQuery that uses Bootstrap styles.

Supports shortcuts on the left-side of the picker.


## Getting Started

**Installing dependencies:**

    npm install


**Building file:**

Run the local `grunt` binary.

    ./node_modules/grunt/bin/grunt

If you have grunt installed globally via the `npm install -g` switch, simply run `grunt`.

This will generate the `dist/wave-datepicker.js` file that can be included on the page via `<script>` node or AMD.


**Testing:**

Run the `test` task:

    grunt test


## Usage:

**Basic usage:**

    // Given an existing <input id="MyInput"/> element.
    $('#MyInput').datepicker();



### Methods:

Methods are called via the `.datepicker(method, args...)` function.

**.datepicker('setDate', date)**

Updates the widget's selected date to the `Date` object.

Example:

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


**Destroying widget:**

    $('#MyInput').datepicker('destroy');
