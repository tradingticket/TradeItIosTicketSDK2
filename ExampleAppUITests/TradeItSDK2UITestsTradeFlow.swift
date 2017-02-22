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

    func testTradeFlow() {
        
        //***********************************//
        //* testTradingWithWelcomeSingleAcc *//
        //***********************************//
        clearData(app)
        handleWelcomeScreen(app, launchOption: "launchTrading")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        //symbol Search screen
        symbolSearch(app, symbol: "GE")
        var activityIndicator = app.activityIndicators.element
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
        waitForElementToAppear(app.tables.staticTexts["GE"])
        app.tables.staticTexts["GE"].tap()
        //Trade Screen
        waitForElementToAppear(app.navigationBars["Trade"])
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
        let accountName = "Individual**cct1"
        waitForElementToAppear(app.buttons[accountName])
        waitForElementToAppear(app.buttons["GE"])
        XCTAssert(app.staticTexts["$2,408.12"].exists)
        testTradeScreenValues(app)
        //Place 1 GE stop Limit order gtc
        fillOrder(app, orderAction: "Buy", orderType: "stopLimit", limitPrice: "25", stopPrice: "30", quantity: "1", expiration: "gtc")
        waitForElementToBeHittable(app.buttons["Preview Order"])
        app.buttons["Preview Order"].tap()
        //Review screen
        waitForElementToAppear(app.navigationBars["Preview"])
        testPreviewValues(app, symbol: "GE", limitPrice: "25", stopPrice: "30", quantity: "1")
        waitForElementToBeHittable(app.buttons["Place Order"])
        app.buttons["Place Order"].tap()
        //Confirmation screen
        waitForElementToAppear(app.navigationBars["Confirmation"])
        testConfirmation(app)
        app.buttons["Close"].tap()
        
        //***********************************//
        //* testTradingFromPortfolioFlow ****//
        //***********************************//
        let launchPortfolioText = app.tables.staticTexts["launchPortfolio"]
        waitForElementToBeHittable(launchPortfolioText)
        launchPortfolioText.tap()
        waitForElementToAppear(app.navigationBars["Portfolio"])
        let username = "Individual**cct1"
        XCTAssert(app.staticTexts[username].exists)
        XCTAssert(app.buttons["Trade"].exists)
        app.buttons["Trade"].tap()
        symbolSearch(app, symbol: "GE")
        activityIndicator = app.activityIndicators.element
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
        waitForElementToAppear(app.tables.staticTexts["GE"])
        app.tables.staticTexts["GE"].tap()
        //Trade Screen
        waitForElementToAppear(app.navigationBars["Trade"])
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
        waitForElementToAppear(app.buttons[username])
        waitForElementToAppear(app.buttons["GE"])
        XCTAssert(app.staticTexts["$2,408.12"].exists)
        testTradeScreenValues(app)
        //Place 1 GE stop Limit order gtc
        fillOrder(app, orderAction: "Buy", orderType: "stopLimit", limitPrice: "25", stopPrice: "30", quantity: "1", expiration: "gtc")
        waitForElementToBeHittable(app.buttons["Preview Order"])
        app.buttons["Preview Order"].tap()
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
        symbolSearch(app, symbol: "AAPL")
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
        waitForElementToAppear(app.tables.staticTexts["AAPL"])
        app.tables.staticTexts["AAPL"].tap()
        waitForElementToAppear(app.navigationBars["Trade"])
        app.buttons["Close"].tap()
        app.buttons["Close"].tap()

        //****************************************//
        //* testTradingFromPortfolioPositionFlow *//
        //****************************************//
        waitForElementToBeHittable(launchPortfolioText)
        launchPortfolioText.tap()
        waitForElementToAppear(app.navigationBars["Portfolio"])
        waitForElementToAppear(app.staticTexts[accountName])
        waitForElementToAppear(app.tables.staticTexts["AAPL"])
        app.tables.staticTexts["AAPL"].tap()
        waitForElementToAppear(app.tables.buttons["BUY"])
        waitForElementToAppear(app.tables.buttons["SELL"])
        app.tables.buttons["BUY"].tap()
        waitForElementToAppear(app.navigationBars["Trade"])
        waitForElementToAppear(app.buttons[accountName])
        XCTAssert(app.buttons["AAPL"].exists)
        XCTAssert(app.buttons["Buy"].exists)
        app.navigationBars["Trade"].buttons["Close"].tap()
        waitForElementToAppear(app.navigationBars["Portfolio"])
        XCTAssert(app.tables.staticTexts["AAPL"].exists)
        app.tables.staticTexts["AAPL"].tap()
        waitForElementToAppear(app.tables.buttons["BUY"])
        waitForElementToAppear(app.tables.buttons["SELL"])
        app.tables.buttons["SELL"].tap()
        waitForElementToAppear(app.navigationBars["Trade"])
        waitForElementToAppear(app.buttons[accountName])
        XCTAssert(app.buttons["AAPL"].exists)
        XCTAssert(app.buttons["Sell"].exists)
    }
}
