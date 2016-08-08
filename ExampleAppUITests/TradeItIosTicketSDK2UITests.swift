import XCTest
import TradeItIosTicketSDK2

class TradeItIosTicketSdk2UITests: XCTestCase {
    var application: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        self.application = XCUIApplication()
        self.application.launchArguments.append("isUITesting")
        self.application.launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testWelcomeFlow() {
        // Launch ticket
        let app = self.application

        // Welcome screen
        app.tables.staticTexts["LaunchSdk"].tap()
        XCTAssert(app.navigationBars["Welcome"].exists)
        XCTAssert(app.otherElements.staticTexts["Link your broker account"].exists)
        app.buttons["Get Started Now"].tap()

        // Broker selection screen
        XCTAssert(app.navigationBars["Select Your Broker"].exists)

        var activityIndicator = app.activityIndicators.element
        XCTAssertTrue(activityIndicator.exists)
        waitForAsyncElementNotToBeHittable(activityIndicator)

        XCTAssert(app.tables.cells.count > 0)

        let dummyBrokerStaticText = app.tables.staticTexts["Dummy Broker"]
        XCTAssert(dummyBrokerStaticText.exists)

        app.tables.staticTexts["Dummy Broker"].tap()

        //Login screen
        XCTAssert(app.navigationBars["Login"].exists)
        XCTAssert(app.staticTexts["Login in to Dummy Broker"].exists)

        XCTAssert(app.textFields["BROKER_USERNAME_ID"].exists)
        XCTAssert(app.secureTextFields["BROKER_PASSWORD_ID"].exists)

        XCTAssertTrue(app.textFields["BROKER_USERNAME_ID"].placeholderValue == "Dummy Broker Username")
        XCTAssertTrue(app.secureTextFields["BROKER_PASSWORD_ID"].placeholderValue == "Dummy Broker Password")

        app.textFields["BROKER_USERNAME_ID"].typeText("dummy")
        app.secureTextFields["BROKER_PASSWORD_ID"].tap()
        app.secureTextFields["BROKER_PASSWORD_ID"].typeText("dummy")

        activityIndicator = app.activityIndicators.element
        waitForAsyncElementNotToBeHittable(activityIndicator)
        app.buttons["Link Account"].tap()

        //Accounts screen
        XCTAssert(app.navigationBars["Accounts"].exists)
    }
}