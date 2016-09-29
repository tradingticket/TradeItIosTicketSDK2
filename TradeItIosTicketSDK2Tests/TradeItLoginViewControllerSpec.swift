import Quick
import Nimble
import TradeItIosEmsApi

class TradeItLoginViewControllerSpec: QuickSpec {
    override func spec() {
        var controller: TradeItLoginViewController!
        var linkedBrokerManager: FakeTradeItLinkedBrokerManager!
        var window: UIWindow!
        var nav: UINavigationController!
        var tradeItAlert: FakeTradeItAlert!
        
        describe("initialization") {
            beforeEach {
                window = UIWindow()
                let bundle = NSBundle(identifier: "TradeIt.TradeItIosTicketSDK2Tests")
                let storyboard: UIStoryboard = UIStoryboard(name: "TradeIt", bundle: bundle)

                linkedBrokerManager = FakeTradeItLinkedBrokerManager()
                TradeItLauncher.linkedBrokerManager = linkedBrokerManager

                controller = storyboard.instantiateViewControllerWithIdentifier("TRADE_IT_LOGIN_VIEW") as! TradeItLoginViewController
                controller.selectedBroker = TradeItBroker(shortName: "B5", longName: "Broker #5")
                tradeItAlert = FakeTradeItAlert()
                controller.tradeItAlert = tradeItAlert
                controller.delegate = FakeTradeItLoginViewControllerDelegate()
                nav = UINavigationController(rootViewController: controller)

                window.addSubview(nav.view)

                flushAsyncEvents()
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
            describe("relinking the account") {
                var relinkedBroker: FakeTradeItLinkedBroker!
                beforeEach {
                    relinkedBroker = FakeTradeItLinkedBroker(session: FakeTradeItSession(),
                                                             linkedLogin: TradeItLinkedLogin(label: "my label",
                                                                                             broker: "my broker",
                                                                                             userId: "my userId",
                                                                                             andKeyChainId: "my keychain id"))
                    controller.userNameInput.text = "My Special Username"
                    controller.userNameOnEditingChanged(controller.userNameInput)
                    controller.passwordInput.text = "My Special Password"
                    controller.passwordOnEditingChanged(controller.passwordInput)
                    controller.relinkLinkedBroker = relinkedBroker
                    controller.linkButtonWasTapped(controller.linkButton)
                }
                
                it("uses the linkedBrokerManager to relink the account") {
                    let relinkCalls = linkedBrokerManager.calls.forMethod("relinkBroker(_:authInfo:onSuccess:onFailure:)")
                    
                    expect(relinkCalls.count).to(equal(1))
                    expect(linkedBrokerManager.calls.count).to(equal(1))
                    
                    let linkCallAuthInfo = relinkCalls[0].args["authInfo"] as! TradeItAuthenticationInfo
                    
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
                    beforeEach {
                        let relinkCalls = linkedBrokerManager.calls.forMethod("relinkBroker(_:authInfo:onSuccess:onFailure:)")

                        let onSuccess = relinkCalls[0].args["onSuccess"] as! ((TradeItLinkedBroker) -> Void)
                        
                        onSuccess(relinkedBroker)
                    }
                    
                    it("authenticates the linkedBroker") {
                        let linkCalls = relinkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")
                        expect(linkCalls.count).to(equal(1))
                        expect(linkedBrokerManager.calls.count).to(equal(1))
                    }
                    
                    itBehavesLike("authenticating the broker") {["controller": controller, "linkedBroker": relinkedBroker, "nav": nav]}
                    
                }
                
                context("when relinking fails") {
                    beforeEach {
                        let errorResult = TradeItErrorResult()
                        errorResult.status = "ERROR"
                        errorResult.token = "My Special Token"
                        errorResult.shortMessage = "My Special Error Title"
                        errorResult.longMessages = ["My Special Error Message"]
                        
                        let onFailure = linkedBrokerManager.calls.forMethod("relinkBroker(_:authInfo:onSuccess:onFailure:)")[0].args["onFailure"] as! ((TradeItErrorResult) -> Void)
                        
                        linkedBrokerManager.calls.reset()
                        
                        onFailure(errorResult)
                    }
                    
                    itBehavesLike("linking/relinking fails") {["controller": controller, "nav": nav]}
                    
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
                    
                    itBehavesLike("authenticating the broker") {["controller": controller, "linkedBroker": linkedBroker, "nav": nav]}
                    
                    
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
                    
                    itBehavesLike("linking/relinking fails") {["controller": controller, "nav": nav]}

                }
            }
        }
    }
}

class TradeItLoginViewControllerSpecConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("authenticating the broker"){ (sharedExampleContext: SharedExampleContext) in
            var controller: TradeItLoginViewController!
            var nav: UINavigationController!
            var linkedBroker: FakeTradeItLinkedBroker!
            beforeEach {
                controller = sharedExampleContext()["controller"] as! TradeItLoginViewController
                nav = sharedExampleContext()["nav"] as! UINavigationController!
                linkedBroker = sharedExampleContext()["linkedBroker"] as! FakeTradeItLinkedBroker
            }
            
