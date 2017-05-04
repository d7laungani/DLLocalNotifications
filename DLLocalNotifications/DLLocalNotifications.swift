//
//  DLLocalNotifications.swift
//  DLLocalNotifications
//
//  Created by Devesh Laungani on 12/14/16.
//  Copyright © 2016 Devesh Laungani. All rights reserved.
//

import Foundation
import UserNotifications
import MapKit


public class DLNotificationScheduler{
    
    
    public init () {
        
        
    }
    
    public func cancelAlllNotifications () {
        
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
    }
    
    public func cancelNotification (notification: DLNotification) {
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [(notification.localNotificationRequest?.identifier)!])
    }
    
    func printAllNotifications () {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
            
            for request  in  requests {
                if let request1 =  request.trigger as?  UNTimeIntervalNotificationTrigger {
                    print(request1.nextTriggerDate().debugDescription)
                }
                if let request2 =  request.trigger as?  UNCalendarNotificationTrigger {
                    print(request2.nextTriggerDate().debugDescription)
                }
                if let request3 = request.trigger as? UNLocationNotificationTrigger {
                    
                    print(request3.region.debugDescription)
                }
                
                
                
                
            }
        })
    }
    
    
    
    private func convertToNotificationDateComponent (notification: DLNotification, repeatInterval: Repeats   ) -> DateComponents{
        
        
        var newComponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: notification.fireDate!)
        
        if repeatInterval != .None {
            
            switch repeatInterval {
            case .Minute:
                newComponents = Calendar.current.dateComponents([ .second], from: notification.fireDate!)
            case .Hourly:
                newComponents = Calendar.current.dateComponents([ .minute], from: notification.fireDate!)
            case .Daily:
                newComponents = Calendar.current.dateComponents([.hour, .minute], from: notification.fireDate!)
            case .Weekly:
                newComponents = Calendar.current.dateComponents([.hour, .minute, .weekday], from: notification.fireDate!)
            case .Monthly:
                newComponents = Calendar.current.dateComponents([.hour, .minute, .day], from: notification.fireDate!)
            case .Yearly:
                newComponents = Calendar.current.dateComponents([.hour, .minute, .day, .month], from: notification.fireDate!)
            default:
                break
            }
        }
        
        
        
        return newComponents
    }
    
    
    public func scheduleNotification ( notification: DLNotification) -> String? {
        
        
        if notification.scheduled {
            return nil
        }
        else {
            var trigger: UNNotificationTrigger
            
            
            
            if (notification.region != nil) {
                trigger = UNLocationNotificationTrigger(region: notification.region!, repeats: false)
                if (notification.repeatInterval == .Hourly) {
                    trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: (TimeInterval(3600)), repeats: false)
                    
                }
                
            } else{
                
                trigger = UNCalendarNotificationTrigger(dateMatching: convertToNotificationDateComponent(notification: notification, repeatInterval: notification.repeatInterval), repeats: notification.repeats)
                if (notification.repeatInterval == .Hourly) {
                    trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: (TimeInterval(3600)), repeats: false)
                    
                }
                
            }
            let content = UNMutableNotificationContent()
            
            content.title = notification.alertTitle!
            
            content.body = notification.alertBody!
            
            content.sound = (notification.soundName == nil) ? UNNotificationSound.default() : UNNotificationSound.init(named: notification.soundName!)
            
            if !(notification.attachments == nil){ content.attachments = notification.attachments! }
            
            if !(notification.launchImageName == nil){ content.launchImageName = notification.launchImageName! }
            
            if !(notification.category == nil){ content.categoryIdentifier = notification.category! }
            
            notification.localNotificationRequest = UNNotificationRequest(identifier: notification.identifier!, content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(notification.localNotificationRequest!, withCompletionHandler: {(error) in print ("completed") } )
            
            notification.scheduled = true
            
            
            
        }
        
        return notification.identifier
        
        
        
    }
    
    // You have to manually keep in mind ios 64 notification limit
    
    public func repeatsFromToDate (identifier:String, alertTitle:String, alertBody: String, fromDate: Date, toDate: Date, interval: Double, repeats: Repeats, category:String = " ") {
        
        
        
        
        let notification = DLNotification(identifier: identifier, alertTitle: alertTitle, alertBody: alertBody, date: fromDate, repeats: repeats)
        notification.category = category
        
        // Create multiple Notifications
        
        self.scheduleNotification(notification: notification)
        let intervalDifference = Int( toDate.timeIntervalSince(fromDate) / interval )
        
        var nextDate = fromDate
        
        for i in 0..<intervalDifference {
            
            // Next notification Date
            
            nextDate = nextDate.addingTimeInterval(interval)
            
            // create notification
            
            let identifier = identifier + String(i + 1)
            
            let notification = DLNotification(identifier: identifier, alertTitle: alertTitle, alertBody: alertBody, date: nextDate, repeats: repeats)
            notification.category = category
            self.scheduleNotification(notification: notification)
        }
        
        
    }
    
    
    public func scheduleCategories(categories:[DLCategory]) {
        
        var categories1 = Set<UNNotificationCategory>()
        
        for x in categories {
            
            categories1.insert(x.categoryInstance!)
        }
        UNUserNotificationCenter.current().setNotificationCategories(categories1)
        
        
        
    }
    
    
    
    
    
}

