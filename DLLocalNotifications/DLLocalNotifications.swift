//
//  DLLocalNotifications.swift
//  DLLocalNotifications
//
//  Created by Devesh Laungani on 12/14/16.
//  Copyright © 2016 Devesh Laungani. All rights reserved.
//

import Foundation
import UserNotifications


public class DLNotificationScheduler{
    
    
    func cancelAlllNotifications () {
        
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
    }
    
    func cancelNotification (notification: DLNotification) {
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [(notification.localNotificationRequest?.identifier)!])
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
    
    
    func scheduleNotification ( notification: DLNotification) -> String? {
        
        
        if notification.scheduled {
            return nil
        } else {
            
            
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: convertToNotificationDateComponent(notification: notification, repeatInterval: notification.repeatInterval), repeats: notification.repeats)
            
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
    
    func repeatsFromToDate (identifier:String, alertTitle:String, alertBody: String, fromDate: Date, toDate: Date, interval: Double) {
        
        
        
        
        let notification = DLNotification(identifier: identifier, alertTitle: alertTitle, alertBody: alertBody, date: fromDate, repeats: .None)
        
        // Create multiple Notifications
        
        self.scheduleNotification(notification: notification)
        let intervalDifference = Int( toDate.timeIntervalSince(fromDate) / interval )
        
        var nextDate = fromDate
        
        for i in 0..<intervalDifference {
            
            // Next notification Date
            
            nextDate = nextDate.addingTimeInterval(interval)
            
            // create notification
            
            let identifier = identifier + String(i + 1)
            
            let notification = DLNotification(identifier: identifier, alertTitle: alertTitle, alertBody: alertBody, date: nextDate, repeats: .None)
            
            self.scheduleNotification(notification: notification)
        }
        
        
    }
    
    
}

// Repeating Interval Times

enum Repeats: String {
    case None,Minute, Hourly , Daily, Weekly , Monthly, Yearly
}



// A wrapper class for creating a User Notification

public class DLNotification {
    
    internal var localNotificationRequest: UNNotificationRequest?
    
    var repeatInterval: Repeats = .None
    
    var alertBody: String?
    
    var alertTitle: String?
    
    var soundName: String?
    
    var fireDate: Date?
    
    var repeats:Bool
    
    var scheduled: Bool = false
    
    var identifier:String?
    
    var attachments:[UNNotificationAttachment]?
    
    var launchImageName: String?
    
    var category:String?
    
    init (identifier:String, alertTitle:String, alertBody: String, date: Date?, repeats: Repeats ) {
        
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
    
    init (identifier:String, alertTitle:String, alertBody: String, date: Date?, repeats: Repeats, soundName: String ) {
        
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
    
    
    
}

