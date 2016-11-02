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
        handleWelcomeScreen(app, launchOption: "launchTrading")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        //symbol Search screen
        symbolSearch(app, symbol: "GE")
        let activityIndicator = app.activityIndicators.element
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
        XCTAssertTrue(app.tables.element.cells.element(boundBy: 0).exists)
        waitForElementToBeHittable(app.tables.element.cells.element(boundBy: 0))
        app.tables.element.cells.element(boundBy: 0).tap()
        //Trade Screen
        waitForElementToAppear(app.navigationBars["Trade"])
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
        XCTAssert(app.buttons["Individual**cct1"].exists)
        XCTAssert(app.staticTexts["$2,408.12"].exists)
        XCTAssert(app.buttons["GE"].exists)
        testTradeScreenValues(app)
        //Place 1 GE stop Limit order gtc
        fillOrder(app, orderAction: "Buy", orderType: "stopLimit", limitPrice: "25", stopPrice: "30", share: "1", expiration: "gtc")
        waitForElementToBeHittable(app.buttons["Preview Order"])
        app.buttons["Preview Order"].tap()
        //Review screen
        waitForElementToAppear(app.navigationBars["Review"])
        testPreviewValues(app, symbol: "GE", limitPrice: "25", stopPrice: "30", quantity: "1")
        waitForElementToBeHittable(app.buttons["Place Order"])
        app.buttons["Place Order"].tap()
        //Confirmation screen
        waitForElementToAppear(app.navigationBars["Confirmation"])
        testConfirmation(app)
    }
    
    func testTradingFromPortfolioFlow(){
        clearData(app)
        handleWelcomeScreen(app, launchOption: "launchPortfolio")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        waitForElementToAppear(app.navigationBars["Portfolio"])
        let username = "Individual**cct1"
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
        waitForElementToAppear(app.navigationBars["Trade"])
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
        XCTAssert(app.buttons[username].exists)
        XCTAssert(app.staticTexts["$2,408.12"].exists)
        XCTAssert(app.buttons["GE"].exists)
        testTradeScreenValues(app)
        //Place 1 GE stop Limit order gtc
        fillOrder(app, orderAction: "Buy", orderType: "stopLimit", limitPrice: "25", stopPrice: "30", share: "1", expiration: "gtc")
        waitForElementToBeHittable(app.buttons["Preview Order"])
        app.buttons["Preview Order"].tap()
        //Review screen
        waitForElementToAppear(app.navigationBars["Review"])
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
        waitForElementToAppear(app.navigationBars["Trade"])
    }
    
    func testTradingFromPortfolioPositionFlow(){
        clearData(app)
        handleWelcomeScreen(app, launchOption: "launchPortfolio")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        waitForElementToAppear(app.navigationBars["Portfolio"])
        let username = "Individual**cct1"
        XCTAssert(app.staticTexts[username].exists)
        XCTAssert(app.tables.staticTexts["AAPL"].exists)
        app.tables.staticTexts["AAPL"].tap()
        waitForElementToAppear(app.tables.buttons["BUY"])
        waitForElementToAppear(app.tables.buttons["SELL"])
        app.tables.buttons["BUY"].tap()
        waitForElementToAppear(app.navigationBars["Trade"])
        XCTAssert(app.buttons["AAPL"].exists)
        XCTAssert(app.buttons[username].exists)
        XCTAssert(app.buttons["Buy"].exists)
        app.navigationBars["Trade"].buttons["Close"].tap()
        waitForElementToAppear(app.navigationBars["Portfolio"])
        XCTAssert(app.tables.staticTexts["AAPL"].exists)
        app.tables.staticTexts["AAPL"].tap()
        waitForElementToAppear(app.tables.buttons["BUY"])
        waitForElementToAppear(app.tables.buttons["SELL"])
        app.tables.buttons["SELL"].tap()
        waitForElementToAppear(app.navigationBars["Trade"])
        XCTAssert(app.buttons["AAPL"].exists)
        XCTAssert(app.buttons[username].exists)
        XCTAssert(app.buttons["Sell"].exists)
    }
}
