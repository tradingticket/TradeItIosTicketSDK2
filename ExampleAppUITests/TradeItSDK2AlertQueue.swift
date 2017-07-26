import XCTest
import TradeItIosTicketSDK2

class TradeItSDK2AlertQueue: XCTestCase{
    var app: XCUIApplication!
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("isUITesting")
        app.launch()
        sleep(1)
    }
    
    func testAlertQueue(){
        let advancedOptions = app.tables.staticTexts["Advanced options"]
        scrollDownTo(app, element: advancedOptions)
        advancedOptions.tap()
        
        let launchAlertQueue = app.tables.staticTexts["Alert Queue"]
        scrollDownTo(app, element: launchAlertQueue)
        launchAlertQueue.tap()
        
        let alert1 = app.alerts["Alert 1"]
        waitForElementToAppear(alert1)
        alert1.buttons["OK"].tap()
        
        let securityQuestion = app.alerts["Security Question"]
        waitForElementToAppear(securityQuestion)
        securityQuestion.buttons["Submit"].tap()
        
        let alert2 = app.alerts["Alert 2"]
        waitForElementToAppear(alert2)
        alert2.buttons["OK"].tap()
    }
}
