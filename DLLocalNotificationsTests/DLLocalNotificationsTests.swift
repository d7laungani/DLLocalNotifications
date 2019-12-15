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
        
        scheduler.cancelAlllNotifications()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        scheduler.cancelAlllNotifications()
    }
    
    
    func testSingleFireNotification() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // The date you would like the notification to fire at
        let triggerDate = Date().addingTimeInterval(300)
        
        let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notification Alert", alertBody: "You have successfully created a notification", date: triggerDate, repeats: .none)
        
        scheduler.scheduleNotification(notification: firstNotification)
        XCTAssertEqual(1, scheduler.notificationsQueue().count)
        scheduler.scheduleAllNotifications()
        XCTAssertEqual(0, scheduler.notificationsQueue().count)
        XCTAssertEqual(true, firstNotification.scheduled)
    
    }
    
    func testRepeatingNotificationMinute() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // The date you would like the notification to fire at
        let triggerDate = Date().addingTimeInterval(0)
        
        let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notification Alert", alertBody: "You have successfully created a notification", date: triggerDate, repeats: .minute)

        scheduler.scheduleNotification(notification: firstNotification)
        XCTAssertEqual(1, scheduler.notificationsQueue().count)
        scheduler.scheduleAllNotifications()
        XCTAssertEqual(0, scheduler.notificationsQueue().count)
        XCTAssertEqual(true, firstNotification.scheduled)
        
        let expectationTemp = expectation(description: "Next Trigger Date Does not match expectation")

       
        scheduler.getScheduledNotification(with: firstNotification.identifier!){ (request) -> Void in
            if let request = request{
                let trigger =  request.trigger as?  UNCalendarNotificationTrigger

                XCTAssertEqual(triggerDate.addingTimeInterval(60).removeSeconds().timeIntervalSince1970, (trigger?.nextTriggerDate()?.removeSeconds().timeIntervalSince1970)!, accuracy: 0.001)

                expectationTemp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        
        
    }
    
    func testRepeatingNotificationHour() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // The date you would like the notification to fire at
        let triggerDate = Date().addingTimeInterval(0)
        
        let firstNotification = DLNotification(identifier: "hourlyNotification", alertTitle: "Notification Alert", alertBody: "You have successfully created a notification", date: triggerDate, repeats: .hourly)
        
        scheduler.scheduleNotification(notification: firstNotification)
        XCTAssertEqual(1, scheduler.notificationsQueue().count)
        scheduler.scheduleAllNotifications()
        XCTAssertEqual(0, scheduler.notificationsQueue().count)
        XCTAssertEqual(true, firstNotification.scheduled)
        
        let expectationTemp = expectation(description: "Next Trigger Date Does not match expectation")
        scheduler.getScheduledNotification(with: firstNotification.identifier!){ (request) -> Void in
            if let request = request{
                let trigger =  request.trigger as?  UNCalendarNotificationTrigger
                
                XCTAssertEqual(triggerDate.addingTimeInterval(3600).removeSeconds().timeIntervalSince1970, (trigger?.nextTriggerDate()?.removeSeconds().timeIntervalSince1970)!, accuracy: 0.001)
                
                expectationTemp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 20, handler: nil)
        
        
        
    }
    
  
    func testNotificationCancel() {
        let triggerDate = Date().addingTimeInterval(300)
        
        let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notification Alert", alertBody: "You have successfully created a notification", date: triggerDate, repeats: .none)
        
        scheduler.scheduleNotification(notification: firstNotification)
        XCTAssertEqual(1, scheduler.notificationsQueue().count)
        scheduler.scheduleAllNotifications()
        XCTAssertEqual(0, scheduler.notificationsQueue().count)
        XCTAssertEqual(true, firstNotification.scheduled)
        scheduler.cancelNotification(notification: firstNotification)
        XCTAssertEqual(false, firstNotification.scheduled)
        
        let expectationTemp = expectation(description: "Removed from apple notification queue")
    
        scheduler.getScheduledNotifications { (requests) in
            XCTAssertEqual(0, requests?.count)
            expectationTemp.fulfill()
        }
        
        
        waitForExpectations(timeout: 10, handler: nil)
        
        
       
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    // Regression tests
    
    // Issue #26
    func testSettingALaunchImage() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // The date you would like the notification to fire at
        let triggerDate = Date().addingTimeInterval(20)
        
        let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notification Alert", alertBody: "You have successfully created a notification", date: triggerDate, repeats: .none)
        
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
    
        let expectationTemp = expectation(description: "All Notifications scheduled")
        scheduler.getScheduledNotifications { (requests) in
            XCTAssertEqual(4, requests?.count)
            expectationTemp.fulfill()
        }
    
        waitForExpectations(timeout: 10, handler: nil)

        
    }
    
    // Issue #15
    public func testDelayedNotificationFiringImmediatelyForMinuteRepetition() {
        
        let triggerDate = Date().addingTimeInterval(600)
        let firstNotification = DLNotification(identifier: "firstNotification", alertTitle: "Notification Alert", alertBody: "You have successfully created a notification", date: triggerDate, repeats: .minute)
        
        let scheduler = DLNotificationScheduler()
        scheduler.scheduleNotification(notification: firstNotification)
        
        XCTAssertEqual(1, scheduler.notificationsQueue().count)
        scheduler.scheduleAllNotifications()
        XCTAssertEqual(0, scheduler.notificationsQueue().count)
        
        let expectationTemp = expectation(description: "All Notifications scheduled")
        scheduler.getScheduledNotifications { (requests) in
            
            let request = requests![0]
            if let request2 =  request.trigger as?  UNCalendarNotificationTrigger {
                
                        XCTAssertEqual(Calendar.current.component(.hour, from:triggerDate), Calendar.current.component(.hour, from: request2.nextTriggerDate()!))
                        
                         XCTAssertEqual(Calendar.current.component(.minute, from:triggerDate), Calendar.current.component(.minute, from: request2.nextTriggerDate()!))
                        
                        print("Calendar notification: \(request2.nextTriggerDate().debugDescription) and repeats")
                
                
                
            }
        
            expectationTemp.fulfill()
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
        
        let expectationTemp = expectation(description: "All Notifications scheduled")
        scheduler.getScheduledNotifications { (requests) in
            
            let request = requests![0]
            if let request2 =  request.trigger as?  UNCalendarNotificationTrigger {
                
                XCTAssertEqual(Calendar.current.component(.hour, from:triggerDate), Calendar.current.component(.hour, from: request2.nextTriggerDate()!))
                
                XCTAssertEqual(Calendar.current.component(.minute, from:triggerDate), Calendar.current.component(.minute, from: request2.nextTriggerDate()!))
                
                print("Calendar notification: \(request2.nextTriggerDate().debugDescription) and repeats")
                
                
                
            }
            
            expectationTemp.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        
        
    }
    
}
