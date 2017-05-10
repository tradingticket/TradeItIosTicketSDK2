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
        handleWelcomeScreen(app, launchOption: "launchPortfolio")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        selectAccountOnPortfolioScreen(app, rowNum: 1)
        testPortfolioValues(app, brokerName: "Dummy")
    }
    
    func testPortfolioWithoutWelcome(){
        clearData(app)
        handleWelcomeScreen(app, launchOption: "launchPortfolio")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        app.navigationBars["Portfolio"].buttons["Close"].tap()
        waitForElementToBeHittable(app.tables.staticTexts["launchPortfolio"])
        app.tables.staticTexts["launchPortfolio"].tap()
        waitForElementToAppear(app.navigationBars["Portfolio"])
        waitForElementToAppear(app.tables.staticTexts["Individual**cct1"])
    }
    
    func testPortfolioWithWelcomeMultiAcc(){
        clearData(app)
        handleWelcomeScreen(app, launchOption: "launchPortfolio")
        
        //log into dummyMultiple
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker", username: "dummyMultiple")
        selectAccountOnPortfolioScreen(app, rowNum: 1)
        
        //log into dummy acc
        app.buttons["Edit Accounts"].tap()
        app.buttons["Add Account"].tap()
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        
        //back to portfolio view
        app.navigationBars["Accounts"].buttons["Portfolio"].tap()
        testPortfolioValues(app, brokerName: "dummyMultipleAcct1")
        selectAccountOnPortfolioScreen(app, rowNum: 2)
        testPortfolioValues(app, brokerName: "jointIRA")
        selectAccountOnPortfolioScreen(app, rowNum: 3)
        testPortfolioValues(app, brokerName: "Joint401k")
        selectAccountOnPortfolioScreen(app, rowNum: 4)
        testPortfolioValues(app, brokerName: "MargicAcct")
        selectAccountOnPortfolioScreen(app, rowNum: 5)
        testPortfolioValues(app, brokerName: "OptionAcct")
    }
    
    func testUnlinkingAcc(){
        clearData(app)
        handleWelcomeScreen(app, launchOption: "launchPortfolio")

        //log into dummyMultiple
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker", username: "dummyMultiple")
        selectAccountOnPortfolioScreen(app, rowNum: 1)

        //unlink and test if portfolio view if reflect the change
        app.buttons["Edit Accounts"].tap()
        waitForElementToAppear(app.navigationBars["Accounts"])
        app.tables.staticTexts["Dummy (5 accounts)"].tap()
        waitForElementToAppear(app.navigationBars["Dummy"])
        app.tables.switches["Joint 401k**cct3, BUYING POWER, $2,408.12"].tap()
        app.navigationBars["Dummy"].buttons.element(boundBy: 0).tap()
        app.navigationBars["Accounts"].buttons["Portfolio"].tap()
        XCTAssertFalse(app.tables.staticTexts["Joint 401k**cct3"].exists) // true: 401k acc is unlinked
        XCTAssertTrue(app.staticTexts["$305,956.91"].exists) // true: total value reflects change

        //log into dummy acc
        app.buttons["Edit Accounts"].tap()
        app.buttons["Add Account"].tap()
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")

        //back to portfolio view
        app.navigationBars["Accounts"].buttons["Portfolio"].tap()

        //delete dummy broker
        app.buttons["Edit Accounts"].tap()
        app.tables.staticTexts["Dummy (5 accounts)"].tap()
        waitForElementToAppear(app.navigationBars["Dummy"])
        XCTAssert(app.buttons["Unlink Account"].exists)
        app.buttons["Unlink Account"].tap()
        app.alerts["Unlink Dummy"].buttons["Unlink"].tap()
        app.navigationBars["Accounts"].buttons["Portfolio"].tap()
        waitForElementToAppear(app.navigationBars["Portfolio"])
        XCTAssert(app.staticTexts["$0.00"].exists) // true: dummyMultiple accs are removed

        //exit app
        app.navigationBars["Portfolio"].buttons["Close"].tap()

        //and relaunch portfolio
        let launchPortfolioText = app.tables.staticTexts["launchPortfolio"]
        waitForElementToBeHittable(launchPortfolioText)
        launchPortfolioText.tap()

        //test if data is persistent
        testPortfolioValues(app, brokerName: "Dummy")
        XCTAssertFalse(app.tables.staticTexts["Joint IRA **cct2"].exists)
        XCTAssertFalse(app.tables.staticTexts["Joint 401k**cct3"].exists)
        XCTAssertFalse(app.tables.staticTexts["Margin Acc**cct4"].exists)
        XCTAssertFalse(app.tables.staticTexts["OPTIONS SU**cct5"].exists)
    }
}
