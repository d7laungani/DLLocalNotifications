//
//  DLLocalNotifications.swift
//  DLLocalNotifications
//
//  Created by Devesh Laungani on 12/14/16.
//  Copyright © 2016 Devesh Laungani. All rights reserved.
//

import Foundation
import UserNotifications

let MAX_ALLOWED_NOTIFICATIONS = 64

@available(iOS 10.0, *)
public class DLNotificationScheduler {
    
    // Apple allows you to only schedule 64 notifications at a time
    static let maximumScheduledNotifications = 60
    
    public init () {}
    
    public func cancelAlllNotifications () {
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        DLQueue.queue.clear()
        saveQueue()
        
    }
    
    
    // Returns all notifications in the notifications queue.
    public func notificationsQueue() -> [DLNotification] {
        return DLQueue.queue.notificationsQueue()
    }
    
    
    
    // Cancel the notification if scheduled or queued
    public func cancelNotification (notification: DLNotification) {
        
        let identifier = (notification.localNotificationRequest != nil) ? notification.localNotificationRequest?.identifier : notification.identifier
        
        cancelNotificationWithIdentifier(identifier: identifier!)
        notification.scheduled = false
    }
    
    // Cancel the notification if scheduled or queued
    public func cancelNotification (identifier : String) {
    
        
        cancelNotificationWithIdentifier(identifier: identifier)
    }
    
    private func cancelNotificationWithIdentifier (identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        let queue = DLQueue.queue.notificationsQueue()
        var i = 0
        for noti in queue {
            if identifier == noti.identifier {
                DLQueue.queue.removeAtIndex(i)
                break
            }
            i += 1
        }
        
    }
    
