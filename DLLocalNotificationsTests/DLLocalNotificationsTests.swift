//
//  DLLocalNotificationsTests.swift
//  DLLocalNotificationsTests
//
//  Created by Devesh Laungani on 12/14/16.
//  Copyright © 2016 Devesh Laungani. All rights reserved.
//

import XCTest
@testable import DLLocalNotifications
import UserNotifications

class DLLocalNotificationsTests: XCTestCase {
    
    let scheduler = DLNotificationScheduler()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        addUIInterruptionMonitor(withDescription: "Allow push") { (alerts) -> Bool in
            if(alerts.buttons["Allow"].exists){
                alerts.buttons["Allow"].tap();
            }
            return true;
        }
        
        scheduler.cancelAlllNotifications()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        scheduler.cancelAlllNotifications()
    }
    
    func testBasicNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "Feed the cat"
        content.subtitle = "It looks hungry"
        content.sound = UNNotificationSound.default()
        
        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // add our notification request
        //UNUserNotificationCenter.current().add(request)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error.debugDescription)
        }
        
        let expectationTemp = expectation(description: "Notification not scheduled")
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
            XCTAssertEqual(1, requests.count)
            expectationTemp.fulfill()
            
        })
        
        waitForExpectations(timeout: 10, handler: nil)
        
    }
    
    func testSingleFireNotification() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // The date you would like the notification to fire at 30 second mark of every minute
        let triggerDate = Date().addingTimeInterval(300)
        
        let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notification Alert", alertBody: "You have successfully created a notification", date: triggerDate)
        
        scheduler.scheduleNotification(notification: firstNotification)
        XCTAssertEqual(1, scheduler.notificationsQueue().count)
        scheduler.scheduleAllNotifications()
        XCTAssertEqual(0, scheduler.notificationsQueue().count)
        XCTAssertEqual(true, firstNotification.scheduled)
        
        
        let expectationTemp = expectation(description: "Notification not scheduled")
        
        
        scheduler.getScheduledNotification(with: firstNotification.identifier!){ (request) -> Void in
            if let request = request{
                
                let trigger =  request.trigger as?  UNCalendarNotificationTrigger
                XCTAssertEqual(request.identifier, firstNotification.identifier)
                XCTAssertEqual(triggerDate.timeIntervalSince1970.rounded(), (trigger?.nextTriggerDate()?.timeIntervalSince1970.rounded())!, accuracy: 0.002)
                XCTAssertFalse(trigger!.repeats)
                
                expectationTemp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
    }
    
    func testRepeatingNotificationMinute() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // The date you would like the notification to fire at 30 second mark of every minute
        var dateComponents = DateComponents()
        dateComponents.second = 30
        
        let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notification Alert", alertBody: "You have successfully created a notification", fromDateComponents: dateComponents, repeatInterval: .minute)
        
        scheduler.scheduleNotification(notification: firstNotification)
        XCTAssertEqual(1, scheduler.notificationsQueue().count)
        scheduler.scheduleAllNotifications()
        XCTAssertEqual(0, scheduler.notificationsQueue().count)
        XCTAssertEqual(true, firstNotification.scheduled)
        
        let expectationTemp = expectation(description: "Next Trigger Date Does not match expectation")
        
        
        scheduler.getScheduledNotification(with: firstNotification.identifier!){ (request) -> Void in
            if let request = request{
                let trigger =  request.trigger as?  UNCalendarNotificationTrigger
                
                var actualTriggerTime = Calendar.current.dateComponents([ .second], from: (trigger!.nextTriggerDate())!)
                

                XCTAssertEqual(dateComponents,actualTriggerTime)
                XCTAssertTrue(trigger!.repeats)
                
                expectationTemp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        
        
    }
    
    func testRepeatingNotificationHour() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // The date you would like the notification to fire at :30 mins every hour
        
        var dateComponents = DateComponents()
        dateComponents.minute = 30
        dateComponents.second = 0

        let firstNotification = DLNotification(identifier: "hourlyNotification", alertTitle: "Notification Alert", alertBody: "You have successfully created a notification", fromDateComponents: dateComponents, repeatInterval: .hourly)
        
        scheduler.scheduleNotification(notification: firstNotification)
        XCTAssertEqual(1, scheduler.notificationsQueue().count)
        scheduler.scheduleAllNotifications()
        XCTAssertEqual(0, scheduler.notificationsQueue().count)
        XCTAssertEqual(true, firstNotification.scheduled)
        
        let expectationTemp = expectation(description: "Next Trigger Date Does not match expectation")
        scheduler.getScheduledNotification(with: firstNotification.identifier!){ (request) -> Void in
            if let request = request{
                let trigger =  request.trigger as?  UNCalendarNotificationTrigger

            
                var actualTriggerTime = Calendar.current.dateComponents([ .minute, .second], from: (trigger!.nextTriggerDate())!)
                

                XCTAssertEqual(dateComponents,actualTriggerTime)
                XCTAssertTrue(trigger!.repeats)

                
                expectationTemp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 20, handler: nil)
        
        
        
    }
    
    
    func testNotificationCancel() {
        let triggerDate = Date().addingTimeInterval(300)
        
        let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notification Alert", alertBody: "You have successfully created a notification", date: triggerDate)
        
        scheduler.scheduleNotification(notification: firstNotification)
        XCTAssertEqual(1, scheduler.notificationsQueue().count)
        scheduler.scheduleAllNotifications()
        XCTAssertEqual(0, scheduler.notificationsQueue().count)
        XCTAssertEqual(true, firstNotification.scheduled)
        
        let expectationTemp1 = expectation(description: "Initial Notification exists")
        
        scheduler.getScheduledNotifications { (requests) in
            XCTAssertEqual(1, requests?.count)
            expectationTemp1.fulfill()
        }
        
        
        scheduler.cancelNotification(notification: firstNotification)
        XCTAssertEqual(false, firstNotification.scheduled)
        
        let expectationTemp = expectation(description: "Removed from apple notification queue")
        
        scheduler.getScheduledNotifications { (requests) in
            XCTAssertEqual(0, requests?.count)
            expectationTemp.fulfill()
        }
        
        
        waitForExpectations(timeout: 10, handler: nil)
        
        
        
    }
    
    func testNotificationCancelWithIdentifier() {
        let triggerDate = Date().addingTimeInterval(300)
        let identifier = "firstNotification"
        let firstNotification = DLNotification(identifier: identifier, alertTitle: "Notification Alert", alertBody: "You have successfully created a notification", date: triggerDate)
        
        scheduler.scheduleNotification(notification: firstNotification)
        XCTAssertEqual(1, scheduler.notificationsQueue().count)
        scheduler.scheduleAllNotifications()
        XCTAssertEqual(0, scheduler.notificationsQueue().count)
        XCTAssertEqual(true, firstNotification.scheduled)
        
        let expectationTemp1 = expectation(description: "Initial Notification exists")
        
        scheduler.getScheduledNotifications { (requests) in
            XCTAssertEqual(1, requests?.count)
            expectationTemp1.fulfill()
        }
        
        
        scheduler.cancelNotification(identifier: identifier)
        
        let expectationTemp = expectation(description: "Removed from apple notification queue")
        
        scheduler.getScheduledNotifications { (requests) in
            XCTAssertEqual(0, requests?.count)
            expectationTemp.fulfill()
        }
        
        
        waitForExpectations(timeout: 10, handler: nil)
        
        
        
    }
    
    
    
    // Regression tests
    

    // Issue #26
    func testSettingALaunchImage() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // The date you would like the notification to fire at
        let triggerDate = Date().addingTimeInterval(20)
        
        let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notification Alert", alertBody: "You have successfully created a notification", date: triggerDate)
        
        firstNotification.launchImageName = "test.png"
        
        scheduler.scheduleNotification(notification: firstNotification)
        XCTAssertEqual(1, scheduler.notificationsQueue().count)
        scheduler.scheduleAllNotifications()
        XCTAssertEqual(0, scheduler.notificationsQueue().count)
        XCTAssertEqual(true, firstNotification.scheduled)
        
        let expectationTemp = expectation(description: "Launch Image is set on notification")
        
        scheduler.getScheduledNotification(with: firstNotification.identifier!){ (request) -> Void in
            if let request = request{
                
                XCTAssertNotNil(request.content.launchImageName)
                
                expectationTemp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
    }
    
    
    // Issue #25
    public func testRepeatEvery3Hrs() {
        
        // Repeats at 9am, 12pm, and 3pm and 6pm
        // if you don't want 6pm then remove a minute from the end date
        let triggerDate9am = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
        let triggerDate6pm = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!
        
        scheduler.repeatsFromToDate(identifier: "First Notification", alertTitle: "Multiple Notifications", alertBody: "Progress", fromDate: triggerDate9am, toDate: triggerDate6pm , interval: 10800, repeats: .daily )
        
        XCTAssertEqual(4, scheduler.notificationsQueue().count)
        scheduler.scheduleAllNotifications()
        XCTAssertEqual(0, scheduler.notificationsQueue().count)
        
        let calendar = Calendar.current
        
        
        let expectationTemp = expectation(description: "All Notifications scheduled")
        scheduler.getScheduledNotifications { (requests) in
            
            XCTAssertEqual(4, requests?.count)
            
            let triggerDate12pm = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
            let triggerDate3pm = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: Date())!

            var expectedDates:[Date] = [triggerDate6pm, triggerDate3pm, triggerDate12pm,triggerDate9am]

            for   (index, request) in requests!.enumerated() {
                
                    var trigger =  request.trigger as?  UNCalendarNotificationTrigger
                    var expectedTriggerTime =  calendar.dateComponents([.hour, .minute], from: expectedDates[index])
                    var actualTriggerTime =  calendar.dateComponents([.hour, .minute], from: (trigger?.nextTriggerDate())!)
                    XCTAssertEqual(expectedTriggerTime,actualTriggerTime)
                                
            
        
            }
            
            
            
            expectationTemp.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        
    }
    
    /*
    // Issue #15
    public func testDelayedNotificationFiringImmediatelyForMinuteRepetition() {
        
        // The date you would like the notification to fire at 30 second mark of every minute
        var dateComponents = DateComponents()
        dateComponents.seconds = 30
        
        let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notification Alert", alertBody: "You have successfully created a notification",  fromDateComponents: dateComponents, repeatInterval: .minute)
        
        let scheduler = DLNotificationScheduler()
        scheduler.scheduleNotification(notification: firstNotification)
        
        XCTAssertEqual(1, scheduler.notificationsQueue().count)
        scheduler.scheduleAllNotifications()
        XCTAssertEqual(0, scheduler.notificationsQueue().count)
        
        let calendar = Calendar.current

        
        let expectationTemp = expectation(description: "All Notifications scheduled")
        scheduler.getScheduledNotifications { (requests) in
            
            
            if let request = requests?[safe: 0] {
                if let request2 =  request.trigger as?  UNCalendarNotificationTrigger {
                    
                    var expectedTriggerTime =  calendar.dateComponents([.hour, .minute], from: triggerDate)
                    var actualTriggerTime =  calendar.dateComponents([.hour, .minute], from: (request2.nextTriggerDate())!)
                    
                    print("expected :" + triggerDate.debugDescription)
                    print("actual :" + request2.nextTriggerDate().debugDescription)
                    
                    XCTAssertEqual(expectedTriggerTime,actualTriggerTime)
                    
                    
                    expectationTemp.fulfill()
                    
                }}
            
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        
        
    }
    
    // Issue #15
    public func testDelayedNotificationFiringImmediatelyForDailyDelayedRepetition() {
        
        let triggerDate = Date().addingTimeInterval(3*24*60*60)
        let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notification Alert", alertBody: "You have successfully created a notification", date: triggerDate, repeats: .daily)
        
        let scheduler = DLNotificationScheduler()
        scheduler.scheduleNotification(notification: firstNotification)
        
        XCTAssertEqual(1, scheduler.notificationsQueue().count)
        scheduler.scheduleAllNotifications()
        XCTAssertEqual(0, scheduler.notificationsQueue().count)
        
        let calendar = Calendar.current

        
        let expectationTemp = expectation(description: "All Notifications scheduled")
        scheduler.getScheduledNotifications { (requests) in
            
            if let request = requests?[safe: 0]  {
                if let request2 =  request.trigger as?  UNCalendarNotificationTrigger {
                    
                    var expectedTriggerTime =  calendar.dateComponents([.hour, .minute], from: triggerDate)
                    var actualTriggerTime =  calendar.dateComponents([.hour, .minute], from: (request2.nextTriggerDate())!)
                    
                    print("expected :" + triggerDate.debugDescription)
                    print("actual :" + request2.nextTriggerDate().debugDescription)

                    XCTAssertEqual(expectedTriggerTime,actualTriggerTime)
                    
                    XCTAssertEqual(request2.nextTriggerDate()!.days(from: triggerDate), 1)
                    expectationTemp.fulfill()
                    
                    
                }}
            
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        
        
    }
    */
}

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
extension Date {

/// Returns the amount of days from another date
func days(from date: Date) -> Int {
    return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
}

}
