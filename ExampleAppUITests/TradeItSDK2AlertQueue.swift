import XCTest
import TradeItIosTicketSDK2

class TradeItSDK2AlertQueue: XCTestCase{
    var app: XCUIApplication!
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("isUITesting")
        app.launch()
        sleep(1)
    }
    
    func testAlertQueue(){
        app.tables.staticTexts["LaunchAlertQueue"].tap()
        waitForElementToAppear(app.alerts["Alert 1"])
        app.alerts["Alert 1"].buttons["OK"].tap()
        waitForElementToAppear(app.alerts["Security Question"])
        app.alerts["Security Question"].buttons["Submit"].tap()
        waitForElementToAppear(app.alerts["Alert 2"])
        app.alerts["Alert 2"].buttons["OK"].tap()
    }
}
