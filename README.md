<p align="center">
  <img src="Assets/banner.png" width="780" title="DLLocalNotifications">
</p>


[![Swift Version][swift-image]][swift-url]
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/DLLocalNotifications.svg)][podLink]
![Platform](https://img.shields.io/badge/platforms-iOS%2010.0+-333333.svg)
[![Build Status](https://travis-ci.org/d7laungani/DLLocalNotifications.svg?branch=master)](https://travis-ci.org/d7laungani/DLLocalNotifications)
[![License][license-image]][license-url]

In IOS 10, apple updated their library for Notifications and separated Local and push notifications to a new framework: 

[User Notifications](https://developer.apple.com/reference/usernotifications)

This library makes it easy to setup a local notification and also includes easy configuration for repeating notifications using [ .None, .Minute, .Hourly, .Daily, .Monthly, .Yearly] .

It also includes all the new features, including inserting attachments and changing the launch image of a notification.


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

## Usage 

### Single fire notification

```swift

// The date you would like the notification to fire at
let triggerDate = Date().addingTimeInterval(300)

let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notificaiton Alert", alertBody: "You have successfully created a notification", date: triggerDate, repeats: .None)

let scheduler = DLNotificationScheduler()
scheduler.scheduleNotification(notification: firstNotification)
```

### Repeating Notification starting at a Date

The configuration of the repetition is chosen in the repeats parameter that can be [ .None, .Minute, .Hourly, .Daily, .Monthly, .Yearly] .

```swift

let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notificaiton Alert", alertBody: "You have successfully created a notification", date: Date(), repeats: .Minute)

let scheduler = DLNotificationScheduler()
scheduler.scheduleNotification(notification: firstNotification)
```

### Notification that repeats from one Date to another with a time interval period

This is useful to setup notifications to repeat every specific time interval for in a specific time period of the day.

```swift

let scheduler = DLNotificationScheduler()
scheduler.cancelAlllNotifications()
 
// This notification repeats every 15 seconds from a time period starting from 15 seconds from the current time till 5 minutes from the current time

scheduler.repeatsFromToDate(identifier: "First Notification", alertTitle: "Multiple Notifcations", alertBody: "Progress", fromDate: Date().addingTimeInterval(15), toDate: Date().addingTimeInterval(300) , interval: 15 )

```

Note: You have to keep into consideration the apple 64 notification limit. This function does not take that into consideration.

### Mofiying elements of the notification

You can modify elements of the notification before categorizing. Publically accessible variables include:

repeatInterval
alertBody
alertTitle
soundName
fireDate
attachments
launchImageName
category

For instance if you want to add a launch image name you can do that by:

```swift

let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notificaiton Alert", alertBody: "You have successfully created a notification", date: Date(), repeats: .Minute)

// You can now change the repeat interval here
firstNotification.repeatInterval = .Yearly

// You can add a launch image name
firstNotification.launchImageName = "Hello.png"

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
