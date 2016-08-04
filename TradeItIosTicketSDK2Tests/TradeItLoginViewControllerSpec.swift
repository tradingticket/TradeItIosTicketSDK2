import Quick
import Nimble

class TradeItLoginViewControllerSpec: QuickSpec {

    override func spec() {
        var controller: TradeItLoginViewController!
        let tradeItConnector = FakeTradeItConnector()
        var window: UIWindow!
        var nav: UINavigationController!
        
        describe("initialization") {
            beforeEach {
                window = UIWindow()
                let bundle = NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2Tests")
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)
                
                
                controller = storyboard.instantiateViewControllerWithIdentifier("TRADE_IT_LOGIN_VIEW") as! TradeItLoginViewController
                controller.selectedBroker = ["longName" : "Broker #5", "shortName" : "B5"]
                
                nav = UINavigationController(rootViewController: controller)
                
                expect(controller.view).toNot(beNil())
                expect(nav.view).toNot(beNil())
        
                window.addSubview(nav.view)
                NSRunLoop.currentRunLoop().runUntilDate(NSDate())
            }
            
            it("show the broker longName in the loginLabel and placeholder of the inputs") {
                let brokerName = controller.selectedBroker["longName"]!
                expect(controller.loginLabel.text).to(equal("Login in to \(brokerName)"))
                expect(controller.userNameInput.placeholder).to(equal("\(brokerName) Username"))
                expect(controller.passwordInput.placeholder).to(equal("\(brokerName) Password"))
            }
            
            it("focus on the userName input") {
                expect(controller.userNameInput.isFirstResponder()).to(equal(true))
            }
            
            context("when username and password are filled") {
                beforeEach {
                    controller.userNameInput.text = "dummy"
                    controller.userNameOnEditingChanged(controller.userNameInput)
                    controller.passwordInput.text = "dummy"
                    controller.passwordOnEditingChanged(controller.passwordInput)
                    controller.tradeItConnector = tradeItConnector
                    controller.linkButtonClick(controller.linkButton)
                }
                
//                it("tries to link account") {
//                    expect(tradeItConnector.calls.forMethod("linkBrokerWithAuthenticationInfo").count).to(equal(1))
//                }
                
                it("enables the link button") {
                    expect(controller.linkButton.enabled).to(equal(true))
                }
                
                it("shows a spinner") {
                    expect(controller.activityIndicator.isAnimating()).to(beTrue())
                }

                context("when authentication is successful") {
                    beforeEach {
                        let oAuthLinkResult = TradeItAuthLinkResult()
                        oAuthLinkResult.userId = "userId1"
                        oAuthLinkResult.userToken = "userToken1"
                        tradeItConnector.completionBlockLinkBrokerWithAuthenticationInfo(oAuthLinkResult)
                        tradeItConnector.tradeItLinkedLogin = TradeItLinkedLogin()
                        tradeItConnector.tradeItLinkedLogin.label = "dummy"
                        tradeItConnector.tradeItLinkedLogin.broker = "dummy"
                        tradeItConnector.tradeItLinkedLogin.userId = "userId1"
                        tradeItConnector.tradeItLinkedLogin.keychainId = "012346586978"
                        tradeItConnector.completionBlockLinkBrokerWithAuthenticationInfo(oAuthLinkResult)
                    }
                    
                    it("hides the spinner") {
                        expect(controller.activityIndicator.isAnimating()).to(beFalse())
                    }

                    it("takes us to the account screen") {
                        expect(nav.topViewController?.title).to(equal("Accounts"))
                    }
                }
                
                context("when authentication fails"){
                    beforeEach {
                        let errorResult = TradeItErrorResult()
                        errorResult.status = "ERROR"
                        errorResult.token = "e3c1873423e142e899bc00c987c657c9"
                        errorResult.shortMessage = "Could Not Login"
                        errorResult.longMessages = ["Check your username and password and try again."]
                        tradeItConnector.completionBlockLinkBrokerWithAuthenticationInfo(errorResult)
                    }
                    
                    it("hides the spinner") {
                        expect(controller.activityIndicator.isAnimating()).to(beFalse())
                    }
                    
                    it("shows a modal alert with the error message") {
                        expect(controller.presentedViewController).toEventually(beAnInstanceOf(UIAlertController))
                        let uiAlertController = controller.presentedViewController as! UIAlertController
                        expect(uiAlertController.title).to(equal("Could Not Login"))
                        expect(uiAlertController.message).to(equal("Check your username and password and try again."))
                    }
                    
                    it("should remain on the login screen when clicking ok") {
                         expect(nav.topViewController?.title).to(equal("Login"))
                    }
                }
            }
            
            context("when username or password is not filled") {
                beforeEach {
                    controller.userNameInput.text = "dummy"
                    controller.userNameOnEditingChanged(controller.userNameInput)
                    controller.passwordInput.text = ""
                    controller.passwordOnEditingChanged(controller.passwordInput)
                    
                }
                
                it("disables the link button") {
                    expect(controller.linkButton.enabled).to(equal(false))
                }
            }
        }
    }

}
