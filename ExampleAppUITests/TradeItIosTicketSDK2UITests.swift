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
    
    func testSecurityQuestionFlow() {
        let app = self.application
        clearData(app)
        handleWelcomeScreen(app, launchOption: "LaunchPortfolio")
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
    
    //******************//
    //* Portfolio Flow *//
    //******************//
    func testPortfolioWithWelcomeSingleAcc() {
        let app = self.application
        clearData(app)
        handleWelcomeScreen(app, launchOption: "LaunchPortfolio")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        selectAccountOnPortfolioScreen(app, rowNum: 1)
        testPortfolioValues(app, brokerName: "Dummy")
    }
    
    func testPortfolioWithoutWelcome(){
        let app = self.application
        clearData(app)
        handleWelcomeScreen(app, launchOption: "LaunchPortfolio")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        waitForElementToAppear(app.navigationBars["Portfolio"])
        app.navigationBars["Portfolio"].buttons["Close"].tap()
        app.tables.staticTexts["LaunchPortfolio"].tap()
        waitForElementToDisappear(app.staticTexts["Refreshing Account"])
        XCTAssert(app.tables.staticTexts["Individual**cct1"].exists)
    }
    
    func testPortfolioWithWelcomeMultiAcc(){
        let app = self.application
        clearData(app)
        handleWelcomeScreen(app, launchOption: "LaunchPortfolio")
        
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
        let app = self.application
        clearData(app)
        handleWelcomeScreen(app, launchOption: "LaunchPortfolio")
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
        app.navigationBars["Dummy"].buttons.elementBoundByIndex(0).tap()
        app.navigationBars["Accounts"].buttons["Portfolio"].tap()
        XCTAssertFalse(app.tables.staticTexts["Joint 401k**cct3"].exists) //true: 401k acc is unlinked
        XCTAssertTrue(app.staticTexts["$305,956.91"].exists) // true: totally value reflects change
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
        let launchPortfolioText = app.tables.staticTexts["LaunchPortfolio"]
        waitForElementToBeHittable(launchPortfolioText)
        launchPortfolioText.tap()
        let activityIndicator = app.activityIndicators.element
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
        //test if data is persistent
        testPortfolioValues(app, brokerName: "Dummy")
        XCTAssertFalse(app.tables.staticTexts["Joint IRA **cct2"].exists)
        XCTAssertFalse(app.tables.staticTexts["Joint 401k**cct3"].exists)
        XCTAssertFalse(app.tables.staticTexts["Margin Acc**cct4"].exists)
        XCTAssertFalse(app.tables.staticTexts["OPTIONS SU**cct5"].exists)
    }
    
    func testFxWelcomeFlow() {
        let app = self.application
        clearData(app)
        handleWelcomeScreen(app, launchOption: "LaunchPortfolio")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy FX Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy FX Broker")
        selectAccountOnPortfolioScreen(app, rowNum: 1)
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
        waitForElementToAppear(app.tables.staticTexts["Bid"])
        XCTAssert(app.tables.staticTexts["Ask"].exists)
        XCTAssert(app.tables.staticTexts["Spread"].exists)
        XCTAssert(!app.tables.staticTexts["Total Return"].exists)
        XCTAssert(!app.tables.staticTexts["Day"].exists)
    }
    
    func testPortfolioBypassWelcomeFlow() {
        let app = self.application
        clearData(app)
        handleWelcomeScreen(app, launchOption: "LaunchPortfolio")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        selectAccountOnPortfolioScreen(app, rowNum: 1)
        waitForElementToAppear(app.navigationBars["Portfolio"])
        app.buttons["Close"].tap()
        app.tables.staticTexts["LaunchPortfolio"].tap()
        waitForElementToAppear(app.navigationBars["Portfolio"])
    }
    
    //**************//
    //* Trade Flow *//
    //**************//
    func testTradingWithWelcomeSingleAcc() {
        let app = self.application
        clearData(app)
        handleWelcomeScreen(app, launchOption: "LaunchTrading")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker")
        //symbol Search screen
        symbolSearch(app, symbol: "GE")
        let activityIndicator = app.activityIndicators.element
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
        XCTAssertTrue(app.tables.element.cells.elementBoundByIndex(0).exists)
        waitForElementToBeHittable(app.tables.element.cells.elementBoundByIndex(0))
        app.tables.element.cells.elementBoundByIndex(0).tap()
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
    
    //******************//
    //* Helper methods *//
    //******************//
    private func testConfirmation(app: XCUIApplication){
        XCTAssert(app.images["success_icon.png"].exists)
        XCTAssert(app.staticTexts["Confirmed"].exists)
        XCTAssert(app.buttons["Trade Again"].exists)
        XCTAssert(app.buttons["View Portfolio"].exists)
    }
    
    private func testPreviewValues(app: XCUIApplication, symbol: String, limitPrice: String, stopPrice: String, quantity: String){
        XCTAssert(app.staticTexts["ACCOUNT"].exists)
        XCTAssert(app.staticTexts["SYMBOL"].exists)
        XCTAssert(app.staticTexts["QUANTITY"].exists)
        XCTAssert(app.staticTexts["ACTION"].exists)
        XCTAssert(app.staticTexts["PRICE"].exists)
        XCTAssert(app.staticTexts["EXPIRATION"].exists)
        XCTAssert(app.staticTexts["SHARES OWNED"].exists)
        XCTAssert(app.staticTexts["SHARES HELD SHORT"].exists)
        XCTAssert(app.staticTexts["BUYING POWER"].exists)
        XCTAssert(app.staticTexts["BROKER FEE"].exists)
        XCTAssert(app.staticTexts["ESTIMATED COST"].exists)
        XCTAssert(app.staticTexts["\(symbol)"].exists)
        XCTAssert(app.staticTexts["\(quantity)"].exists)
        XCTAssert(app.staticTexts["$\(limitPrice).00 (trigger: $\(stopPrice).00)"].exists)
        XCTAssert(app.buttons["Place Order"].exists)
    }
    
    private func fillOrder(app: XCUIApplication, orderAction: String, orderType: String, limitPrice: String, stopPrice: String, share: String, expiration: String){
        //Shares
        app.textFields["Shares"].tap()
        waitForElementToHaveKeyboardFocus(app.textFields["Shares"])
        app.textFields["Shares"].typeText("\(share)")
        //Limit Price
        app.textFields["Limit Price"].tap()
        waitForElementToHaveKeyboardFocus(app.textFields["Limit Price"])
        app.textFields["Limit Price"].typeText("\(limitPrice)")
        //Stop Price
        app.textFields["Stop Price"].tap()
        waitForElementToHaveKeyboardFocus(app.textFields["Stop Price"])
        app.textFields["Stop Price"].typeText("\(stopPrice)")
    }
    
    private func testTradeScreenValues(app: XCUIApplication){
        XCTAssert(app.buttons["Buy"].exists)
        XCTAssert(app.buttons["Market"].exists)
        XCTAssert(app.textFields["Shares"].exists)
        app.buttons["Buy"].tap()
        waitForElementToAppear(app.sheets["Order Action"])
        XCTAssert(app.sheets.buttons["Buy"].exists)
        XCTAssert(app.sheets.buttons["Sell"].exists)
        XCTAssert(app.sheets.buttons["Buy to Cover"].exists)
        XCTAssert(app.sheets.buttons["Sell Short"].exists)
        XCTAssert(app.buttons["Cancel"].exists)
        app.buttons["Cancel"].tap()
        waitForElementToDisappear(app.sheets["Order Action"])
        app.buttons["Market"].tap()
        waitForElementToAppear(app.sheets["Order Type"])
        XCTAssert(app.sheets.buttons["Market"].exists)
        XCTAssert(app.sheets.buttons["Limit"].exists)
        XCTAssert(app.sheets.buttons["Stop Market"].exists)
        XCTAssert(app.sheets.buttons["Stop Limit"].exists)
        XCTAssert(app.buttons["Cancel"].exists)
        app.sheets.buttons["Stop Limit"].tap()
        waitForElementToDisappear(app.sheets["Order Type"])
        XCTAssert(app.textFields["Limit Price"].exists)
        XCTAssert(app.textFields["Stop Price"].exists)
        XCTAssert(app.buttons["Good for day"].exists)
        app.buttons["Good for day"].tap()
        waitForElementToAppear(app.sheets["Order Expiration"])
        XCTAssert(app.sheets.buttons["Good for day"].exists)
        XCTAssert(app.sheets.buttons["Good until canceled"].exists)
        XCTAssert(app.buttons["Cancel"].exists)
        app.sheets.buttons["Good until canceled"].tap()
        waitForElementToDisappear(app.sheets["Order Expiration"])
    }
    
    private func symbolSearch(app: XCUIApplication, symbol: String){
        let symbolSearchField = app.textFields["Enter a symbol"]
        waitForElementToHaveKeyboardFocus(symbolSearchField)
        symbolSearchField.typeText("\(symbol)")
    }
    
    private func clearData(app: XCUIApplication) {
        let deleteLinkedBrokersText = app.tables.staticTexts["DeleteLinkedBrokers"]
        waitForElementToBeHittable(deleteLinkedBrokersText)
        deleteLinkedBrokersText.tap()
    }
    
    private func handleWelcomeScreen(app: XCUIApplication, launchOption: String) {
        let launchPortfolioText = app.tables.staticTexts["\(launchOption)"]
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
    
    private func submitValidCredentialsOnTheLoginScreen(app: XCUIApplication, longBrokerName: String, username: String = "dummy", password: String = "dummy") {
        XCTAssert(app.navigationBars["Login"].exists)
        let usernameTextField = app.textFields["\(longBrokerName) Username"]
        let passwordTextField = app.secureTextFields["\(longBrokerName) Password"]
        waitForElementToHaveKeyboardFocus(usernameTextField)
        waitForElementNotToHaveKeyboardFocus(passwordTextField)
        
        XCTAssert(app.staticTexts["Log in to \(longBrokerName)"].exists)
        usernameTextField.typeText(username)
        passwordTextField.tap()
        waitForElementToHaveKeyboardFocus(passwordTextField)
        waitForElementNotToHaveKeyboardFocus(usernameTextField)
        passwordTextField.typeText(password)
        
        app.buttons["Link Broker"].tap()
        let activityIndicator = app.activityIndicators.element
        waitForElementNotToBeHittable(activityIndicator, withinSeconds: 10)
    }
    
    private func selectAccountOnPortfolioScreen(app: XCUIApplication, rowNum: Int) {
        waitForElementToAppear(app.navigationBars["Portfolio"])
        var ezLoadingActivity = app.staticTexts["Authenticating"]
        waitForElementToDisappear(ezLoadingActivity, withinSeconds: 10)
        ezLoadingActivity = app.staticTexts["Retreiving Account Summary"]
        waitForElementToDisappear(ezLoadingActivity)
        let tableView = app.tables.elementBoundByIndex(0)
        XCTAssertTrue(tableView.cells.count > 0)
        let cell = tableView.cells.elementBoundByIndex(UInt(rowNum)) // index 0 is header
        cell.tap()
    }
    
    private func testPortfolioValues(app: XCUIApplication, brokerName: String){
        if(brokerName == "Dummy"){
            //AccountTotalValue
            XCTAssert(app.staticTexts["$76,489.23"].exists)
            //Balances
            XCTAssert(app.tables.staticTexts["Individual**cct1"].exists)
            XCTAssert(app.tables.staticTexts["$2,408.12"].exists)
            XCTAssert(app.tables.staticTexts["$76,489.23 (22.84%)"].exists)
            //Positions
            let holdingsTitle = app.staticTexts["Individual**cct1 Holdings"]
            waitForElementToAppear(holdingsTitle)
            waitForElementToAppear(app.tables.staticTexts["AAPL"])//change
            XCTAssert(app.tables.staticTexts["1 shares"].exists)
            XCTAssert(app.tables.staticTexts["$103.34"].exists)
            XCTAssert(app.tables.staticTexts["$112.34"].exists)
            //Positions details
            app.tables.staticTexts["AAPL"].tap()
            waitForElementToAppear(app.tables.staticTexts["Bid"])
            XCTAssert(app.tables.staticTexts["Ask"].exists)
            XCTAssert(app.tables.staticTexts["Total Value"].exists)
            XCTAssert(app.tables.staticTexts["Total Return"].exists)
            XCTAssert(app.tables.staticTexts["Day"].exists)
            app.tables.staticTexts["AAPL"].tap()
        }
        else if(brokerName == "dummyMultipleAcct1"){
            //Balances
            XCTAssert(app.tables.staticTexts["Individual**cct1"].exists)
            XCTAssert(app.tables.staticTexts["$2,408.12"].exists)
            XCTAssert(app.tables.staticTexts["$76,489.23 (22.84%)"].exists)
            //Positions
            let holdingsTitle = app.staticTexts["Individual**cct1 Holdings"]
            waitForElementToAppear(holdingsTitle)
            waitForElementToAppear(app.tables.staticTexts["AAPL"])//change
            XCTAssert(app.tables.staticTexts["1 shares"].exists)
            XCTAssert(app.tables.staticTexts["$103.34"].exists)
            XCTAssert(app.tables.staticTexts["$112.34"].exists)
            //Positions details
            app.tables.staticTexts["AAPL"].tap()
            waitForElementToAppear(app.tables.staticTexts["Bid"])
            XCTAssert(app.tables.staticTexts["Ask"].exists)
            XCTAssert(app.tables.staticTexts["Total Value"].exists)
            XCTAssert(app.tables.staticTexts["Total Return"].exists)
            XCTAssert(app.tables.staticTexts["Day"].exists)
            app.tables.staticTexts["AAPL"].tap()
        }
        else if(brokerName == "jointIRA"){
            //Balances
            XCTAssert(app.tables.staticTexts["Joint IRA **cct2"].exists)
            XCTAssert(app.tables.staticTexts["$2,408.12"].exists)
            XCTAssert(app.tables.staticTexts["$76,489.23 (22.84%)"].exists)
            //Positions
            let holdingsTitle = app.staticTexts["Joint IRA **cct2 Holdings"]
            waitForElementToAppear(holdingsTitle)
            waitForElementToAppear(app.tables.staticTexts["AAPL"])//change
            XCTAssert(app.tables.staticTexts["1 shares"].exists)
            XCTAssert(app.tables.staticTexts["$103.34"].exists)
            XCTAssert(app.tables.staticTexts["$112.34"].exists)
            //Positions details
            app.tables.staticTexts["AAPL"].tap()
            waitForElementToAppear(app.tables.staticTexts["Bid"])
            XCTAssert(app.tables.staticTexts["Ask"].exists)
            XCTAssert(app.tables.staticTexts["Total Value"].exists)
            XCTAssert(app.tables.staticTexts["Total Return"].exists)
            XCTAssert(app.tables.staticTexts["Day"].exists)
            app.tables.staticTexts["AAPL"].tap()
        }
        else if(brokerName == "Joint401k"){
            //Balances
            XCTAssert(app.tables.staticTexts["Joint 401k**cct3"].exists)
            XCTAssert(app.tables.staticTexts["$2,408.12"].exists)
            XCTAssert(app.tables.staticTexts["$76,489.23 (22.84%)"].exists)
            //Positions
            let holdingsTitle = app.staticTexts["Joint 401k**cct3 Holdings"]
            waitForElementToAppear(holdingsTitle)
            waitForElementToAppear(app.tables.staticTexts["AAPL"])//change
            XCTAssert(app.tables.staticTexts["1 shares"].exists)
            XCTAssert(app.tables.staticTexts["$103.34"].exists)
            XCTAssert(app.tables.staticTexts["$112.34"].exists)
            //Positions details
            app.tables.staticTexts["AAPL"].tap()
            waitForElementToAppear(app.tables.staticTexts["Bid"])
            XCTAssert(app.tables.staticTexts["Ask"].exists)
            XCTAssert(app.tables.staticTexts["Total Value"].exists)
            XCTAssert(app.tables.staticTexts["Total Return"].exists)
            XCTAssert(app.tables.staticTexts["Day"].exists)
            app.tables.staticTexts["AAPL"].tap()
        }
        else if(brokerName == "MargicAcct"){
            //Balances
            XCTAssert(app.tables.staticTexts["Margin Acc**cct4"].exists)
            XCTAssert(app.tables.staticTexts["$2,408.12"].exists)
            XCTAssert(app.tables.staticTexts["$76,489.23 (22.84%)"].exists)
            //Positions
            let holdingsTitle = app.staticTexts["Margin Acc**cct4 Holdings"]
            waitForElementToAppear(holdingsTitle)
            waitForElementToAppear(app.tables.staticTexts["AAPL"]) //change
            XCTAssert(app.tables.staticTexts["1 shares"].exists)
            XCTAssert(app.tables.staticTexts["$103.34"].exists)
            XCTAssert(app.tables.staticTexts["$112.34"].exists)
            //Positions details
            app.tables.staticTexts["AAPL"].tap()
            waitForElementToAppear(app.tables.staticTexts["Bid"])
            XCTAssert(app.tables.staticTexts["Ask"].exists)
            XCTAssert(app.tables.staticTexts["Total Value"].exists)
            XCTAssert(app.tables.staticTexts["Total Return"].exists)
            XCTAssert(app.tables.staticTexts["Day"].exists)
            app.tables.staticTexts["AAPL"].tap()
        }
        else if(brokerName == "OptionAcct"){
            //Balances
            XCTAssert(app.tables.staticTexts["OPTIONS SU**cct5"].exists)
            XCTAssert(app.tables.staticTexts["$2,408.12"].exists)
            XCTAssert(app.tables.staticTexts["$76,489.23 (22.84%)"].exists)
            //Positions
            let holdingsTitle = app.staticTexts["OPTIONS SU**cct5 Holdings"]
            waitForElementToAppear(holdingsTitle)
            XCTAssert(app.tables.staticTexts["AAPL"].exists)
            XCTAssert(app.tables.staticTexts["1 shares"].exists)
            XCTAssert(app.tables.staticTexts["$103.34"].exists)
            XCTAssert(app.tables.staticTexts["$112.34"].exists)
            //Positions details
            app.tables.staticTexts["AAPL"].tap()
            waitForElementToAppear(app.tables.staticTexts["Bid"])
            XCTAssert(app.tables.staticTexts["Ask"].exists)
            XCTAssert(app.tables.staticTexts["Total Value"].exists)
            XCTAssert(app.tables.staticTexts["Total Return"].exists)
            XCTAssert(app.tables.staticTexts["Day"].exists)
        }
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
