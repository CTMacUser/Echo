# echo

I made this app to try out `URLSessionStreamTask` (or `NSURLSessionStreamTask` for Objective-C users) since I didn't see it used anywhere, except for [one bug demonstration on GitHub](https://github.com/belkevich/stream-task).

The echo protocol is defined in [RFC 862](https://www.rfc-editor.org/info/rfc862), but first proposed in [RFC 347](https://www.rfc-editor.org/info/rfc347).  Since the app is a demonstration of `URLSessionStreamTask`, it only does the TCP version.

The app opens a single window.  Put a hostname or IP address in the first text field.  Put a port number, or leave it at the default of 7, in the second field.  Press "Connect" when ready.  Then you may send (text) data by filling in the bottom text field and pressing "Echo."  Below that text field is the status, including whether the returned data matches the sent data.  Errors encountered will display as sheets on the primary window.
