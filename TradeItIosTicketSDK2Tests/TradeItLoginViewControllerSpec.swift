import Quick
import Nimble
import TradeItIosEmsApi

class TradeItLoginViewControllerSpec: QuickSpec {
    override func spec() {
        var controller: TradeItLoginViewController!
        var linkedLoginManager: FakeTradeItLinkedLoginManager!
        var window: UIWindow!
        var nav: UINavigationController!

        describe("initialization") {
            beforeEach {
                window = UIWindow()
                let bundle = NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2Tests")
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)

                linkedLoginManager = FakeTradeItLinkedLoginManager()
                TradeItLauncher.linkedLoginManager = linkedLoginManager

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
                    controller.userNameInput.text = "My Special Username"
                    controller.userNameOnEditingChanged(controller.userNameInput)
                    controller.passwordInput.text = "My Special Password"
                    controller.passwordOnEditingChanged(controller.passwordInput)

                    controller.linkButtonWasTapped(controller.linkButton)
                }

                it("uses the linkedLoginManager to link the account") {
                    let linkCalls = linkedLoginManager.calls.forMethod("linkBroker(authInfo:onSuccess:onSecurityQuestion:onFailure:)")

                    expect(linkCalls.count).to(equal(1))
                    expect(linkedLoginManager.calls.count).to(equal(1))

                    let linkCallAuthInfo = linkCalls[0].args["authInfo"] as! TradeItAuthenticationInfo

                    expect(linkCallAuthInfo.broker).to(equal("B5"))
                    expect(linkCallAuthInfo.id).to(equal("My Special Username"))
                    expect(linkCallAuthInfo.password).to(equal("My Special Password"))
                }

                it("disables the link button") {
                    expect(controller.linkButton.enabled).to(equal(false))
                }

                it("shows a spinner") {
                    expect(controller.activityIndicator.isAnimating()).to(beTrue())
                }

                context("when linking is successful") {
                    beforeEach {
                        let onSuccess = linkedLoginManager.calls.forMethod("linkBroker(authInfo:onSuccess:onSecurityQuestion:onFailure:)")[0].args["onSuccess"] as! (() -> Void)
                        
                        linkedLoginManager.calls.reset()
                        
                        onSuccess()
                    }

                    it("hides the spinner") {
                        expect(controller.activityIndicator.isAnimating()).to(beFalse())
                    }

                    it("segues to the portfolio screen") {
                        expect(nav.topViewController).to(beAnInstanceOf(TradeItPortfolioViewController))
//                        let portfolioController = nav.topViewController as! TradeItPortfolioViewController
                        //expect(portfolioController.accounts[0].name).to(equal("My Special account name"))
                    }

//                    it("keeps the spinner spinning") {
//                        expect(controller.activityIndicator.isAnimating()).to(beTrue())
//                    }
//
//                    it("saves the link") {
//                        let saveLinkCalls = tradeItConnector.calls.forMethod("saveLinkToKeychain(_:withBroker:)")
//                        expect(saveLinkCalls.count).to(equal(1))
//
//                        let brokerArg = saveLinkCalls[0].args["broker"] as! String
//                        expect(brokerArg).to(equal("B5"))
//
//                        let authLinkResultArg = saveLinkCalls[0].args["link"] as! TradeItAuthLinkResult
//                        expect(authLinkResultArg.userId).to(equal("userId1"))
//                        expect(authLinkResultArg.userToken).to(equal("userToken1"))
//                    }

//                    describe("authenticating the account") {
//                        it("uses the tradeItSession to authenticate the linked account") {
//                            let authenticateCalls = tradeItSession.calls.forMethod("authenticate(_:withCompletionBlock:)")
//                            expect(authenticateCalls.count).to(equal(1))
//                            expect(tradeItConnector.calls.count).to(equal(1))
//                        }
//
//                        context("when authentication is successful") {
//                            beforeEach {
//                                let authenticationResult = TradeItAuthenticationResult()
//                                authenticationResult.status = "SUCCESS"
//                                authenticationResult.token = "My special token"
//                                authenticationResult.shortMessage = "Fake short message"
//                                authenticationResult.longMessages = nil
//                                authenticationResult.accounts = [TradeItBrokerAccount(accountBaseCurrency: "MyCurrency", accountNumber: "My special account number", name: "My Special account name", tradable: true)]
//
//
//                                let completionHandler = tradeItSession.calls.forMethod("authenticate(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
//
//                                completionHandler(authenticationResult)
//                            }
//
//                            it("hides the spinner") {
//                                expect(controller.activityIndicator.isAnimating()).to(beFalse())
//                            }
//
//                            it("segues to the portfolio screen") {
//                                let portfolioController = nav.topViewController as! TradeItPortfolioViewController
//                                expect(portfolioController.accounts[0].name).to(equal("My Special account name"))
//                            }
//                        }
//
//                        context("when authentication fails") {
//                            beforeEach {
//                                let errorResult = TradeItErrorResult()
//                                errorResult.status = "ERROR"
//                                errorResult.token = "My Special Token"
//                                errorResult.shortMessage = "My Special Short Message"
//                                errorResult.longMessages = ["My Special Long Message.", "My Special Other Long Message."]
//
//                                let completionHandler = tradeItSession.calls.forMethod("authenticate(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
//
//                                completionHandler(errorResult)
//
//                            }
//
//                            it("hides the spinner") {
//                                expect(controller.activityIndicator.isAnimating()).to(beFalse())
//                            }
//
//                            it("enables the link button") {
//                                expect(controller.linkButton.enabled).to(equal(true))
//                            }
//
//                            it("stays on the login screen") {
//                                expect(nav.topViewController).toEventually(beAnInstanceOf(TradeItLoginViewController))
//                            }
//
//                            it("shows an error") {
//                                expect(controller.presentedViewController).toEventually(beAnInstanceOf(UIAlertController))
//
//                                let alertController = controller.presentedViewController as! UIAlertController
//
//                                expect(alertController.title).to(equal("My Special Short Message"))
//                                expect(alertController.message).to(equal("My Special Long Message. My Special Other Long Message."))
//                            }
//
//                            describe("dismissing the error") {
//                                beforeEach {
//                                    //  TODO: dismiss the error
//                                }
//
//                                it("stays on the login screen") {
//                                    expect(nav.topViewController).toEventually(beAnInstanceOf(TradeItLoginViewController))
//                                }
//                            }
//                        }
//                        
//                        context("when there is a security question") {
//                          //  TODO: Test security question handling
//                        }
//                    }
//                }
                }

                context("when linking fails") {
                    beforeEach {
                        let errorResult = TradeItErrorResult()
                        errorResult.status = "ERROR"
                        errorResult.token = "My Special Token"
                        errorResult.shortMessage = "My Special Error Title"
                        errorResult.longMessages = ["My Special Error Message"]

                        let onFailure = linkedLoginManager.calls.forMethod("linkBroker(authInfo:onSuccess:onSecurityQuestion:onFailure:)")[0].args["onFailure"] as! ((TradeItErrorResult) -> Void)

                        linkedLoginManager.calls.reset()

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

                context("when security question is required", { 
                    // TODO:
                })
            }
        }
    }
}
