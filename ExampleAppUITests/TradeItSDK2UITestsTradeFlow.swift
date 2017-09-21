import XCTest
import TradeItIosTicketSDK2

class TradeItSDK2UITestsTradeFlow: XCTestCase {
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

    func testTradingWithWelcomeSingleAcc() {
        clearData(app)
        handleWelcomeScreen(app, launchOption: "Trading")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        completeOauthScreen(app)
        //symbol Search screen
        symbolSearch(app, symbol: "GE")
        let activityIndicator = app.activityIndicators.element
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
        XCTAssertTrue(app.tables.element.cells.element(boundBy: 0).exists)
        waitForElementToBeHittable(app.tables.element.cells.element(boundBy: 0))
        app.tables.element.cells.element(boundBy: 0).tap()
        //Trade Screen
        waitForElementToAppear(app.navigationBars["Buy GE"])
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
        XCTAssert(app.buttons["Individual***001"].exists)
        XCTAssert(app.tables.staticTexts["Buying Power: $2,408.12"].exists)
        XCTAssert(app.buttons["GE"].exists)
        testTradeScreenValues(app)
        //Place 1 GE stop Limit order gtc
        fillOrder(app, orderAction: "Buy", orderType: "stopLimit", limitPrice: "25", stopPrice: "30", quantity: "1", expiration: "gtc")
        app.buttons["Done"].tap()
        waitForElementToBeHittable(app.buttons["Preview order"])
        app.buttons["Preview order"].tap()
        //Review screen
        waitForElementToAppear(app.navigationBars["Preview"])
        testPreviewValues(app, symbol: "GE", limitPrice: "25", stopPrice: "30", quantity: "1")
        waitForElementToBeHittable(app.buttons["Place Order"])
        app.buttons["Place Order"].tap()
        //Confirmation screen
        waitForElementToAppear(app.navigationBars["Confirmation"])
        testConfirmation(app)
    }
    
    func testTradingFromPortfolioFlow(){
        clearData(app)
        handleWelcomeScreen(app, launchOption: "Portfolio")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        completeOauthScreen(app)
        waitForElementToAppear(app.navigationBars["Portfolio"])
        selectAccountOnPortfolioScreen(app, rowNum: 3)
        let username = "Individual***001"
        XCTAssert(app.staticTexts[username].exists)
        XCTAssert(app.buttons["Trade"].exists)
        app.buttons["Trade"].tap()
        symbolSearch(app, symbol: "GE")
        let activityIndicator = app.activityIndicators.element
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
        XCTAssertTrue(app.tables.element.cells.element(boundBy: 0).exists)
        waitForElementToBeHittable(app.tables.element.cells.element(boundBy: 0))
        app.tables.element.cells.element(boundBy: 0).tap()
        //Trade Screen
        waitForElementToAppear(app.navigationBars["Buy GE"])
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
        waitForElementToAppear(app.buttons[username])
        XCTAssert(app.staticTexts["Buying Power: $2,408.12"].exists)
        waitForElementToAppear(app.buttons["GE"])
        testTradeScreenValues(app)
        //Place 1 GE stop Limit order gtc
        fillOrder(app, orderAction: "Buy", orderType: "stopLimit", limitPrice: "25", stopPrice: "30", quantity: "1", expiration: "gtc")
        app.buttons["Done"].tap()
        waitForElementToBeHittable(app.buttons["Preview order"])
        app.buttons["Preview order"].tap()
        // Preview screen
        waitForElementToAppear(app.navigationBars["Preview"])
        testPreviewValues(app, symbol: "GE", limitPrice: "25", stopPrice: "30", quantity: "1")
        waitForElementToBeHittable(app.buttons["Place Order"])
        app.buttons["Place Order"].tap()
        //Confirmation screen
        waitForElementToAppear(app.navigationBars["Confirmation"])
        testConfirmation(app)
        app.buttons["Trade Again"].tap()
        waitForElementToAppear(app.navigationBars["Search"])
        symbolSearch(app, symbol: "APPL")
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
        XCTAssertTrue(app.tables.element.cells.element(boundBy: 0).exists)
        waitForElementToBeHittable(app.tables.element.cells.element(boundBy: 0))
        app.tables.element.cells.element(boundBy: 0).tap()
        waitForElementToAppear(app.navigationBars["Buy AAPL"])
    }
    
    func testTradingFromPortfolioPositionFlow(){
        clearData(app)
        handleWelcomeScreen(app, launchOption: "Portfolio")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        completeOauthScreen(app)
        waitForElementToAppear(app.navigationBars["Portfolio"])
        selectAccountOnPortfolioScreen(app, rowNum: 3)
        let username = "Individual***001"
        XCTAssert(app.staticTexts[username].exists)
        waitForElementToAppear(app.tables.staticTexts["AAPL"])
        app.tables.staticTexts["AAPL"].tap()
        waitForElementToAppear(app.tables.buttons["BUY"])
        waitForElementToAppear(app.tables.buttons["SELL"])
        app.tables.buttons["BUY"].tap()
        waitForElementToAppear(app.navigationBars["Buy AAPL"])
        XCTAssert(app.buttons["AAPL"].exists)
        waitForElementToAppear(app.buttons[username])
        XCTAssert(app.buttons["Buy"].exists)
        app.navigationBars["Buy AAPL"].buttons["Close"].tap()
        waitForElementToAppear(app.navigationBars["Dummy"])
        XCTAssert(app.tables.staticTexts["AAPL"].exists)
        app.tables.buttons["SELL"].tap()
        waitForElementToAppear(app.navigationBars["Sell AAPL"])
        XCTAssert(app.buttons["AAPL"].exists)
        waitForElementToAppear(app.buttons[username])
        XCTAssert(app.buttons["Sell"].exists)
    }
}
