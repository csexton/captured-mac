//
//  CapturedUITests.swift
//  CapturedUITests
//
//  Created by Christopher Sexton on 11/20/15.
//  Copyright © 2015 Christopher Sexton. All rights reserved.
//

import XCTest

class CapturedUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
      
      let app = XCUIApplication()
      app.typeKey(",", modifierFlags:.Command)
      app.windows["Captured"].toolbars.buttons["Accounts"].click()
      
      let accountsWindow = app.windows["Accounts"]
      accountsWindow.buttons["Add Account"].click()
      // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
      accountsWindow.tables.cells.containingType(.Button, identifier:"Edit").element.typeText("Tester")
      accountsWindow.sheets.buttons["Save"].click()
      //Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