    public func getScheduledNotifications(handler:@escaping (_ request:[UNNotificationRequest]?)-> Void) {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
            handler(requests)
        })
        
    }
    
    
    
    public func getScheduledNotification(with identifier: String, handler:@escaping (_ request:UNNotificationRequest?)-> Void) {
        
        
        var foundNotification:UNNotificationRequest? = nil
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
            
            for request  in  requests {
                if let request1 =  request.trigger as?  UNTimeIntervalNotificationTrigger {
                    if (request.identifier == identifier) {
                        print("Timer interval notificaiton: \(request1.nextTriggerDate().debugDescription)")
                        handler(request)
                    }
                    break
                    
                }
                if let request2 =  request.trigger as?  UNCalendarNotificationTrigger {
                    if (request.identifier == identifier) {
                        handler(request)
                        if(request2.repeats) {
                            print(request)
                            print("Calendar notification: \(request2.nextTriggerDate().debugDescription) and repeats")
                        } else {
                            print("Calendar notification: \(request2.nextTriggerDate().debugDescription) does not repeat")
                        }
                        break
                    }
                    
                }
                if let request3 = request.trigger as? UNLocationNotificationTrigger {
                    
                    print("Location notification: \(request3.region.debugDescription)")
                }
            }
        })
        
    }
    
    public func printAllNotifications () {
        
        print("printing all notifications")
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
            print(requests.count)
            for request  in  requests {
                if let request1 =  request.trigger as?  UNTimeIntervalNotificationTrigger {
                    print("Timer interval notificaiton: \(request1.nextTriggerDate().debugDescription)")
                }
                if let request2 =  request.trigger as?  UNCalendarNotificationTrigger {
                    if(request2.repeats) {
                        print(request)
                        print("Calendar notification: \(request2.nextTriggerDate().debugDescription) and repeats")
                    } else {
                        print("Calendar notification: \(request2.nextTriggerDate().debugDescription) does not repeat")
                    }
                }
                if let request3 = request.trigger as? UNLocationNotificationTrigger {
                    
                    print("Location notification: \(request3.region.debugDescription)")
                }
            }
        })
    }
    
    private func convertToNotificationDateComponent (notification: DLNotification, repeatInterval: RepeatingInterval   ) -> DateComponents {
        
        print(notification.fromDateComponents != nil)
        let dateFromDateComponents = Calendar.current.date(from: notification.fromDateComponents!)
        var newComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second ], from: dateFromDateComponents!)
        
        if repeatInterval != .none {
            
            switch repeatInterval {
            case .minute:
                newComponents = Calendar.current.dateComponents([ .second], from: dateFromDateComponents!)
            case .hourly:
                newComponents = Calendar.current.dateComponents([ .minute], from: dateFromDateComponents!)
            case .daily:
                newComponents = Calendar.current.dateComponents([.hour, .minute], from: dateFromDateComponents!)
            case .weekly:
                newComponents = Calendar.current.dateComponents([.hour, .minute, .weekday], from: dateFromDateComponents!)
            case .monthly:
                newComponents = Calendar.current.dateComponents([.hour, .minute, .day], from: dateFromDateComponents!)
            case .yearly:
                newComponents = Calendar.current.dateComponents([.hour, .minute, .day, .month], from: dateFromDateComponents!)
            default:
                break
            }
        }
        
        print(newComponents.debugDescription)
        return newComponents
    }
    
    fileprivate func queueNotification (notification: DLNotification) -> String? {
        
        if notification.scheduled {
            return nil
        } else {
            DLQueue.queue.push(notification)
        }
        
        return notification.identifier
    }
    
    public func scheduleNotification ( notification: DLNotification) {
        
        queueNotification(notification: notification)
        
    }
    
    public func scheduleAllNotifications () {
        
        let queue = DLQueue.queue.notificationsQueue()
        
        var count = 0
        for _ in queue {
            
            if count < min(DLNotificationScheduler.maximumScheduledNotifications, MAX_ALLOWED_NOTIFICATIONS) {
                let popped = DLQueue.queue.pop()
                scheduleNotificationInternal(notification: popped)
                count += 1
            } else { break }
            
        }
    }
    
    // Refactored for backwards compatability
    fileprivate func scheduleNotificationInternal ( notification: DLNotification) -> String? {
        
        if notification.scheduled {
            return nil
        } else {
            
            var trigger: UNNotificationTrigger?
            
            if (notification.region != nil) {
                trigger = UNLocationNotificationTrigger(region: notification.region!, repeats: false)
                
                
            } else {
                
                
                if let repeatInterval = notification.repeatInterval as? RepeatingInterval , let dateComponents = notification.fromDateComponents as? DateComponents {
                    // If RepeatingInterval Notification
                    trigger = UNCalendarNotificationTrigger(dateMatching: convertToNotificationDateComponent(notification: notification, repeatInterval: notification.repeatInterval), repeats: notification.repeats)
                }
                // If Date based notification
                else if let fireDate = notification.fireDate{
                    //trigger = UNTimeIntervalNotificationTrigger.init(timeInterval:  fireDate.timeIntervalSince(Date()), repeats: notification.repeats)
                    
                    if (notification.repeatInterval == .none) {
                        trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second ], from: fireDate) , repeats: notification.repeats)
                    }
                }
                /*
                 if (notification.repeatInterval == .minute) {
                 trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: (TimeInterval(60)), repeats: notification.repeats)
                 
                 }
                 
                 if (notification.repeatInterval == .hourly) {
                 trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: (TimeInterval(3600)), repeats: false)
                 
                 }
                 */
                
                
                
                
            }
            let content = UNMutableNotificationContent()
            
            content.title = notification.alertTitle!
            
            content.body = notification.alertBody!
            
            content.sound = notification.soundName == "" ? UNNotificationSound.default : UNNotificationSound.init(named: UNNotificationSoundName(rawValue: notification.soundName))
            
            
            if (notification.soundName == "1") { content.sound = nil}
            
            if !(notification.attachments == nil) { content.attachments = notification.attachments! }
            
            if !(notification.launchImageName == nil) { content.launchImageName = notification.launchImageName! }
            
            if !(notification.category == nil) { content.categoryIdentifier = notification.category! }
            
            notification.localNotificationRequest = UNNotificationRequest(identifier: notification.identifier!, content: content, trigger: trigger!)
            
            let center = UNUserNotificationCenter.current()
            center.add(notification.localNotificationRequest!, withCompletionHandler: {(error) in
                if error != nil {
                    print(error.debugDescription)
                }
            })
            
            notification.scheduled = true
        }
        
        return notification.identifier
        
    }
    
    ///Persists the notifications queue to the disk
    ///> Call this method whenever you need to save changes done to the queue and/or before terminating the app.
    public func saveQueue() -> Bool {
        return DLQueue.queue.save()
    }
    ///- returns: Count of scheduled notifications by iOS.
    func scheduledCount(completion: @escaping (Int) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (localNotifications) in
            completion(localNotifications.count)
        })
        
    }
    
    // You have to manually keep in mind ios 64 notification limit
    
    public func repeatsFromToDate (identifier: String, alertTitle: String, alertBody: String, fromDate: Date, toDate: Date, interval: Double, repeats: RepeatingInterval, category: String = "åa", sound: String = " ") {
        
        
        // Create multiple Notifications
        
        let intervalDifference = Int( toDate.timeIntervalSince(fromDate) / interval )
        
        var nextDate = fromDate
       
        
        for i in 0..<intervalDifference + 1 {
            
            // Next notification Date
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second ], from: nextDate)
            
            let identifier = identifier + String(i + 1)
            
            var notification = DLNotification(identifier: identifier, alertTitle: alertTitle, alertBody: alertBody, fromDateComponents: dateComponents, repeatInterval: repeats)
            notification.category = category
            notification.soundName = sound
            print("Dates from notifications : " + notification.fromDateComponents!.debugDescription)
            self.queueNotification(notification: notification)
            nextDate = nextDate.addingTimeInterval(interval)

        }
        
    }
    
    public func scheduleCategories(categories: [DLCategory]) {
        
        var notificationCategories = Set<UNNotificationCategory>()
        
        for category in categories {
            
            guard let categoryInstance = category.categoryInstance else { continue }
            notificationCategories.insert(categoryInstance)
            
        }
        
        UNUserNotificationCenter.current().setNotificationCategories(notificationCategories)
        
    }
    
}

// Repeating Interval Times

public enum RepeatingInterval: String {
    case none, minute, hourly, daily, weekly, monthly, yearly
}

extension Date {
    
    func removeSeconds() -> Date {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: components)!
    }
}

