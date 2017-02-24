# fit-sdk-with-swift
####Back Story
The [FLEXIBLE AND INTEROPERABLE DATA TRANSFER (FIT) PROTOCOL SDK](https://www.thisisant.com/resources/fit/) is a binary encoded data format used in the world of embedded fitness and activity-related sensors and associated client and service software. It's basically what an activity sensor like a running or cycling computer might use, or a fancy fitness scale or other exercise gear. The format is interoperable, meaning that a plurality of clients or services can use it without knowing anything about the client or service that may have generated the data. At the same time, the SDK embeds information about specific clients or services, such as manufacturer, device serial number and so forth.

The most useful aspect of the SDK is the ability to encode and decode in the FIT binary format. This makes it possible to consume FIT data from devices or services, or generate FIT data from, for example, a device.

The SDK has examples and static libraries for a variety of languages, including C, C++, Objective-C, Objective-C++, C# and jars for Java.

But — I needed it to work with Swift, which was my language of choice for a from-the-ground iOS app.

####So..now what?
Most resources explain that interoperability is possible between Swift and C, C++, Objective-C and Objective-C++ (cf: [How To Call Objective-C Code From Swift](http://stackoverflow.com/questions/24002369/how-to-call-objective-c-code-from-swift) and [Can I Have Swift Obj-C and C Files In The Same XCode Project](http://stackoverflow.com/questions/32541268/can-i-have-swift-objective-c-c-and-c-files-in-the-same-xcode-project/32546879#32546879), but I had a bit of a struggle trying to figure out how to get the static library for this SDK to build such that Swift source could call methods in the SDK (cf: [Building Swift and Objective-C and a Static C++ Library Together](http://stackoverflow.com/questions/42383838/building-swift-objective-c-and-a-static-c-library-together)). I mostly ended up with a plaintive linker error complaining that some class in the standard c++ library (`libstdc++`) like `<string>` or `<vector>` or `<map>` couldn't be found. Which isn't the best clue. Ultimately, after puzzling this through with some folks who were very generous with their time, I came to the conclusion that, actually, the linker error is indicating that the C++ from those libraries were just completely alien to Swift. In fact, those classes from the standard library that were breaking things have their own native forms in Foundation — String, Array and Dictionary.

Getting the [FIT SDK](https://www.thisisant.com/resources/fit/) to work with Swift was a bit of a bear. There's currently no native Swift code in the SDK, so the project became finding out how Swift can interoperate so that I can call API methods in the SDK from Swift source. 

This repository has a rudimentary example of getting Swift to play with the C++ SDK.

####Configuration
You will need the FIT SDK itself to build this project, particularly the headers found under the FIT SDK Root, i.e. 

`FitSDKRelease_20.xx.01/cpp/MacStaticLib/build/ReleaseiOS-universal/usr/local/include`

In Xcode, under Target Build Settings, you'll want to make sure that your Header Search Path is set to point to the necessary headers found in the above directory.
