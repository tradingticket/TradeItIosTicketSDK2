import Quick
import Nimble

class TradeItLoginViewControllerSpec: QuickSpec {

    override func spec() {
        var controller: TradeItLoginViewController!
        
        describe("initialization") {
            beforeEach {
                let bundle = NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2Tests")
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)
                
                controller = storyboard.instantiateViewControllerWithIdentifier("TRADE_IT_LOGIN_VIEW") as! TradeItLoginViewController
                
                controller.selectedBroker = ["longName" : "Broker #5", "shortName" : "B5"]
                expect(controller.view).toNot(beNil())
            }
            
            it("show the broker longName in the loginLabel and placeholder of the inputs") {
                let brokerName = controller.selectedBroker["longName"]!
                expect(controller.loginLabel.text).to(equal("Login in to \(brokerName)"))
                expect(controller.userNameInput.placeholder).to(equal("\(brokerName) Username"))
                expect(controller.passwordInput.placeholder).to(equal("\(brokerName) Password"))
            }
            
        }
    }

}
