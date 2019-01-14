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
        XCTAssertEqual(0, scheduler.notificationsQueue().count)
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
