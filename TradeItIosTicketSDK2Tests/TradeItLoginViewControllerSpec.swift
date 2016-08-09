import Quick
import Nimble

class TradeItLoginViewControllerSpec: QuickSpec {
    override func spec() {
        var controller: TradeItLoginViewController!
        var tradeItConnector: FakeTradeItConnector!
        var window: UIWindow!
        var nav: UINavigationController!

        describe("initialization") {
            beforeEach {
                window = UIWindow()
                let bundle = NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2Tests")
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)

                controller = storyboard.instantiateViewControllerWithIdentifier("TRADE_IT_LOGIN_VIEW") as! TradeItLoginViewController

                controller.selectedBroker = TradeItBroker(shortName: "B5", longName: "Broker #5")

                nav = UINavigationController(rootViewController: controller)

                window.addSubview(nav.view)

                NSRunLoop.currentRunLoop().runUntilDate(NSDate())
            }

            it("sets the broker longName in the instruction label the and text field placeholders") {
                let brokerName = controller.selectedBroker!.brokerLongName

                expect(controller.loginLabel.text).to(equal("Login in to \(brokerName)"))
                expect(controller.userNameInput.placeholder).to(equal("\(brokerName) Username"))
                expect(controller.passwordInput.placeholder).to(equal("\(brokerName) Password"))
            }

            it("focuses the userName text field") {
                expect(controller.userNameInput.isFirstResponder()).to(equal(true))
            }

            it("disables the link button") {
                expect(controller.linkButton.enabled).to(equal(false))
            }

            describe("filling in the login fields") {
                context("when username and password are filled") {
                    beforeEach {
                        controller.userNameInput.text = "dummy"
                        controller.userNameOnEditingChanged(controller.userNameInput)
                        controller.passwordInput.text = "dummy"
                        controller.passwordOnEditingChanged(controller.passwordInput)
                    }

                    it("enables the link button") {
                        expect(controller.linkButton.enabled).to(equal(true))
                    }
                }

                context("when at least one field is empty") {
                    beforeEach {
                        controller.userNameInput.text = ""
                        controller.userNameOnEditingChanged(controller.userNameInput)
                        controller.passwordInput.text = "my special password"
                        controller.passwordOnEditingChanged(controller.passwordInput)

                    }

                    it("disables the link button") {
                        expect(controller.linkButton.enabled).to(equal(false))
                    }
                }

                context("when both fields are empty") {
                    beforeEach {
                        controller.userNameInput.text = ""
                        controller.userNameOnEditingChanged(controller.userNameInput)
                        controller.passwordInput.text = ""
                        controller.passwordOnEditingChanged(controller.passwordInput)
                    }

                    it("disables the link button") {
                        expect(controller.linkButton.enabled).to(equal(false))
                    }
                }

            }

            describe("linking the account") {
                beforeEach {
                    controller.userNameInput.text = "dummy"
                    controller.userNameOnEditingChanged(controller.userNameInput)
                    controller.passwordInput.text = "dummy"
                    controller.passwordOnEditingChanged(controller.passwordInput)
                    tradeItConnector = FakeTradeItConnector()
                    controller.tradeItConnector = tradeItConnector
                    //controller.linkButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                    controller.linkButtonWasTapped(controller.linkButton)
                }

                it("uses the connector to link the account") {
                    expect(tradeItConnector.calls.forMethod("linkBrokerWithAuthenticationInfo(_:andCompletionBlock:)").count).to(equal(1))
                }

                it("disables the link button") {
                    expect(controller.linkButton.enabled).to(equal(false))
                }

                it("shows a spinner") {
                    expect(controller.activityIndicator.isAnimating()).to(beTrue())
                }

                context("when authentication is successful") {
                    beforeEach {
                        let oAuthLinkResult = TradeItAuthLinkResult()
                        oAuthLinkResult.userId = "userId1"
                        oAuthLinkResult.userToken = "userToken1"
                        tradeItConnector.tradeItLinkedLogin = TradeItLinkedLogin()
                        tradeItConnector.tradeItLinkedLogin.label = "dummy"
                        tradeItConnector.tradeItLinkedLogin.broker = "dummy"
                        tradeItConnector.tradeItLinkedLogin.userId = "userId1"
                        tradeItConnector.tradeItLinkedLogin.keychainId = "012346586978"
                        let completionHandler = tradeItConnector.calls.forMethod("linkBrokerWithAuthenticationInfo(_:andCompletionBlock:)")[0].args[1] as! ((TradeItResult!) -> Void)
                        completionHandler(oAuthLinkResult)
                    }
                    
                    it("hides the spinner") {
                        expect(controller.activityIndicator.isAnimating()).to(beFalse())
                    }

                    it("takes us to the account screen") {
                        expect(nav.topViewController?.title).to(equal("Accounts"))
                    }

                    // TODO: Test passing the right info to the next screen
                }

                context("when authentication fails") {
                    beforeEach {
                        let errorResult = TradeItErrorResult()
                        errorResult.status = "ERROR"
                        errorResult.token = "e3c1873423e142e899bc00c987c657c9"
                        errorResult.shortMessage = "Could Not Login"
                        errorResult.longMessages = ["Check your username and password and try again."]
                        let completionHandler = tradeItConnector.calls.forMethod("linkBrokerWithAuthenticationInfo(_:andCompletionBlock:)")[0].args[1] as! ((TradeItResult!) -> Void)
                        completionHandler(errorResult)
                    }

                    it("hides the spinner") {
                        expect(controller.activityIndicator.isAnimating()).to(beFalse())
                    }

                    it("enables the link button") {
                        expect(controller.linkButton.enabled).to(equal(true))
                    }

                    it("shows a modal alert with the error message") {
                        expect(controller.presentedViewController).toEventually(beAnInstanceOf(UIAlertController))
                        let alertController = controller.presentedViewController as! UIAlertController
                        expect(alertController.title).to(equal("Could Not Login"))
                        expect(alertController.message).to(equal("Check your username and password and try again."))
                    }

                    describe("dismissing the alert") {
                        beforeEach {
//                            let alertController = controller.presentedViewController as! UIAlertController
//                            let action = alertController.actions.first as UIAlertAction!

                            // TODO: ADD AlertProvider setup here to test calling the alert's OK action
                        }

                        it("remains on the login screen") {
                            expect(nav.topViewController?.title).to(equal("Login"))
                        }
                    }
                }
                
            }
        }
    }
}
