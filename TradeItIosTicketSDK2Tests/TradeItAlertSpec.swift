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
                        
                        tradeItAlert.showTradeItErrorResultAlert(onController: controller, withError: error)
                    }
                    
                    it("display a modal with an empty title and message") {
                        expect(controller.presentedViewController).toEventually(beAnInstanceOf(UIAlertController))
                        expect(controller.presentedViewController?.title).to(equal(""))
                    }
                }
                
                context("when there are nil shotMessage and nil longMessages") {
                    beforeEach {
                        let error = TradeItErrorResult()
                        tradeItAlert.showTradeItErrorResultAlert(onController: controller, withError: error)
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
                        tradeItAlert.showTradeItErrorResultAlert(onController: controller, withError: error)
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
                        tradeItAlert.showTradeItErrorResultAlert(onController: controller, withError: error)
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
                    tradeItAlert.showErrorAlert(onController: controller, withTitle: title, withMessage: message)
                }
                
                it("display a modal with an empty title and message") {
                    expect(controller.presentedViewController).toEventually(beAnInstanceOf(UIAlertController))
                    let alert = controller.presentedViewController as! UIAlertController
                    expect(alert.title).to(equal(title))
                    expect(alert.message).to(equal(message))
                }

            }
            
        }
    }
    
}
