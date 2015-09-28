# Code has been moved. This version here is not maintained anymore.

## ProxMate for Chrome
[![Built Status](Status](https://travis-ci.org/dabido/proxmate-chrome.png "Build Status")](https://travis-ci.org/dabido/ProxMate-chrome/)

Extension store version here - https://chrome.google.com/webstore/detail/proxmate/ifalmiidchkjjmkkbkoaibpmoeichmki

## Building

ProxMate is using grunt for building. To build a dist file (completely minified through googles clojurecompiler, cssmin and htmlmin) run `grunt build`.

Development and live reloading is available through `grunt serve`.

To build a non-minified version, run `grunt src`. 


## Contributing

Contributions have to be unit tested and should not break existing functionality (`grunt test`). 
