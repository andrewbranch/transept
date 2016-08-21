//
//  AuthenticationUITest.swift
//  FUMC
//
//  Created by Andrew Branch on 8/20/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import XCTest

class AuthenticationUITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launchEnvironment = ["UITEST": "true"]
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.buttons["Reset Access Requests"].tap()
        app.tabBars.buttons["Directory"].tap()
        usleep(10000)
        app.buttons["Reset Facebook"].tap()
        app.buttons["Mock Digits Unknown"].tap()
        app.buttons["Get Access"].tap()
        app.buttons["Log in with Facebook"].tap()
        
        let webViewsQuery = app.webViews
        if webViewsQuery.textFields["Email or Phone"].exists {
            webViewsQuery.textFields["Email or Phone"].tap()
            webViewsQuery.textFields["Email or Phone"].typeText("hahtdrq_zuckersen_1471729971@tfbnw.net")
            webViewsQuery.secureTextFields["Password"].tap()
            webViewsQuery.secureTextFields["Password"].typeText(Env.get("FB_TEST_USER_PASSWORD")!)
            // press log in
        } else {
            let button = webViewsQuery.buttons["OK"]
            let pageLoaded = NSPredicate(format: "exists == 1")
            expectationForPredicate(pageLoaded, evaluatedWithObject: button, handler: nil)
            waitForExpectationsWithTimeout(5, handler: nil)
            button.tap()
        }
        
        let pendingWithIdentityTextView = app.staticTexts["Your request is being reviewed."]
        XCTAssert(pendingWithIdentityTextView.hittable)
    }
    
}
