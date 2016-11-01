import Quick
import Nimble
@testable import TradeItIosTicketSDK2

class TradeItOrderSpec: QuickSpec {
    override func spec() {
        var order: TradeItOrder!
        var linkedBrokerAccount: TradeItLinkedBrokerAccount!

        beforeEach {
            let linkedBroker = FakeTradeItLinkedBroker()
            linkedBrokerAccount = FakeTradeItLinkedBrokerAccount(
                linkedBroker: linkedBroker,
                brokerName: "Fake",
                accountName: "my-special-account-name",
                accountNumber: "my-special-account-number",
                balance: nil,
                fxBalance: nil,
                positions: []
            )
            order = TradeItOrder()
            order.linkedBrokerAccount = linkedBrokerAccount
            order.symbol = "AAPL"
        }

        describe("initialization") {
            it("sets the default action to Buy") {
                expect(order.action).to(equal(TradeItOrderAction.buy))
            }

            it("sets the default type to Market") {
                expect(order.type).to(equal(TradeItOrderPriceType.market))
            }

            it("sets the default expiration to Good for the Day") {
                expect(order.expiration).to(equal(TradeItOrderExpiration.goodForDay))
            }
        }

        describe("requiresLimitPrice")  {
            it("returns true for type Limit") {
                order.type = .limit
                expect(order.requiresLimitPrice()).to(beTrue())
            }

            it("returns true for type Stop Limit") {
                order.type = .stopLimit
                expect(order.requiresLimitPrice()).to(beTrue())
            }

            it("returns false for type Market") {
                order.type = .market
                expect(order.requiresLimitPrice()).to(beFalse())
            }

            it("returns false for type Stop Market") {
                order.type = .stopMarket
                expect(order.requiresLimitPrice()).to(beFalse())
            }
        }

        describe("requiresStopPrice")  {
            it("returns false for type Limit") {
                order.type = .limit
                expect(order.requiresStopPrice()).to(beFalse())
            }

            it("returns true for type Stop Limit") {
                order.type = .stopLimit
                expect(order.requiresStopPrice()).to(beTrue())
            }

            it("returns false for type Market") {
                order.type = .market
                expect(order.requiresStopPrice()).to(beFalse())
            }

            it("returns true for type Stop Market") {
                order.type = .stopMarket
                expect(order.requiresStopPrice()).to(beTrue())
            }
        }

        describe("requiresExpiration")  {
            it("returns true for type Limit") {
                order.type = .limit
                expect(order.requiresExpiration()).to(beTrue())
            }

            it("returns true for type Stop Limit") {
                order.type = .stopLimit
                expect(order.requiresExpiration()).to(beTrue())
            }

            it("returns false for type Market") {
                order.type = .market
                expect(order.requiresExpiration()).to(beFalse())
            }

            it("returns true for type Stop Market") {
                order.type = .stopMarket
                expect(order.requiresExpiration()).to(beTrue())
            }
        }

        describe("estimatedChange") {
            it("returns nil if shares is not a number") {
                order.quantity = NSDecimalNumber.notANumber
                expect(order.estimatedChange()).to(beNil())
            }

            context("when type is Market") {
                beforeEach {
                    order.type = .market
                }

                it("returns nil if no quoteLastPrice is set") {
                    order.quoteLastPrice = nil
                    expect(order.estimatedChange()).to(beNil())
                }

                it("returns the calculation otherwise") {
                    order.quantity = 10
                    order.quoteLastPrice = 1.25
                    expect(order.estimatedChange()).to(equal(12.5))
                }
            }

            context("when type is Stop Market") {
                beforeEach {
                    order.type = .stopMarket
                }

                it("returns nil if stopPrice is not a number") {
                    order.stopPrice = NSDecimalNumber.notANumber
                    expect(order.estimatedChange()).to(beNil())
                }

                it("returns nil if no stopPrice is set") {
                    order.stopPrice = nil
                    expect(order.estimatedChange()).to(beNil())
                }

                it("returns the calculation otherwise") {
                    order.quantity = 5
                    order.stopPrice = 1.5
                    expect(order.estimatedChange()).to(equal(7.5))
                }
            }

            context("when type is Limit") {
                beforeEach {
                    order.type = .limit
                }

                it("returns nil if limitPrice is not a number") {
                    order.limitPrice = NSDecimalNumber.notANumber
                    expect(order.estimatedChange()).to(beNil())
                }

                it("returns nil if no limitPrice is set") {
                    order.limitPrice = nil
                    expect(order.estimatedChange()).to(beNil())
                }

                it("returns the calculation otherwise") {
                    order.quantity = 5
                    order.limitPrice = 1.5
                    expect(order.estimatedChange()).to(equal(7.5))
                }
            }

            context("when type is Stop Limit") {
                beforeEach {
                    order.type = .stopLimit
                }

                it("returns nil if limitPrice is not a number") {
                    order.limitPrice = NSDecimalNumber.notANumber
                    expect(order.estimatedChange()).to(beNil())
                }

                it("returns nil if no limitPrice is set") {
                    order.limitPrice = nil
                    expect(order.estimatedChange()).to(beNil())
                }

                it("returns the calculation otherwise") {
                    order.quantity = 5
                    order.limitPrice = 1.5
                    expect(order.estimatedChange()).to(equal(7.5))
                }
            }
        }

        describe("isValid") {
            context("for type Market") {
                beforeEach {
                    order.type = .market
                }

                it("returns true when quantity is present") {
                    order.quantity = NSDecimalNumber(value: 12)
                    expect(order.isValid()).to(beTrue())
                }

                it("returns false when quantity is nil") {
                    order.quantity = nil
                    expect(order.isValid()).to(beFalse())
                }
            }

            context("for type Limit") {
                beforeEach {
                    order.type = .limit
                    order.quantity = NSDecimalNumber(value: 12)
                    order.limitPrice = NSDecimalNumber(value: 5)
                }

                it("returns true when quantity and limitPrice are set") {
                    expect(order.isValid()).to(beTrue())
                }

                it("returns false when quantity is nil") {
                    order.quantity = nil
                    expect(order.isValid()).to(beFalse())
                }

                it("returns false when limitPrice is nil") {
                    order.limitPrice = nil
                    expect(order.isValid()).to(beFalse())
                }
            }

            context("for type Stop Market") {
                beforeEach {
                    order.type = .stopMarket
                    order.quantity = NSDecimalNumber(value: 12)
                    order.stopPrice = NSDecimalNumber(value: 5)
                }

                it("returns true when quantity and stopPrice are set") {
                    expect(order.isValid()).to(beTrue())
                }

                it("returns false when quantity is nil") {
                    order.quantity = nil
                    expect(order.isValid()).to(beFalse())
                }

                it("returns false when stopPrice is nil") {
                    order.stopPrice = nil
                    expect(order.isValid()).to(beFalse())
                }
            }

            context("for type Stop Limit") {
                beforeEach {
                    order.type = .stopLimit
                    order.quantity = NSDecimalNumber(value: 12)
                    order.limitPrice = NSDecimalNumber(value: 5)
                    order.stopPrice = NSDecimalNumber(value: 5)
                }

                it("returns true when quantity, limitPrice and stopPrice are set") {
                    expect(order.isValid()).to(beTrue())
                }

                it("returns false when quantity is nil") {
                    order.quantity = nil
                    expect(order.isValid()).to(beFalse())
                }

                it("returns false when stopPrice is nil") {
                    order.stopPrice = nil
                    expect(order.isValid()).to(beFalse())
                }

                it("returns false when limitPrice is nil") {
                    order.limitPrice = nil
                    expect(order.isValid()).to(beFalse())
                }
            }
        }

        describe("preview") {
            var order: TradeItOrder!
            var expectedResponse: TradeItResult!
            var actualResponse: TradeItResult!
            var onSuccessWasCalled = false
            var onFailureWasCalled = false
            var linkedBrokerAccount: FakeTradeItLinkedBrokerAccount!
            var tradeService: FakeTradeItTradeService!

            beforeEach {
                linkedBrokerAccount = FakeTradeItLinkedBrokerAccount(linkedBroker: FakeTradeItLinkedBroker(), brokerName: "Dummy", accountName: "Dummy Account Name", accountNumber: "Dummy Account Number", balance: nil, fxBalance: nil, positions: [])
                tradeService = FakeTradeItTradeService()
                linkedBrokerAccount.tradeService = tradeService
                order = TradeItOrder(linkedBrokerAccount: linkedBrokerAccount, symbol: "AAPL")
                order.quantity = 1.0

                onSuccessWasCalled = false
                order.preview(onSuccess: { previewTradeResult, handlers in
                    onSuccessWasCalled = true
                    actualResponse = previewTradeResult
                }, onFailure: { errorResult in
                    onFailureWasCalled = true
                    actualResponse = errorResult
                })

            }

            xcontext("when it was successful") {
                beforeEach {
                    expectedResponse = TradeItPreviewTradeResult()
                    let completionBlock = tradeService.calls.forMethod("previewTrade(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
                    completionBlock(expectedResponse)
                }

                it("calls onSuccess") {
                    flushAsyncEvents()

                    expect(onSuccessWasCalled).to(beTrue())
                    expect(onFailureWasCalled).to(beFalse())
                    expect(actualResponse).to(equal(expectedResponse))
                }
            }

            xcontext("when it was a failure") {
                beforeEach {
                    expectedResponse = TradeItErrorResult()
                    let completionBlock = tradeService.calls.forMethod("previewTrade(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! ((TradeItResult!) -> Void)
                    completionBlock(expectedResponse)
                }

                it("calls onSuccess") {
                    flushAsyncEvents()

                    expect(onSuccessWasCalled).to(beFalse())
                    expect(onFailureWasCalled).to(beTrue())
                    expect(actualResponse).to(equal(expectedResponse))
                }
            }
        }
    }
}
