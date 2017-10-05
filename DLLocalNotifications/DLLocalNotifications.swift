//
//  DLLocalNotifications.swift
//  DLLocalNotifications
//
//  Created by Devesh Laungani on 12/14/16.
//  Refactored and migrated to Swift 3 syntax by Jan Thielemann on 05/13/17
//  Copyright © 2016 Devesh Laungani. All rights reserved.
//

import Foundation
import UserNotifications
import MapKit

public class DLNotificationScheduler {
    
    private init() {}
    
    public static func cancelAlllNotifications () {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    public static func cancelNotification(_ notification: DLNotification) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [(notification.localNotificationRequest?.identifier)!])
    }
    
    public static func printAllNotifications () {
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

    private static func convertToNotificationDateComponent(_ notification: DLNotification, repeatInterval: RepeatingInterval   ) -> DateComponents{
        var newComponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: notification.fireDate!)
        if repeatInterval != .none {
            switch repeatInterval {
            case .minute:
                newComponents = Calendar.current.dateComponents([ .second], from: notification.fireDate!)
            case .hour:
                newComponents = Calendar.current.dateComponents([ .minute], from: notification.fireDate!)
            case .day:
                newComponents = Calendar.current.dateComponents([.hour, .minute], from: notification.fireDate!)
            case .week:
                newComponents = Calendar.current.dateComponents([.hour, .minute, .weekday], from: notification.fireDate!)
            case .month:
                newComponents = Calendar.current.dateComponents([.hour, .minute, .day], from: notification.fireDate!)
            case .year:
                newComponents = Calendar.current.dateComponents([.hour, .minute, .day, .month], from: notification.fireDate!)
            default:
                break
            }
        }
        
        return newComponents
    }
    
    public static func scheduleNotification(_ notification: DLNotification) -> String? {
        if notification.scheduled {
            return nil
        } else {
            var trigger: UNNotificationTrigger
            
            if (notification.region != nil) {
                trigger = UNLocationNotificationTrigger(region: notification.region!, repeats: false)
                if (notification.repeatInterval == .hour) {
                    trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: (TimeInterval(3600)), repeats: false)
                    
                }
            } else {
                trigger = UNCalendarNotificationTrigger(dateMatching: convertToNotificationDateComponent(notification, repeatInterval: notification.repeatInterval), repeats: notification.repeats)
                if (notification.repeatInterval == .hour) {
                    trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: (TimeInterval(3600)), repeats: false)
                }
            }
            
            let content = UNMutableNotificationContent()
            content.title = notification.alertTitle!
            content.body = notification.alertBody!
            content.sound = (notification.soundName == nil) ? UNNotificationSound.default() : UNNotificationSound.init(named: notification.soundName!)
            
            if !(notification.attachments == nil){
                content.attachments = notification.attachments!
            }
            
            if !(notification.launchImageName == nil){
                content.launchImageName = notification.launchImageName!
            }
            
            if !(notification.category == nil){
                content.categoryIdentifier = notification.category!
            }
            
            notification.localNotificationRequest = UNNotificationRequest(identifier: notification.identifier!, content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(notification.localNotificationRequest!, withCompletionHandler: {(error) in print ("completed") } )
            
            notification.scheduled = true
        }
        
        return notification.identifier
    }
    
    public static func repeatsFromToDate(identifier:String, alertTitle:String, alertBody: String, fromDate: Date, toDate: Date, interval: Double, repeats: RepeatingInterval, category:String = " ") -> [String] {
        
        var identifiers = [String]()
        
        let notification = DLNotification(identifier: identifier + String(0), alertTitle: alertTitle, alertBody: alertBody, date: fromDate, repeats: repeats)
        notification.category = category
        
        if let identifier = scheduleNotification(notification) {
            identifiers.append(identifier)
        }
        
        let intervalDifference = Int(toDate.timeIntervalSince(fromDate) / interval)
        
        var nextDate = fromDate
        
        for i in 1..<intervalDifference {
            nextDate = nextDate.addingTimeInterval(interval)
            
            let notification = DLNotification(identifier: identifier + String(i), alertTitle: alertTitle, alertBody: alertBody, date: nextDate, repeats: repeats)
            notification.category = category
            
            if let identifier = scheduleNotification(notification) {
                identifiers.append(identifier)
            }
        }
        
        return identifiers
    }
    
    
    public static func scheduleCategories(_ categories:[DLCategory]) {
        var notificationCategories = Set<UNNotificationCategory>()
        
        for categorie in categories {
            guard let categoryInstance = categorie.categoryInstance else { continue }
            notificationCategories.insert(categoryInstance)
        }
        
        UNUserNotificationCenter.current().setNotificationCategories(notificationCategories)
    }
}

// Repeating Interval Times
public enum RepeatingInterval: String {
    case none, minute, hour, day, week, month, year
}


// A wrapper class for creating a Category
public class DLCategory  {
    
    private var actions: [UNNotificationAction]?
    
    internal var categoryInstance: UNNotificationCategory?
    
    var identifier: String
    
    public init(categoryIdentifier:String) {
        identifier = categoryIdentifier
        actions = [UNNotificationAction]()
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
    
    var repeatInterval: RepeatingInterval = .none
    
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
    
    public init(identifier:String, alertTitle:String, alertBody: String, date: Date?, repeats: RepeatingInterval ) {
        self.alertBody = alertBody
        self.alertTitle = alertTitle
        self.fireDate = date
        self.repeatInterval = repeats
        self.identifier = identifier
        if (repeats == .none) {
            self.repeats = false
        } else {
            self.repeats = true
        }
    }
    
    public init(identifier:String, alertTitle:String, alertBody: String, date: Date?, repeats: RepeatingInterval, soundName: String ) {
        self.alertBody = alertBody
        self.alertTitle = alertTitle
        self.fireDate = date
        self.repeatInterval = repeats
        self.soundName = soundName
        self.identifier = identifier
        
        if (repeats == .none) {
            self.repeats = false
        } else {
            self.repeats = true
        }
    }
    
    public init(identifier:String, alertTitle:String, alertBody: String, region: CLRegion? ) {
        self.alertBody = alertBody
        self.alertTitle = alertTitle
        self.identifier = identifier
        region?.notifyOnExit = false
        region?.notifyOnEntry = true
        self.region = region
    }
}

