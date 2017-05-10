import XCTest
import TradeItIosTicketSDK2

class TradeItSDKUITestsAuthFlow: XCTestCase {
    var app: XCUIApplication!
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("isUITesting")
        app.launch()
        sleep(1)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSecurityQuestionFlow() {
        clearData(app)
        handleWelcomeScreen(app, launchOption: "launchPortfolio")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker", username: "dummySecurity")
        
        //Test with wrong security answer first, then the correct one
        waitForElementToAppear(app.alerts["Security Question"])
        let securityQuestionAlert = app.alerts["Security Question"]
        securityQuestionAlert.textFields[""].typeText("123")
        securityQuestionAlert.buttons["Submit"].tap()
        waitForElementToAppear(securityQuestionAlert)
        securityQuestionAlert.textFields[""].typeText("")
        securityQuestionAlert.buttons["Submit"].tap()
        waitForElementToAppear(app.alerts["Could Not Login"])
        app.alerts["Could Not Login"].buttons["OK"].tap()
        app.buttons["Link Broker"].tap()
        waitForElementToAppear(securityQuestionAlert)
        securityQuestionAlert.textFields[""].typeText("tradingticket")
        securityQuestionAlert.buttons["Submit"].tap()
        waitForElementToAppear(app.navigationBars["Portfolio"])
    }
    
    func testDummyOptionFlow(){
        clearData(app)
        handleWelcomeScreen(app, launchOption: "launchPortfolio")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker", username: "dummyOption")
        
        //Test for option pop-up, wrong answer first, then the correct one
        waitForElementToAppear(app.alerts["Security Question"])
        let alert = app.alerts["Security Question"]
        XCTAssert(alert.buttons["Cancel"].exists)
        XCTAssert(alert.buttons["option 1"].exists)
        XCTAssert(alert.buttons["option 2"].exists)
        alert.buttons["option 2"].tap()
        waitForElementToAppear(alert)
        alert.buttons["Cancel"].tap()
        waitForElementToAppear(app.alerts["Authentication failed"])
        XCTAssert(app.alerts["Authentication failed"].staticTexts["The security question was canceled."].exists)
        app.alerts["Authentication failed"].buttons["OK"].tap()
        waitForElementToDisappear(app.alerts["Authentication failed"])
        app.buttons["Link Broker"].tap()
        waitForElementToAppear(alert)
        alert.buttons["option 2"].tap()
        waitForElementToAppear(alert)
        alert.buttons["option 1"].tap()
        waitForElementToAppear(app.navigationBars["Portfolio"])
    }
}
