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

        // See Welcome screen
        app.tables.staticTexts["LaunchSdk"].tap()
        XCTAssert(app.navigationBars["Welcome"].exists)
        XCTAssert(app.otherElements.staticTexts["Link your broker account"].exists)
        app.buttons["Get Started Now"].tap()

        // Select a broker from the Broker Selection screen
        XCTAssert(app.navigationBars["Select Your Broker"].exists)


        var ezLoadingActivity = app.staticTexts["Loading Brokers"]
        waitForAsyncElementToDisappear(ezLoadingActivity)

        XCTAssert(app.tables.cells.count > 0)

        let dummyBrokerStaticText = app.tables.staticTexts["Dummy Broker"]
        XCTAssert(dummyBrokerStaticText.exists)

        app.tables.staticTexts["Dummy Broker"].tap()

        // Submit valid credentials on the Login screen
        XCTAssert(app.navigationBars["Login"].exists)
        XCTAssert(app.staticTexts["Login in to Dummy Broker"].exists)

        let usernameTextField = app.textFields["Dummy Broker Username"]
        let passwordTextField = app.secureTextFields["Dummy Broker Password"]

        XCTAssert(usernameTextField.exists)
        XCTAssert(passwordTextField.exists)

        usernameTextField.typeText("dummy")
        passwordTextField.tap()
        passwordTextField.typeText("dummy")

        let activityIndicator = app.activityIndicators.element
        waitForAsyncElementNotToBeHittable(activityIndicator)

        app.buttons["Link Account"].tap()

        // Select an account on the Accounts screen
        waitForAsyncElementToAppear(app.navigationBars["Portfolio"])

        ezLoadingActivity = app.staticTexts["Authenticating"]
        waitForAsyncElementToDisappear(ezLoadingActivity)

        ezLoadingActivity = app.staticTexts["Retreiving Account Summary"]
        waitForAsyncElementToDisappear(ezLoadingActivity)

        XCTAssert(app.tables.cells.count > 0)

        //Balances
        app.tables.staticTexts["Dummy *cct1"].exists
        app.tables.staticTexts["$2408.12"].exists
        app.tables.staticTexts["$76489.23 (22.84%)"].exists

        //Positions
        app.tables.staticTexts["Dummy *cct1 Holdings"].exists
        app.tables.staticTexts["AAPL (1)"].exists
        app.tables.staticTexts["$103.34"].exists
        app.tables.staticTexts["$112.34"].exists
    }

    func testPortfolioUserHasAccountFlow() {
//        // Launch ticket
//        let app = self.application
//        
//        // See Portfolio screen
//        app.tables.staticTexts["LaunchPortfolio"].tap()
//        XCTAssert(app.navigationBars["Portfolio"].exists)
//        
//        var ezLoadingActivity = app.staticTexts["Authenticating"]
//        waitForAsyncElementToDisappear(ezLoadingActivity)
//        
//        ezLoadingActivity = app.staticTexts["Retreiving Account Summary"]
//        waitForAsyncElementToDisappear(ezLoadingActivity)
//        
//        XCTAssert(app.tables.cells.count > 0)
//        
//        //Balances
//        app.tables.staticTexts["Dummy *cct1"].exists
//        app.tables.staticTexts["$2408.12"].exists
//        app.tables.staticTexts["$76489.23 (22.84%)"].exists
//        
//        //Positions
//        app.tables.staticTexts["Dummy *cct1 Holdings"].exists
//        app.tables.staticTexts["AAPL (1)"].exists
//        app.tables.staticTexts["$103.34"].exists
//        app.tables.staticTexts["$112.34"].exists
    }
}