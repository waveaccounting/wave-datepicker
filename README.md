Datepicker widget built using Backbone.

## Installing dependencies:

    npm install

## Building file:

    grunt

This will generate the `dist/wave-datepicker.js` file that can be included on the page via `<script>` node or AMD.

## Usage (CoffeeScript):

    # Given an existing <input id="MyInput"/> element.
    datepicker = new DatePicker(el: $('#MyInput'))
