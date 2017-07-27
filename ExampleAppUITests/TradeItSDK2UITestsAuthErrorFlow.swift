import XCTest
import TradeItIosTicketSDK2

class TradeItSDK2UITestsAuthErrorFlow: XCTestCase {
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
    
    //test different error messages without authenticating
    func testAuthErrorFlow() {
        //testDummyAppCompleteFlow
        var expectMessage = "Your broker needs you to complete your account application before you can trade. Please visit your broker to answer a few more questions and finalize your account."
        genericErrorFlow("dummyCompleteApplication", errorMessage: expectMessage)
        
        
        //testDummyActionFlow
        expectMessage = "Your broker needs more information before you can trade. Please visit your broker website for details."
        genericErrorFlow("dummyAction", errorMessage: expectMessage)
        
        
        //testDummyNoAccountFlow
        expectMessage = "Your broker requires an active account before you can trade. It's possible your funds have yet to clear or an agreement needs signed, please visit your brokers for more information."
        genericErrorFlow("dummyNoAccount", errorMessage: expectMessage)
        
        
        //testDummyQuoteFlow
        expectMessage = "Your broker requires you to sign or update your Real-Time quote agreements before you can trade. Please visit your broker website for details."
        genericErrorFlow("dummyQuote", errorMessage: expectMessage)
        
        
        //testDummySecureAccountFlow
        expectMessage = "For your security, your broker requires you to create or update your security question before you can trade. Please visit your broker website for details."
        genericErrorFlow("dummySecureAccount", errorMessage: expectMessage)
        
        
        //testDummyResetPasswordFlow
        expectMessage = "Your broker requires you to update or reset your password before you can trade. Please visit your broker website for details."
        genericErrorFlow("dummyResetPassword", errorMessage: expectMessage)
        
        
        //testDummyCreateUsernameFlow
        expectMessage = "For your security, your broker requires you to create a username before you can login. Please visit your broker website for details."
        genericErrorFlow("dummyCreateUsername", errorMessage: expectMessage)
        
        
        //testDummyRetirementFlow
        expectMessage = "You cannot trade this kind of security in a retirement account. Please visit your broker to open a brokerage account today."
        genericErrorFlow("dummyRetirement", errorMessage: expectMessage)
        
    }
    
    
    private func genericErrorFlow(_ dummyUsername: String, errorMessage: String){
        clearData(app)
        handleWelcomeScreen(app, launchOption: "Portfolio")
        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker", username: dummyUsername)
        waitForElementToAppear(app.alerts["Could Not Login"])
        let alert = app.alerts["Could Not Login"]
        XCTAssert(alert.staticTexts[errorMessage].exists)
        alert.buttons["OK"].tap()
        
        let successText = app.staticTexts["Success!"]
        waitForElementToAppear(successText)
        XCTAssert(successText.exists)
        app.buttons["Continue"].tap()
        tapCloseButton(app)
    }
    
    //TODO: Wait for dummyFailTrade to be fixed
    //    func testDummyFailTradeFlow(){
    //        let app = self.application
    //        clearData(app)
    //        handleWelcomeScreen(app, launchOption: "LaunchPortfolio")
    //        selectBrokerFromTheBrokerSelectionScreen(app, longBrokerName: "Dummy Broker")
    //        submitValidCredentialsOnTheLoginScreen(app, longBrokerName: "Dummy Broker", username: "dummyFailTrade")
    //
    //    }
}
