<p align="center">
  <img src="Assets/banner.png" width="780" title="DLLocalNotifications">
</p>


[![Swift Version][swift-image]][swift-url]
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/DLLocalNotifications.svg)][podLink]
![Platform](https://img.shields.io/badge/platforms-iOS%2010.0+-333333.svg)
[![License][license-image]][license-url]

Since IOS 10, apple updated their library for Notifications and separated Local and push notifications to a new framework: 

[User Notifications](https://developer.apple.com/reference/usernotifications)

This library makes it easy to setup a local notification and also includes easy configuration for repeating notifications using [ .None, .Minute, .Hourly, .Daily, .Monthly, .Yearly] .

It also includes all the new features, including inserting images into a notification.


## Features

- [x] Easily Repeat Notifications
- [ ] Category Actions

## Requirements

- iOS 10.0+
- Xcode 8.0+

## Installation

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `DLLocalNotifications` by adding it to your `Podfile`:

```ruby
platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
	pod 'DLLocalNotifications'
end
```
Note: your iOS deployment target must be 10.0+

To get the full benefits import `YourLibrary` wherever you import UIKit

``` swift
import UIKit
import DLLocalNotifications
```

#### Manually
1. Download and drop ```DLLocalNotifications.swift``` in your project.  
2. Congratulations!  

## Usage example

```swift
import DLLocalNotifications

let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notificaiton Alert", alertBody: "You have successfully created a notification", date: Date(), repeats: .Minute)

let scheduler = DLNotificationScheduler()
scheduler.scheduleNotification(notification: firstNotification)
```

## Contribute

We would love for you to contribute to **DLLocalNotifications**, check the ``LICENSE`` file for more info.

## Meta

Devesh Laungani – [@d7laungani](https://twitter.com/d7laungani)

Distributed under the MIT license. See ``LICENSE`` for more information

[https://github.com/d7laungani/](https://github.com/d7laungani/)

[swift-image]:https://img.shields.io/badge/swift-3.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[podLink]:https://cocoapods.org/pods/DLLocalNotifications
