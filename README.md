"What's new in iOS 7" Presentation
==================================

This repository contains an Xcode 5 project for iOS 7, showcasing the
major changes and new APIs in iOS 7.

Functionality
-------------

- Every screen is a subclass of `TRIBaseScreenController` and displays a
  screenful of information with a particular sample or demo.
- The configuration of the presentation is stored in the file
  `Resources/Data/ScreenDefinitions.json.`
- Presenters can showcase every demo and share the source code with the
  audience. The source code is stored inside of the application bundle,
  as a series of HTML files that are generated at compile time.
- The application generates a takeaway PDF that includes the source code
  of the example screens as required, in the same order of the screens.
- The PDF can be shared using e-mail, iMessage, via AirDrop or using a
  dedicated app that handles PDF.

iPhone Application
------------------

The project is an universal app, and the iPhone app can be used to drive
the iPad back and forward from screen to screen. To do this, launch both
apps in the iPhone and the iPad and get them close to each other for a
couple of seconds. The list of slides will be transmitted from the iPad
to the iPhone automatically.

Requirements
------------

This project contains a "Run Script" build phase, which requires the
`Pygments` Python library installed locally. This can be done by issuing
`sudo easy_install Pygments` at the command line.