            it("keeps the link button disabled") {
                expect(controller.linkButton.enabled).to(beFalse())
            }
            
            it("keeps the spinner spinning") {
                expect(controller.activityIndicator.isAnimating()).to(beTrue())
            }
            describe("authentication") {
                context("when authentication succeeds") {
                    beforeEach {
                        let onSuccess = linkedBroker.calls.forMethod("authenticate(onSuccess:onSecurityQuestion:onFailure:)")[0].args["onSuccess"] as! (() -> Void)
                        
                        onSuccess()
                    }
                    it("hides the spinner") {
                        expect(controller.activityIndicator.isAnimating()).to(beFalse())
                    }
                    
                    it("enables the link button") {
                        expect(controller.linkButton.enabled).to(beTrue())
                    }
                    
                    it("calls brokerLinked on  the delegate") {
                        let delegate = controller.delegate as! FakeTradeItLoginViewControllerDelegate
                        let calls = delegate.calls.forMethod("brokerLinked(_:withLinkedBroker:)")
                        let arg1 = calls[0].args["fromTradeItLoginViewController"] as! TradeItLoginViewController
                        let arg2 = calls[0].args["withLinkedBroker"] as! TradeItLinkedBroker
                        expect(calls.count).to(equal(1))
                        expect(arg1).to(equal(controller))
                        expect(arg2).to(equal(linkedBroker))
                        
                    }
                }
                
                context("when authentication fails") {
                    var tradeItAlert: FakeTradeItAlert!
                    beforeEach {
                        tradeItAlert = controller.tradeItAlert as! FakeTradeItAlert
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
                    
                    it("calls the showTradeItErrorResultAlert to show a modal") {
                        let calls = tradeItAlert.calls.forMethod("showTradeItErrorResultAlert(onViewController:errorResult:onAlertDismissed:)")
                        expect(calls.count).to(equal(1))
                    }
                    
                    it("remains on the login screen") {
                        expect(nav.topViewController).toEventually(beAnInstanceOf(TradeItLoginViewController))
                    }
                    
                    describe("dismissing the alert") {
                        beforeEach {
                            let calls = tradeItAlert.calls.forMethod("showTradeItErrorResultAlert(onViewController:errorResult:onAlertDismissed:)")
                            let onCompletion = calls[0].args["onAlertDismissed"] as! () -> Void
                            onCompletion()
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
        
        sharedExamples("linking/relinking fails") { (sharedExampleContext: SharedExampleContext) in
            var controller: TradeItLoginViewController!
            var tradeItAlert: FakeTradeItAlert!
            var nav: UINavigationController!
            beforeEach {
                controller = sharedExampleContext()["controller"] as! TradeItLoginViewController
                tradeItAlert = controller.tradeItAlert as! FakeTradeItAlert
                nav = sharedExampleContext()["nav"] as! UINavigationController

            }
            it("hides the spinner") {
                expect(controller.activityIndicator.isAnimating()).to(beFalse())
            }
            
            it("enables the link button") {
                expect(controller.linkButton.enabled).to(equal(true))
            }
            
            it("calls the showTradeItErrorResultAlert to show a modal") {
                let calls = tradeItAlert.calls.forMethod("showTradeItErrorResultAlert(onViewController:errorResult:onAlertDismissed:)")
                expect(calls.count).to(equal(1))
            }
            
            it("remains on the login screen") {
                expect(nav.topViewController).toEventually(beAnInstanceOf(TradeItLoginViewController))
            }
            
            describe("dismissing the alert") {
                beforeEach {
                        let calls = tradeItAlert.calls.forMethod("showTradeItErrorResultAlert(onViewController:errorResult:onAlertDismissed:)")
                        let onCompletion = calls[0].args["onAlertDismissed"] as! () -> Void
                        onCompletion()
                }
                
                it("remains on the login screen") {
                    expect(nav.topViewController).toEventually(beAnInstanceOf(TradeItLoginViewController))
                }
            }
            
            
        }
    }
    
}

