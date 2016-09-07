import Quick
import Nimble
import TradeItIosEmsApi

class TradeItLoginViewControllerSpec: QuickSpec {
    override func spec() {
        var controller: TradeItLoginViewController!
        var linkedBrokerManager: FakeTradeItLinkedBrokerManager!
        var window: UIWindow!
        var nav: UINavigationController!

        describe("initialization") {
            beforeEach {
                window = UIWindow()
                let bundle = NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2Tests")
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)

                linkedBrokerManager = FakeTradeItLinkedBrokerManager()
                TradeItLauncher.linkedBrokerManager = linkedBrokerManager

                controller = storyboard.instantiateViewControllerWithIdentifier("TRADE_IT_LOGIN_VIEW") as! TradeItLoginViewController
                controller.selectedBroker = TradeItBroker(shortName: "B5", longName: "Broker #5")

                nav = UINavigationController(rootViewController: controller)

                window.addSubview(nav.view)

                NSRunLoop.currentRunLoop().runUntilDate(NSDate())
            }

            it("sets the broker longName in the instruction label the and text field placeholders") {
                let brokerName = controller.selectedBroker!.brokerLongName

                expect(controller.loginLabel.text).to(equal("Log in to \(brokerName)"))
                expect(controller.userNameInput.placeholder).to(equal("\(brokerName) Username"))
                expect(controller.passwordInput.placeholder).to(equal("\(brokerName) Password"))
            }

            it("focuses the userName text field") {
                expect(controller.userNameInput.isFirstResponder()).to(equal(true))
            }

            it("disables the link button") {
                expect(controller.linkButton.enabled).to(beFalse())
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
                        expect(controller.linkButton.enabled).to(beTrue())
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
                        expect(controller.linkButton.enabled).to(beFalse())
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
                        expect(controller.linkButton.enabled).to(beFalse())
                    }
                }

            }

            describe("linking the account") {
                beforeEach {
                    controller.userNameInput.text = "My Special Username"
                    controller.userNameOnEditingChanged(controller.userNameInput)
                    controller.passwordInput.text = "My Special Password"
                    controller.passwordOnEditingChanged(controller.passwordInput)

                    controller.linkButtonWasTapped(controller.linkButton)
                }

                it("uses the linkedBrokerManager to link the account") {
                    let linkCalls = linkedBrokerManager.calls.forMethod("linkBroker(authInfo:onSuccess:onFailure:)")

                    expect(linkCalls.count).to(equal(1))
                    expect(linkedBrokerManager.calls.count).to(equal(1))

                    let linkCallAuthInfo = linkCalls[0].args["authInfo"] as! TradeItAuthenticationInfo

                    expect(linkCallAuthInfo.broker).to(equal("B5"))
                    expect(linkCallAuthInfo.id).to(equal("My Special Username"))
                    expect(linkCallAuthInfo.password).to(equal("My Special Password"))
                }

                it("disables the link button") {
                    expect(controller.linkButton.enabled).to(beFalse())
                }

                it("shows a spinner") {
                    expect(controller.activityIndicator.isAnimating()).to(beTrue())
                }

                context("when linking is successful") {
                    var linkedBroker: FakeTradeItLinkedBroker!

                    beforeEach {
                        let onSuccess = linkedBrokerManager.calls.forMethod("linkBroker(authInfo:onSuccess:onFailure:)")[0].args["onSuccess"] as! ((TradeItLinkedBroker) -> Void)
                        
                        linkedBroker = FakeTradeItLinkedBroker(session: FakeTradeItSession(),
                                                           linkedLogin: TradeItLinkedLogin(label: "",
                                                                                           broker: "",
                                                                                           userId: "",
                                                                                           andKeyChainId: ""))
                        onSuccess(linkedBroker)
                    }
                    
                    it("authenticates the linkedBroker") {
                        let linkCalls = linkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
                        expect(linkCalls.count).to(equal(1))
                        expect(linkedBrokerManager.calls.count).to(equal(1))
                    }

                    it("keeps the link button disabled") {
                        expect(controller.linkButton.enabled).to(beFalse())
                    }

                    it("keeps the spinner spinning") {
                        expect(controller.activityIndicator.isAnimating()).to(beTrue())
                    }

                    describe("authenticating the broker") {
                        context("when authentication succeeds") {
                            beforeEach {
                                let onSuccess = linkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")[0].args["onSuccess"] as! (() -> Void)

                                    onSuccess()
                            }
                            it("hides the spinner") {
                                expect(controller.activityIndicator.isAnimating()).to(beFalse())
                            }

                            it("segues to the portfolio screen") {
                                expect(nav.topViewController).to(beAnInstanceOf(TradeItPortfolioViewController))
                                let portfolioController = nav.topViewController as! TradeItPortfolioViewController
//                                expect(portfolioController.accounts[0].name).to(equal("My Special account name"))
                            }
                        }

                        context("when authentication fails") {
                            beforeEach {
                                let errorResult = TradeItErrorResult()
                                errorResult.status = "ERROR"
                                errorResult.token = "My Special Token"
                                errorResult.shortMessage = "My Special Error Title"
                                errorResult.longMessages = ["My Special Error Message"]

                                let onFailure = linkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")[0].args["onFailure"] as! ((TradeItErrorResult) -> Void)
                                onFailure(errorResult)
                            }

                            it("hides the spinner") {
                                expect(controller.activityIndicator.isAnimating()).to(beFalse())
                            }

                            it("enables the link button") {
                                expect(controller.linkButton.enabled).to(beTrue())
                            }

                            it("shows a modal alert with the error message") {
                                expect(controller.presentedViewController).toEventually(beAnInstanceOf(UIAlertController))

                                let alertController = controller.presentedViewController as! UIAlertController

                                expect(alertController.title).to(equal("My Special Error Title"))
                                expect(alertController.message).to(equal("My Special Error Message"))
                            }

                            it("remains on the login screen") {
                                expect(nav.topViewController).toEventually(beAnInstanceOf(TradeItLoginViewController))
                            }

                            describe("dismissing the alert") {
                                beforeEach {
                                    //                            let alertController = controller.presentedViewController as! UIAlertController
                                    //                            let action = alertController.actions.first as UIAlertAction!

                                    // TODO: ADD AlertProvider setup here to test calling the alert's OK action
                                }
                                
                                it("remains on the login screen") {
                                    expect(nav.topViewController).toEventually(beAnInstanceOf(TradeItLoginViewController))
                                }
                            }
                        }

                        context("when security question is needed") {
                            // TODO
//                            beforeEach {
//                                let tradeItSecurityQuestionResult = TradeItSecurityQuestionResult()
//                                let onSecurityQuestion = linkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")[0].args["onSecurityQuestion"] as! ((tradeItSecurityQuestionResult: TradeItSecurityQuestionResult) -> String)
//                                
//                                onSecurityQuestion(tradeItSecurityQuestionResult: tradeItSecurityQuestionResult)
//                            }
                        }
                    }
                }

                context("when linking fails") {
                    beforeEach {
                        let errorResult = TradeItErrorResult()
                        errorResult.status = "ERROR"
                        errorResult.token = "My Special Token"
                        errorResult.shortMessage = "My Special Error Title"
                        errorResult.longMessages = ["My Special Error Message"]

                        let onFailure = linkedBrokerManager.calls.forMethod("linkBroker(authInfo:onSuccess:onFailure:)")[0].args["onFailure"] as! ((TradeItErrorResult) -> Void)

                        linkedBrokerManager.calls.reset()

                        onFailure(errorResult)
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

                        expect(alertController.title).to(equal("My Special Error Title"))
                        expect(alertController.message).to(equal("My Special Error Message"))
                    }

                    it("remains on the login screen") {
                        expect(nav.topViewController).toEventually(beAnInstanceOf(TradeItLoginViewController))
                    }

                    describe("dismissing the alert") {
                        beforeEach {
//                            let alertController = controller.presentedViewController as! UIAlertController
//                            let action = alertController.actions.first as UIAlertAction!

                            // TODO: ADD AlertProvider setup here to test calling the alert's OK action
                        }

                        it("remains on the login screen") {
                            expect(nav.topViewController).toEventually(beAnInstanceOf(TradeItLoginViewController))
                        }
                    }
                }
            }
        }
    }
}
