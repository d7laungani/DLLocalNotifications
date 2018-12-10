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
    
    public func cancelNotification (notification: DLNotification) {
        
        notification.cancel()
    }
    
    // Returns all notifications in the notifications queue.
    public func notificationsQueue() -> [DLNotification] {
        return DLQueue.queue.notificationsQueue()
    }
    
    public func printAllNotifications () {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
            print(requests.count)
            for request  in  requests {
                if let request1 =  request.trigger as?  UNTimeIntervalNotificationTrigger {
                    print("Timer interval notificaiton: \(request1.nextTriggerDate().debugDescription)")
                }
                if let request2 =  request.trigger as?  UNCalendarNotificationTrigger {
                    if(request2.repeats) {
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
        
        var newComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second ], from: notification.fireDate!)
        
        if repeatInterval != .none {
            
            switch repeatInterval {
            case .minute:
                newComponents = Calendar.current.dateComponents([ .second], from: notification.fireDate!)
            case .hourly:
                newComponents = Calendar.current.dateComponents([ .minute], from: notification.fireDate!)
            case .daily:
                newComponents = Calendar.current.dateComponents([.hour, .minute], from: notification.fireDate!)
            case .weekly:
                newComponents = Calendar.current.dateComponents([.hour, .minute, .weekday], from: notification.fireDate!)
            case .monthly:
                newComponents = Calendar.current.dateComponents([.hour, .minute, .day], from: notification.fireDate!)
            case .yearly:
                newComponents = Calendar.current.dateComponents([.hour, .minute, .day, .month], from: notification.fireDate!)
            default:
                break
            }
        }
        
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
            
            var trigger: UNNotificationTrigger
            
            if (notification.region != nil) {
                trigger = UNLocationNotificationTrigger(region: notification.region!, repeats: false)
                if (notification.repeatInterval == .hourly) {
                    trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: (TimeInterval(3600)), repeats: false)
                    
                }
                
            } else {
                
                trigger = UNCalendarNotificationTrigger(dateMatching: convertToNotificationDateComponent(notification: notification, repeatInterval: notification.repeatInterval), repeats: notification.repeats)
                if (notification.repeatInterval == .hourly) {
                    trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: (TimeInterval(3600)), repeats: false)
                    
                }
                
            }
            let content = UNMutableNotificationContent()
            
            content.title = notification.alertTitle!
            
            content.body = notification.alertBody!
            
            content.sound = notification.soundName == "" ? UNNotificationSound.default : UNNotificationSound.init(named: UNNotificationSoundName(rawValue: notification.soundName))
            
            if (notification.soundName == "1") { content.sound = nil}
            
            if !(notification.attachments == nil) { content.attachments = notification.attachments! }
            
            if !(notification.launchImageName == nil) { content.launchImageName = notification.launchImageName! }
            
            if !(notification.category == nil) { content.categoryIdentifier = notification.category! }
            
            notification.localNotificationRequest = UNNotificationRequest(identifier: notification.identifier!, content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(notification.localNotificationRequest!, withCompletionHandler: {(_) in print ("completed") })
            
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
    
    public func repeatsFromToDate (identifier: String, alertTitle: String, alertBody: String, fromDate: Date, toDate: Date, interval: Double, repeats: RepeatingInterval, category: String = " ", sound: String = " ") {
        
        let notification = DLNotification(identifier: identifier, alertTitle: alertTitle, alertBody: alertBody, date: fromDate, repeats: repeats)
        notification.category = category
        notification.soundName = sound
        // Create multiple Notifications
        
        self.queueNotification(notification: notification)
        let intervalDifference = Int( toDate.timeIntervalSince(fromDate) / interval )
        
        var nextDate = fromDate
        
        for i in 0..<intervalDifference {
            
            // Next notification Date
            
            nextDate = nextDate.addingTimeInterval(interval)
            let identifier = identifier + String(i + 1)
            
            let notification = DLNotification(identifier: identifier, alertTitle: alertTitle, alertBody: alertBody, date: nextDate, repeats: repeats)
            notification.category = category
            notification.soundName = sound
            self.queueNotification(notification: notification)
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

// A wrapper class for creating a Category
@available(iOS 10.0, *)
public class DLCategory {
    
    private var actions: [UNNotificationAction]?
    internal var categoryInstance: UNNotificationCategory?
    var identifier: String
    
    public init (categoryIdentifier: String) {
        
        identifier = categoryIdentifier
        actions = [UNNotificationAction]()
        
    }
    
    public func addActionButton(identifier: String?, title: String?) {
        
        let action = UNNotificationAction(identifier: identifier!, title: title!, options: [])
        actions?.append(action)
        categoryInstance = UNNotificationCategory(identifier: self.identifier, actions: self.actions!, intentIdentifiers: [], options: [])
        
    }
    
}

// A wrapper class for creating a User Notification

@available(iOS 10.0, *)
public class DLNotification {
    
    internal var localNotificationRequest: UNNotificationRequest?
    
    var repeatInterval: RepeatingInterval = .none
    
    var alertBody: String?
    
    var alertTitle: String?
    
    var soundName: String = ""
    
    var fireDate: Date?
    
    var repeats: Bool = false
    
    var scheduled: Bool = false
    
    public var identifier: String?
    
    var attachments: [UNNotificationAttachment]?
    
    var launchImageName: String?
    
    public var category: String?
    
    var region: CLRegion?
    
    var hasDataFromBefore = false
    
    public init(request: UNNotificationRequest) {
        
        self.hasDataFromBefore = true
        self.localNotificationRequest = request
        if let calendarTrigger =  request.trigger as? UNCalendarNotificationTrigger {
            self.fireDate = calendarTrigger.nextTriggerDate()
        } else if let  intervalTrigger =  request.trigger as? UNTimeIntervalNotificationTrigger {
            self.fireDate = intervalTrigger.nextTriggerDate()
        }
    }
    
    public init (identifier: String, alertTitle: String, alertBody: String, date: Date?, repeats: RepeatingInterval ) {
        
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
    
    public init (identifier: String, alertTitle: String, alertBody: String, date: Date?, repeats: RepeatingInterval, soundName: String ) {
        
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
    
    // Region based notification
    // Default notifyOnExit is false and notifyOnEntry is true
    
    public init (identifier: String, alertTitle: String, alertBody: String, region: CLRegion? ) {
        
        self.alertBody = alertBody
        self.alertTitle = alertTitle
        self.identifier = identifier
        region?.notifyOnExit = false
        region?.notifyOnEntry = true
        self.region = region
        
    }
    
    ///Cancels the notification if scheduled or queued.
    func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [(self.localNotificationRequest?.identifier)!])
        let queue = DLQueue.queue.notificationsQueue()
        var i = 0
        for notification in queue {
            if self.identifier == notification.identifier {
                DLQueue.queue.removeAtIndex(i)
                break
            }
            i += 1
        }
        scheduled = false
    }
    
}



@available(iOS 10.0, *)
public func <(lhs: DLNotification, rhs: DLNotification) -> Bool {
    return lhs.fireDate?.compare(rhs.fireDate!) == ComparisonResult.orderedAscending
}
@available(iOS 10.0, *)
public func ==(lhs: DLNotification, rhs: DLNotification) -> Bool {
    return lhs.identifier == rhs.identifier
}

@available(iOS 10.0, *)
private class DLQueue: NSObject {
    
    fileprivate var notifQueue = [DLNotification]()
    static let queue = DLQueue()
    let ArchiveURL = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("notifications.dlqueue")
    
    override init() {
        super.init()
        if let notificationQueue = self.load() {
            notifQueue = notificationQueue
        }
    }
    
    fileprivate func push(_ notification: DLNotification) {
        notifQueue.insert(notification, at: findInsertionPoint(notification))
    }
    
    /// Finds the position at which the new DLNotification is inserted in the queue.
    /// - seealso: [swift-algorithm-club](https://github.com/hollance/swift-algorithm-club/tree/master/Ordered%20Array)
    fileprivate func findInsertionPoint(_ notification: DLNotification) -> Int {
        let range = 0..<notifQueue.count
        var rangeLowerBound = range.lowerBound
        var rangeUpperBound = range.upperBound
        
        while rangeLowerBound < rangeUpperBound {
            let midIndex = rangeLowerBound + (rangeUpperBound - rangeLowerBound) / 2
            if notifQueue[midIndex] == notification {
                return midIndex
            } else if notifQueue[midIndex] < notification {
                rangeLowerBound = midIndex + 1
            } else {
                rangeUpperBound = midIndex
            }
        }
        return rangeLowerBound
    }
    
    ///Removes and returns the head of the queue.
    
    fileprivate func pop() -> DLNotification {
        return notifQueue.removeFirst()
    }
    
    //Returns the head of the queue.
    
    fileprivate func peek() -> DLNotification? {
        return notifQueue.last
    }
    
    ///Clears the queue.
    
    fileprivate func clear() {
        notifQueue.removeAll()
    }
    
    ///Called when a DLLocalnotification is cancelled.
    
    fileprivate func removeAtIndex(_ index: Int) {
        notifQueue.remove(at: index)
    }
    
    // Returns Count of DLNotifications in the queue.
    fileprivate func count() -> Int {
        return notifQueue.count
    }
    
    // Returns The notifications queue.
    fileprivate func notificationsQueue() -> [DLNotification] {
        let queue = notifQueue
        return queue
    }
    
    // Returns DLLocalnotifcation if found, nil otherwise.
    fileprivate func notificationWithIdentifier(_ identifier: String) -> DLNotification? {
        for note in notifQueue {
            if note.identifier == identifier {
                return note
            }
        }
        return nil
    }
    
    
    ///Save queue on disk.
    
    fileprivate func save() -> Bool {
        return NSKeyedArchiver.archiveRootObject(self.notifQueue, toFile: ArchiveURL.path)
    }
    
    ///Load queue from disk.
    ///Called first when instantiating the DLQueue singleton.
    ///You do not need to manually call this method
    
    fileprivate func load() -> [DLNotification]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: ArchiveURL.path) as? [DLNotification]
    }
    
}
