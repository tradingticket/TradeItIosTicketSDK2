import XCTest
import TradeItIosTicketSDK2

class TradeItSDK2UITestsPortfolioFlow: XCTestCase {
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
    
    //******************//
    //* Portfolio Flow *//
    //******************//
    func testPortfolioWithWelcomeSingleAcc() {
        clearData(app)
        handleWelcomeScreen(app, launchOption: "Portfolio")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        completeOauthScreen(app)
        selectAccountOnPortfolioScreen(app, rowNum: 2)
        testPortfolioValues(app, brokerName: "Dummy")
    }
    
    func testPortfolioWithoutWelcome(){
        clearData(app)
        handleWelcomeScreen(app, launchOption: "Portfolio")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        completeOauthScreen(app)
        app.navigationBars["Portfolio"].buttons["Close"].tap()
        waitForElementToBeHittable(app.tables.staticTexts["Portfolio"])
        app.tables.staticTexts["Portfolio"].tap()
        waitForElementToAppear(app.navigationBars["Portfolio"])
        waitForElementToAppear(app.tables.staticTexts["Individual**0001"])
    }
    
    func testPortfolioWithWelcomeMultiAcc(){
        clearData(app)
        handleWelcomeScreen(app, launchOption: "Portfolio")
        
        //log into dummyMultiple
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker", username: "dummyMultiple")
        completeOauthScreen(app)
        selectAccountOnPortfolioScreen(app, rowNum: 1)
        
        //log into dummy acc
        app.buttons["Manage"].tap()
        app.tables.staticTexts["Add Account"].tap()
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        completeOauthScreen(app)
        
        //back to portfolio view
        app.navigationBars["Accounts"].buttons["Portfolio"].tap()
        selectAccountOnPortfolioScreen(app, rowNum: 3)
        testPortfolioValues(app, brokerName: "dummyMultipleAcct1")
        waitForElementToAppear(app.navigationBars["Portfolio"])
        selectAccountOnPortfolioScreen(app, rowNum: 4)
        testPortfolioValues(app, brokerName: "jointIRA")
        waitForElementToAppear(app.navigationBars["Portfolio"])
        selectAccountOnPortfolioScreen(app, rowNum: 5)
        testPortfolioValues(app, brokerName: "Joint401k")
        waitForElementToAppear(app.navigationBars["Portfolio"])
        selectAccountOnPortfolioScreen(app, rowNum: 6)
        testPortfolioValues(app, brokerName: "MargicAcct")
        waitForElementToAppear(app.navigationBars["Portfolio"])
        selectAccountOnPortfolioScreen(app, rowNum: 7)
        testPortfolioValues(app, brokerName: "OptionAcct")
    }
    
    func testUnlinkingAcc(){
        clearData(app)
        handleWelcomeScreen(app, launchOption: "Portfolio")

        //log into dummyMultiple
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker", username: "dummyMultiple")
        completeOauthScreen(app)

        //unlink and test if portfolio view if reflect the change
        app.buttons["Manage"].tap()
        waitForElementToAppear(app.navigationBars["Accounts"])
        app.tables.staticTexts["Dummy (5 accounts)"].tap()
        waitForElementToAppear(app.navigationBars["Dummy"])
        app.tables.switches.matching(predicateBeginsWith(label: "Joint 401k**0003")).element.tap()
        app.navigationBars["Dummy"].buttons.element(boundBy: 0).tap()
        app.navigationBars["Accounts"].buttons["Portfolio"].tap()
        XCTAssertFalse(app.tables.staticTexts["Joint 401k**003"].exists) // true: 401k acc is disabled
        let totalValue = app.staticTexts["$305,956.91"]
        waitForElementToAppear(totalValue)

        //log into dummy acc
        app.buttons["Manage"].tap()
        app.tables.staticTexts["Add Account"].tap()
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        completeOauthScreen(app)
        
        //back to portfolio view
        app.navigationBars["Accounts"].buttons["Portfolio"].tap()

        //delete dummy broker
        app.buttons["Manage"].tap()
        app.tables.staticTexts["Dummy (5 accounts)"].tap()
        waitForElementToAppear(app.navigationBars["Dummy"])
        let unlinkCell = app.tables.staticTexts["Unlink"]
        XCTAssert(unlinkCell.exists)
        unlinkCell.tap()
        app.alerts["Unlink Dummy"].buttons["Unlink"].tap()
        app.navigationBars["Accounts"].buttons["Portfolio"].tap()
        waitForElementToAppear(app.navigationBars["Portfolio"])
        XCTAssert(app.staticTexts["$76,489.23"].exists) // true: dummyMultiple accs are removed

        //exit app
        app.navigationBars["Portfolio"].buttons["Close"].tap()

        //and relaunch portfolio
        let launchPortfolioText = app.tables.staticTexts["Portfolio"]
        waitForElementToBeHittable(launchPortfolioText)
        launchPortfolioText.tap()

        //test if data is persistent
        selectAccountOnPortfolioScreen(app, rowNum: 2)
        testPortfolioValues(app, brokerName: "Dummy")
        XCTAssertFalse(app.tables.staticTexts["Joint IRA **0002"].exists)
        XCTAssertFalse(app.tables.staticTexts["Joint 401k**0003"].exists)
        XCTAssertFalse(app.tables.staticTexts["Margin Acc**0004"].exists)
        XCTAssertFalse(app.tables.staticTexts["OPTIONS SU**0005"].exists)
    }
}
