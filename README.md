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

1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation](#installation)
    - [CocoaPods](#cocoapods)
    - [Manually](#manually)
4. [Usage](#usage)
    - [Single Fire Notification](#single-fire-notification)
    - [Repeating Notification starting at a Date](#repeating-notification-starting-at-a-date)
    - [Notification that repeats from one Date to another with a time interval period](#notification-that-repeats-from-one-date-to-another-with-a-time-interval-period)
    - [Modifying elements of the notification](#modifying-elements-of-the-notification)
    - [Location Based Notification](#location-based-notification)
    - [Action Buttons](#adding-action-buttons-to-a-notification)
5. [Contribute](#contribute)

## Features

- [x] Easily Repeat Notifications
- [x] Location Based Notifications
- [x] Category Action buttons
- [ ] Queue to enforce 64 notification limit

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

#### Manually
1. Download and drop ```DLLocalNotifications.swift``` in your project.  
2. Congratulations!  

## Usage 

### Single fire notification

Notification that repeats from one Date to another with a time interval period

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

// This notification repeats every 15 seconds from a time period starting from 15 seconds from the current time till 5 minutes from the current time

scheduler.repeatsFromToDate(identifier: "First Notification", alertTitle: "Multiple Notifcations", alertBody: "Progress", fromDate: Date().addingTimeInterval(15), toDate: Date().addingTimeInterval(300) , interval: 15, repeats: .None )

```

Note: You have to keep into consideration the apple 64 notification limit. This function does not take that into consideration.

### Modifying elements of the notification

You can modify elements of the notification before scheduling. Publically accessible variables include:

repeatInterval, alertBody, alertTitle, soundName, fireDate, attachments, launchImageName, category

```swift

let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notificaiton Alert", alertBody: "You have successfully created a notification", date: Date(), repeats: .Minute)

// You can now change the repeat interval here
firstNotification.repeatInterval = .Yearly

// You can add a launch image name
firstNotification.launchImageName = "Hello.png"

let scheduler = DLNotificationScheduler()
scheduler.scheduleNotification(notification: firstNotification)
```
### Location Based Notification

The notification is triggered when a user enters a geo-fenced area.

```swift

let center = CLLocationCoordinate2D(latitude: 37.335400, longitude: -122.009201)
let region = CLCircularRegion(center: center, radius: 2000.0, identifier: "Headquarters")
region.notifyOnEntry = true
region.notifyOnExit = false

let locationNotification = DLNotification(identifier: "LocationNotification", alertTitle: "Notificaiton Alert", alertBody: "You have reached work", region: region )

let scheduler = DLNotificationScheduler()
scheduler.scheduleNotification(notification: locationNotification)
```

### Adding action buttons to a notification

```swift

 let scheduler = DLNotificationScheduler()
        
 let standingCategory = DLCategory(categoryIdentifier: "standingReminder")
        
 standingCategory.addActionButton(identifier: "willStand", title: "Ok, got it")
 standingCategory.addActionButton(identifier: "willNotStand", title: "Cannot")
        
 scheduler.scheduleCategories(categories: [standingCategory])

```
Don't forget to the set the notificaiton category before scheduling the notification using

```swift
notification.category = "standingReminder"
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