// Repeating Interval Times

public enum Repeats: String {
    case None,Minute, Hourly , Daily, Weekly , Monthly, Yearly
}


// A wrapper class for creating a Category

public class DLCategory  {
    
    private var actions:[UNNotificationAction]?
    internal var categoryInstance:UNNotificationCategory?
    var identifier:String
    
    
    public init (categoryIdentifier:String) {
        
        identifier = categoryIdentifier
        actions = [UNNotificationAction] ()
        
    }
    
    public func addActionButton(identifier:String?, title:String?) {
        
        let action = UNNotificationAction(identifier: identifier!, title: title!, options: [])
        actions?.append(action)
        categoryInstance = UNNotificationCategory(identifier: self.identifier, actions: self.actions!, intentIdentifiers: [], options: [])
        
    }
    
    
    
    
    
}




// A wrapper class for creating a User Notification

public class DLNotification {
    
    internal var localNotificationRequest: UNNotificationRequest?
    
    var repeatInterval: Repeats = .None
    
    var alertBody: String?
    
    var alertTitle: String?
    
    var soundName: String?
    
    var fireDate: Date?
    
    var repeats:Bool = false
    
    var scheduled: Bool = false
    
    var identifier:String?
    
    var attachments:[UNNotificationAttachment]?
    
    var launchImageName: String?
    
    public var category:String?
    
    var region:CLRegion?
    
    public init (identifier:String, alertTitle:String, alertBody: String, date: Date?, repeats: Repeats ) {
        
        self.alertBody = alertBody
        self.alertTitle = alertTitle
        self.fireDate = date
        self.repeatInterval = repeats
        self.identifier = identifier
        if (repeats == .None) {
            self.repeats = false
        } else {
            self.repeats = true
        }
        
        
        
        
    }
    
    public init (identifier:String, alertTitle:String, alertBody: String, date: Date?, repeats: Repeats, soundName: String ) {
        
        self.alertBody = alertBody
        self.alertTitle = alertTitle
        self.fireDate = date
        self.repeatInterval = repeats
        self.soundName = soundName
        self.identifier = identifier
        
        if (repeats == .None) {
            self.repeats = false
        } else {
            self.repeats = true
        }
        
    }
    
    // Region based notification
    // Default notifyOnExit is false and notifyOnEntry is true
    
    public init (identifier:String, alertTitle:String, alertBody: String, region: CLRegion? ) {
        
        self.alertBody = alertBody
        self.alertTitle = alertTitle
        self.identifier = identifier
        region?.notifyOnExit = false
        region?.notifyOnEntry = true
        self.region = region
        
        
    }
    
    
}

