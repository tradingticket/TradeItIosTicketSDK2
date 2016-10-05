import Quick
import Nimble
import UIKit
import TradeItIosEmsApi

class TradeItAlertSpec: QuickSpec {
    override func spec() {
        var controller: UIViewController!
        var window: UIWindow!
        var tradeItAlert: TradeItAlert!

        describe("initialization") {
            beforeEach {
                window = UIWindow()
                controller = UIViewController()
                tradeItAlert = TradeItAlert()
                window.addSubview(controller.view)
            }
            
            describe("showTradeItErrorResultAlert") {
                context("when there are nil shotMessage and nil longMessages") {
                    beforeEach {
                        let error = TradeItErrorResult()
                        flushAsyncEvents()
                        
                        tradeItAlert.showTradeItErrorResultAlert(onViewController: controller, errorResult: error)
                    }
                    
                    it("display a modal with an empty title and message") {
                        expect(controller.presentedViewController).toEventually(beAnInstanceOf(UIAlertController))
                        expect(controller.presentedViewController?.title).to(equal(""))
                    }
                }
                
                context("when there are nil shotMessage and nil longMessages") {
                    beforeEach {
                        let error = TradeItErrorResult()
                        tradeItAlert.showTradeItErrorResultAlert(onViewController: controller, errorResult: error)
                    }
                    
                    it("display a modal with an empty title and message") {
                        expect(controller.presentedViewController).toEventually(beAnInstanceOf(UIAlertController))
                        let alert = controller.presentedViewController as! UIAlertController
                        expect(alert.title).to(equal(""))
                        expect(alert.message).to(equal(""))
                    }
                }
                
                context("when there are non nil shotMessage and one non nil longMessages") {
                    beforeEach {
                        let error = TradeItErrorResult()
                        error.shortMessage = "My special short message."
                        error.longMessages = ["My special long message."]
                        tradeItAlert.showTradeItErrorResultAlert(onViewController: controller, errorResult: error)
                    }
                    
                    it("display a modal with an empty title and message") {
                        expect(controller.presentedViewController).toEventually(beAnInstanceOf(UIAlertController))
                        let alert = controller.presentedViewController as! UIAlertController
                        expect(alert.title).to(equal("My special short message."))
                        expect(alert.message).to(equal("My special long message."))
                    }
                }
                
                context("when there are non nil shotMessage and two non nil longMessages") {
                    beforeEach {
                        let error = TradeItErrorResult()
                        error.shortMessage = "My special short message."
                        error.longMessages = ["My special long message.", "My special 2 long message."]
                        tradeItAlert.showTradeItErrorResultAlert(onViewController: controller, errorResult: error)
                    }
                    
                    it("display a modal with an empty title and message") {
                        expect(controller.presentedViewController).toEventually(beAnInstanceOf(UIAlertController))
                        let alert = controller.presentedViewController as! UIAlertController
                        expect(alert.title).to(equal("My special short message."))
                        expect(alert.message).to(equal("My special long message. My special 2 long message."))
                    }
                }
            }
            
            describe("showErrorAlert") {
                var title: String!
                var message: String!

                beforeEach {
                    title = "My special title."
                    message = "My special message."
                    tradeItAlert.showErrorAlert(onViewController: controller, title: title, message: message)
                }
                
                it("display a modal with an empty title and message") {
                    expect(controller.presentedViewController).toEventually(beAnInstanceOf(UIAlertController))
                    let alert = controller.presentedViewController as! UIAlertController
                    expect(alert.title).to(equal(title))
                    expect(alert.message).to(equal(message))
                }
            }

            describe("show:securityQuestion:onViewController") {
                it("displays the security question with a text field") {
                    let securityQuestion = TradeItSecurityQuestionResult()
                    securityQuestion.securityQuestion = "What is your quest?"
                    let onAnswerSecurityQuestion: (String) -> Void = { _ in }

                    tradeItAlert.show(
                        securityQuestion: securityQuestion,
                        onViewController: controller,
                        onAnswerSecurityQuestion: onAnswerSecurityQuestion
                    )

                    let alert = controller.presentedViewController as! UIAlertController
                    expect(alert.title).to(equal("Security Question"))
                    expect(alert.message).to(equal("What is your quest?"))
                    expect(alert.textFields!.count).to(equal(1))
                    expect(alert.textFields!.first).to(beAKindOf(UITextField))
                }
            }
        }
    }
}
