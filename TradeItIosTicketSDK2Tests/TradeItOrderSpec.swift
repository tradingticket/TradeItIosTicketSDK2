import Quick
import Nimble
import TradeItIosEmsApi

class TradeItOrderSpec: QuickSpec {
    override func spec() {
        var order: TradeItOrder!
        var brokerAccount: TradeItLinkedBrokerAccount!

        beforeEach {
            let linkedBroker = FakeTradeItLinkedBroker()
            brokerAccount = FakeTradeItLinkedBrokerAccount(
                linkedBroker: linkedBroker,
                brokerName: "Fake",
                accountName: "my-special-account-name",
                accountNumber: "my-special-account-number",
                balance: nil,
                fxBalance: nil,
                positions: []
            )
            order = TradeItOrder(brokerAccount: brokerAccount, symbol: "AAPL")
        }

        describe("initialization") {
            it("sets the broker account") {
                expect(order.brokerAccount).to(equal(brokerAccount))
            }

            it("sets the symbol") {
                expect(order.symbol).to(equal("AAPL"))
            }

            it("sets the default action to Buy") {
                expect(order.action).to(equal("Buy"))
            }

            it("sets the default type to Market") {
                expect(order.type).to(equal(TradeItOrder.OrderType.Market))
            }

            it("sets the default expiration to Good for the Day") {
                expect(order.expiration).to(equal("Good for the Day"))
            }
        }

        describe("requiresLimitPrice")  {
            it("returns true for type Limit") {
                order.type = .Limit
                expect(order.requiresLimitPrice()).to(beTrue())
            }

            it("returns true for type Stop Limit") {
                order.type = .StopLimit
                expect(order.requiresLimitPrice()).to(beTrue())
            }

            it("returns false for type Market") {
                order.type = .Market
                expect(order.requiresLimitPrice()).to(beFalse())
            }

            it("returns false for type Stop Market") {
                order.type = .StopMarket
                expect(order.requiresLimitPrice()).to(beFalse())
            }
        }

        describe("requiresStopPrice")  {
            it("returns false for type Limit") {
                order.type = .Limit
                expect(order.requiresStopPrice()).to(beFalse())
            }

            it("returns true for type Stop Limit") {
                order.type = .StopLimit
                expect(order.requiresStopPrice()).to(beTrue())
            }

            it("returns false for type Market") {
                order.type = .Market
                expect(order.requiresStopPrice()).to(beFalse())
            }

            it("returns true for type Stop Market") {
                order.type = .StopMarket
                expect(order.requiresStopPrice()).to(beTrue())
            }
        }

        describe("requiresExpiration")  {
            it("returns true for type Limit") {
                order.type = .Limit
                expect(order.requiresExpiration()).to(beTrue())
            }

            it("returns true for type Stop Limit") {
                order.type = .StopLimit
                expect(order.requiresExpiration()).to(beTrue())
            }

            it("returns false for type Market") {
                order.type = .Market
                expect(order.requiresExpiration()).to(beFalse())
            }

            it("returns true for type Stop Market") {
                order.type = .StopMarket
                expect(order.requiresExpiration()).to(beTrue())
            }
        }

        describe("estimatedChange") {
            it("returns nil if no quoteLastPrice is set") {
                order.quoteLastPrice = nil
                expect(order.estimatedChange()).to(beNil())
            }

            it("returns nil if shares is not a number") {
                order.shares = NSDecimalNumber.notANumber()
                expect(order.estimatedChange()).to(beNil())
            }

            it("returns the calculation otherwise") {
                order.shares = 10
                order.quoteLastPrice = 1.25
                expect(order.estimatedChange()).to(equal(12.5))
            }
        }

        describe("isValid") {
            context("for type Market") {
                beforeEach {
                    order.type = .Market
                }

                it("returns true when shares is present") {
                    order.shares = NSDecimalNumber(integer: 12)
                    expect(order.isValid()).to(beTrue())
                }

                it("returns false when shares is nil") {
                    order.shares = nil
                    expect(order.isValid()).to(beFalse())
                }
            }

            context("for type Limit") {
                beforeEach {
                    order.type = .Limit
                    order.shares = NSDecimalNumber(integer: 12)
                    order.limitPrice = NSDecimalNumber(integer: 5)
                }

                it("returns true when shares and limitPrice are set") {
                    expect(order.isValid()).to(beTrue())
                }

                it("returns false when shares is nil") {
                    order.shares = nil
                    expect(order.isValid()).to(beFalse())
                }

                it("returns false when limitPrice is nil") {
                    order.limitPrice = nil
                    expect(order.isValid()).to(beFalse())
                }
            }

            context("for type Stop Market") {
                beforeEach {
                    order.type = .StopMarket
                    order.shares = NSDecimalNumber(integer: 12)
                    order.stopPrice = NSDecimalNumber(integer: 5)
                }

                it("returns true when shares and stopPrice are set") {
                    expect(order.isValid()).to(beTrue())
                }

                it("returns false when shares is nil") {
                    order.shares = nil
                    expect(order.isValid()).to(beFalse())
                }

                it("returns false when stopPrice is nil") {
                    order.stopPrice = nil
                    expect(order.isValid()).to(beFalse())
                }
            }

            context("for type Stop Limit") {
                beforeEach {
                    order.type = .StopLimit
                    order.shares = NSDecimalNumber(integer: 12)
                    order.limitPrice = NSDecimalNumber(integer: 5)
                    order.stopPrice = NSDecimalNumber(integer: 5)
                }

                it("returns true when shares, limitPrice and stopPrice are set") {
                    expect(order.isValid()).to(beTrue())
                }

                it("returns false when shares is nil") {
                    order.shares = nil
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
    }
}
