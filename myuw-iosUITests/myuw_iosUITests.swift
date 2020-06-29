//
//  myuw_testUITests.swift
//  myuw-testUITests
//
//  Created by Charlon Palacay on 7/30/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import XCTest

class myuw_iosUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWeblogin() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.launch()
        
        // TEST: weblogin is displayed on initial load... prompting user to sign in
        let userNetidString = app.staticTexts["usernetid"]
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: userNetidString, handler: nil)

        waitForExpectations(timeout: 5, handler: nil)
        
        let fullScreenshot = XCUIScreen.main.screenshot()
        let screenshot = XCTAttachment(screenshot: fullScreenshot)
        screenshot.lifetime = .keepAlways
        // if we don't set lifetime to .keepAlways, Xcode will delete the image if the test passes.

        add(screenshot)
        
        XCTAssert(userNetidString.exists)
        
        
    }

}
