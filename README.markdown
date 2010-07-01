#  Gowalla-Basic
## A simple example iPhone App using the Gowalla API

We created this example application as a resource to help you get up to speed with the Gowalla API on the iPhone. The app implements a basic feature set, including an authentication flow using OAuth.

As you might expect, the Core Location and MapKit frameworks are central to the functionality of the app. If you are just getting started with location programming on the iPhone, you might want to check out Apple's [Core Location Framework Reference](http://developer.apple.com/iphone/library/documentation/CoreLocation/Reference/CoreLocation_Framework/index.html) and [MapKit Framework Reference Guide](http://developer.apple.com/iphone/library/documentation/MapKit/Reference/MapKit_Framework_Reference/index.html) before diving in.

## Requirements

Gowalla-Basic uses iOS4 as its Base SDK, which is available to ADC Members at [http://developer.apple.com/iphone/](http://developer.apple.com/iphone/). If you are developing for the iPad, or targeting a previous version of iOS, you may need to make some changes before adopting this code into your project.

## Creating Your Own Application

Gowalla-Basic comes working out-of-the-box with its own API key, secret, and callback. You can configure everything for your application with the following steps:

- Create an application at [http://api.gowalla.com/api/keys](http://api.gowalla.com/api/keys), by clicking "Add Application"
- Fill out the form accordingly.
  For <u>Callback URL</u> you will most likely want to use a custom URL scheme. This should be something unique, for example a dasherized version of your application's name (ie. my-app://callback). 
    
    **Note**: Do not use gowalla://, as this is already reserved by Gowalla for iPhone and iPad, and will cause conflicts.
- Once you've submitted your form and gotten your API credentials, open up <tt>GowallaAPIKeys.h</tt>. Replace all of the API constants with your own values.
- Next, open up <tt>Info.plist</tt>. Under "URL types > Item 0" change the identifier and scheme to match your callback URI.
- All done! If there's an existing copy of the app in the simulator, you should delete it to reset your application credentials.

## Libraries

In the spirit of not re-inventing the wheel, this project includes several external libraries for things like HTTP requests and JSON parsing. Of course, you're more than welcome to adapt this example to use your libraries of choice.

* **[EGOHTTPRequest](http://github.com/enormego/EGOHTTPRequest)** - Useful wrapper around NSURLConnection that adds many essential methods. API Requests are mediated with EGOHTTPRequest.

* **[EGOImageLoading](http://github.com/enormego/EGOImageLoading)** - "What if images on the iPhone were as easy as HTML?" Used for image loading and caching in TableViewCells and  UIViews.

* **[TouchJSON](http://code.google.com/p/touchcode/wiki/TouchJSON)** - Parser and generator for JSON implemented in Objective C. TouchJSON is used to convert JSON into NSDictionaries.

## License

Gowalla-Basic is licensed under the MIT License:

Copyright (c) 2010 Gowalla, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## Credits

Created by [Mattt Thompson](http://mattt.me). Please contact me at [mattt@gowalla.com](mailto://mattt@gowalla.com) with any problems, questions, or feature requests. Or, for more general developer questions, [check out our mailing list](http://groups.google.com/group/gowalla-dev).