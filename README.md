Datepicker widget built using Backbone.

## Installing dependencies:

    npm install

## Building file:

Run the local `grunt` binary.

    ./node_modules/grunt/bin/grunt

If you have grunt installed globally via the `npm install -g` switch, simply run `grunt`.

This will generate the `dist/wave-datepicker.js` file that can be included on the page via `<script>` node or AMD.

## Usage:

    // Given an existing <input id="MyInput"/> element.
    $('#MyInput').datepicker();
