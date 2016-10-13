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
        sleep(1)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testWelcomeFlow() {
        let app = self.application

        clearData(app)

        handleWelcomeScreen(app)
        
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        
        selectFirstAccountOnthePortfolioScreen(app)

        //AccountTotalValue
        XCTAssert(app.staticTexts["$76,489.23"].exists)
        
        //Balances
        XCTAssert(app.tables.staticTexts["Individual**cct1"].exists)
        XCTAssert(app.tables.staticTexts["$2,408.12"].exists)
        XCTAssert(app.tables.staticTexts["$76,489.23 (22.84%)"].exists)

        //Positions
        let holdingsTitle = app.staticTexts["Individual**cct1 Holdings"]
        XCTAssert(holdingsTitle.exists)
        XCTAssert(app.tables.staticTexts["AAPL"].exists)
        XCTAssert(app.tables.staticTexts["1 shares"].exists)
        XCTAssert(app.tables.staticTexts["$103.34"].exists)
        XCTAssert(app.tables.staticTexts["$112.34"].exists)
        
        //Positions details
        app.tables.staticTexts["AAPL"].tap()
        XCTAssert(app.tables.staticTexts["Bid"].exists)
        XCTAssert(app.tables.staticTexts["Ask"].exists)
        XCTAssert(app.tables.staticTexts["Total Value"].exists)
        XCTAssert(app.tables.staticTexts["Total Return"].exists)
        XCTAssert(app.tables.staticTexts["Day"].exists)
    }
    
    func testFxWelcomeFlow() {
        let app = self.application

        clearData(app)
        
        handleWelcomeScreen(app)
        
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy FX Broker")
        
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy FX Broker")
        
        selectFirstAccountOnthePortfolioScreen(app)
        
        //AccountTotalValue
        XCTAssert(app.staticTexts["$9,163.00"].exists)
        
        //Fx Balances
        XCTAssert(app.tables.staticTexts["Account (F**cct1"].exists)
        XCTAssert(app.tables.staticTexts["$9,163.00"].exists)
        XCTAssert(app.tables.staticTexts["$1,900.00 (0%)"].exists)
        
        //Fx Summary
//        app.tables.staticTexts["Account (F**cct1 Summary"].exists
//        app.tables.staticTexts["$5.89"].exists
//        app.tables.staticTexts["$2,500"].exists
        
        //Fx Positions
        let holdingsTitle = app.staticTexts["Account (F**cct1 Holdings"]
        XCTAssert(holdingsTitle.exists)
        XCTAssert(app.tables.staticTexts["USD/JPY"].exists)
        XCTAssert(app.tables.staticTexts["490"].exists)
        XCTAssert(app.tables.staticTexts["$100.06"].exists)
        XCTAssert(app.tables.staticTexts["$0.00"].exists)
        
        //Positions details
        app.tables.staticTexts["USD/JPY"].tap()
        XCTAssert(app.tables.staticTexts["Bid"].exists)
        XCTAssert(app.tables.staticTexts["Ask"].exists)
        XCTAssert(app.tables.staticTexts["Spread"].exists)
        XCTAssert(!app.tables.staticTexts["Total Return"].exists)
        XCTAssert(!app.tables.staticTexts["Day"].exists)
        
    }

    func testPortfolioBypassWelcomeFlow() {
        let app = self.application

        clearData(app)

        handleWelcomeScreen(app)

        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")

        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")

        selectFirstAccountOnthePortfolioScreen(app)

        waitForElementToAppear(app.navigationBars["Portfolio"])

        app.buttons["Close"].tap()

        app.tables.staticTexts["LaunchPortfolio"].tap()

        waitForElementToAppear(app.navigationBars["Portfolio"])
    }

    func testSecurityQuestionFlow() {
        let app = self.application

        clearData(app)

        handleWelcomeScreen(app)

        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")

        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker", withUsername: "dummySecurity")

        waitForElementToAppear(app.alerts["Security Question"])

        let securityQuestionAlert = app.alerts["Security Question"]
        securityQuestionAlert.textFields[""].typeText("tradingticket")
        securityQuestionAlert.buttons["Submit"].tap()

        waitForElementToAppear(app.navigationBars["Portfolio"])
    }

    private func clearData(app: XCUIApplication) {
        let deleteLinkedBrokersText = app.tables.staticTexts["DeleteLinkedBrokers"]
        waitForElementToBeHittable(deleteLinkedBrokersText)
        deleteLinkedBrokersText.tap()
    }
    
    private func handleWelcomeScreen(app: XCUIApplication) {
        let launchPortfolioText = app.tables.staticTexts["LaunchPortfolio"]
        waitForElementToBeHittable(launchPortfolioText)
        launchPortfolioText.tap()

        waitForElementToAppear(app.navigationBars["Welcome"])
        XCTAssert(app.otherElements.staticTexts["Link your broker account"].exists)
        app.buttons["Get Started Now"].tap()
    }
    
    private func selectBrokerFromTheBrokerSelectionScreen(app: XCUIApplication, longBrokerName: String) {
        XCTAssert(app.navigationBars["Select Your Broker"].exists)

        let ezLoadingActivity = app.staticTexts["Loading Brokers"]
        waitForElementToDisappear(ezLoadingActivity)

        XCTAssert(app.tables.cells.count > 0)
        
        let dummyBrokerStaticText = app.tables.staticTexts[longBrokerName]
        XCTAssert(dummyBrokerStaticText.exists)
        
        app.tables.staticTexts[longBrokerName].tap()
    }
    
    private func submitValidCredentialsOnTheLoginScreen(app: XCUIApplication, longBrokerName: String, withUsername username: String = "dummy") {
        XCTAssert(app.navigationBars["Login"].exists)
        XCTAssert(app.staticTexts["Log in to \(longBrokerName)"].exists)
        
        let usernameTextField = app.textFields["\(longBrokerName) Username"]
        let passwordTextField = app.secureTextFields["\(longBrokerName) Password"]
        
        waitForElementToHaveKeyboardFocus(usernameTextField)
        waitForElementNotToHaveKeyboardFocus(passwordTextField)
        usernameTextField.typeText(username)
        app.buttons["Next"].tap()

        waitForElementToHaveKeyboardFocus(passwordTextField)
        passwordTextField.typeText("dummy")
        app.buttons["Done"].tap()
        
        let activityIndicator = app.activityIndicators.element
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
    }
    
    private func selectFirstAccountOnthePortfolioScreen(app: XCUIApplication) {
        waitForElementToAppear(app.navigationBars["Portfolio"])

        var ezLoadingActivity = app.staticTexts["Authenticating"]
        waitForElementToDisappear(ezLoadingActivity, withinSeconds: 10)

        ezLoadingActivity = app.staticTexts["Retreiving Account Summary"]
        waitForElementToDisappear(ezLoadingActivity)
        
        let tableView = app.tables.elementBoundByIndex(0)
        XCTAssertTrue(tableView.cells.count > 0)
        
        let firstCell = tableView.cells.elementBoundByIndex(1) // index 0 is header
        XCTAssertTrue(firstCell.images["selectorLabel"].exists)
    }

//    func testPortfolioUserHasAccountFlow() {
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
//    }
}
