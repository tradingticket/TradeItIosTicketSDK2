import Quick
import Nimble

class TradeItLinkedBrokerAccountSpec: QuickSpec {
    override func spec() {
        var tradeItLinkedBrokerAccount: TradeItLinkedBrokerAccount!
        var tradeItBalanceService: FakeTradeItBalanceService!
        var tradeItPositionService: FakeTradeItPositionService!
        var linkedBroker: FakeTradeItLinkedBroker!
        beforeEach {
            linkedBroker = FakeTradeItLinkedBroker(session: FakeTradeItSession(), linkedLogin: TradeItLinkedLogin())
            tradeItLinkedBrokerAccount = TradeItLinkedBrokerAccount(linkedBroker: linkedBroker, brokerName: "My special broker name", accountName: "My special account name", accountNumber: "My special account number", balance: nil, fxBalance: nil, positions: [])
            linkedBroker.accounts = [tradeItLinkedBrokerAccount]
            tradeItBalanceService = FakeTradeItBalanceService()
            tradeItPositionService = FakeTradeItPositionService()
            tradeItLinkedBrokerAccount.tradeItBalanceService = tradeItBalanceService
            tradeItLinkedBrokerAccount.tradeItPositionService = tradeItPositionService
        }

        // TODO: Needs to be fixed to use standard onSuccess/onFailure and not withCompletion
        xdescribe("getAccountOverview") {
            var isFinished = false
            beforeEach {
                tradeItLinkedBrokerAccount.getAccountOverview(
                    onFinished: {
                        isFinished = true
                    }
                )
            }
            
            it("doesn't call onFinished yet") {
                expect(isFinished).to(beFalse())
            }
            
            context("when getAccountOverview fails") {
                beforeEach {
                    isFinished = false
                    let tradeItErrorResult = TradeItErrorResult()
                    let completionBlock = tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! (tradeItResult: TradeItResult!) -> Void
                    completionBlock(tradeItResult: tradeItErrorResult)
                }

                it("calls onFinished") {
                    expect(isFinished).to(beTrue())
                }
            }
            
            context("when getAccountOverview successfuly fetches an equity balance") {
                var accountOverview: TradeItAccountOverview!
                beforeEach {
                    isFinished = false
                    let tradeItAccountOverviewResult = TradeItAccountOverviewResult()
                    accountOverview = TradeItAccountOverview()
                    accountOverview.accountBaseCurrency = "My account base currency"
                    accountOverview.availableCash = 12345
                    accountOverview.buyingPower = 2345
                    accountOverview.dayAbsoluteReturn = 145
                    accountOverview.dayPercentReturn = 5.43
                    
                    tradeItAccountOverviewResult.accountOverview = accountOverview
                    tradeItAccountOverviewResult.fxAccountOverview = nil
                    let completionBlock = tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! (tradeItResult: TradeItResult!) -> Void
                    completionBlock(tradeItResult: tradeItAccountOverviewResult)
                }

                it("updates the balance property") {
                    expect(tradeItLinkedBrokerAccount.balance.accountBaseCurrency).to(equal(accountOverview.accountBaseCurrency))
                    expect(tradeItLinkedBrokerAccount.balance.availableCash).to(equal(accountOverview.availableCash))
                    expect(tradeItLinkedBrokerAccount.balance.buyingPower).to(equal(accountOverview.buyingPower))
                    expect(tradeItLinkedBrokerAccount.balance.dayAbsoluteReturn).to(equal(accountOverview.dayAbsoluteReturn))
                    expect(tradeItLinkedBrokerAccount.balance.dayPercentReturn).to(equal(accountOverview.dayPercentReturn))
                    expect(tradeItLinkedBrokerAccount.fxBalance).to(beNil())
                }
                
                it("calls onFinished") {
                    expect(isFinished).to(beTrue())
                }
            }
            
            context("when getAccountOverview successfuly fetches an fx balance") {
                var fxAccountOverview: TradeItFxAccountOverview!
                beforeEach {
                    let tradeItAccountOverviewResult = TradeItAccountOverviewResult()
                    fxAccountOverview = TradeItFxAccountOverview()
                    fxAccountOverview.buyingPowerBaseCurrency = 6543678
                    fxAccountOverview.realizedProfitAndLossBaseCurrency = 12345
                    fxAccountOverview.totalValueBaseCurrency = 45678
                    fxAccountOverview.totalValueUSD = 9876
                    fxAccountOverview.unrealizedProfitAndLossBaseCurrency = 45463
                    
                    tradeItAccountOverviewResult.fxAccountOverview = fxAccountOverview
                    tradeItAccountOverviewResult.accountOverview = nil
                    let completionBlock = tradeItBalanceService.calls.forMethod("getAccountOverview(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! (tradeItResult: TradeItResult!) -> Void
                    completionBlock(tradeItResult: tradeItAccountOverviewResult)
                }
                
                it("updates the fxBalance property") {
                    expect(tradeItLinkedBrokerAccount.fxBalance.buyingPowerBaseCurrency).to(equal(fxAccountOverview.buyingPowerBaseCurrency))
                    expect(tradeItLinkedBrokerAccount.fxBalance.realizedProfitAndLossBaseCurrency).to(equal(fxAccountOverview.realizedProfitAndLossBaseCurrency))
                    expect(tradeItLinkedBrokerAccount.fxBalance.totalValueBaseCurrency).to(equal(fxAccountOverview.totalValueBaseCurrency))
                    expect(tradeItLinkedBrokerAccount.fxBalance.totalValueUSD).to(equal(fxAccountOverview.totalValueUSD))
                    expect(tradeItLinkedBrokerAccount.fxBalance.unrealizedProfitAndLossBaseCurrency).to(equal(fxAccountOverview.unrealizedProfitAndLossBaseCurrency))

                    expect(tradeItLinkedBrokerAccount.balance).to(beNil())
                }
                
                it("calls onFinished") {
                    expect(isFinished).to(beTrue())
                }
            }
        }
        
        describe("getPositions") {
            var isFinished = false
            beforeEach {
                tradeItLinkedBrokerAccount.getPositions(
                    onFinished: {
                        isFinished = true
                    }
                )
            }
            
            it("doesn't call onFinished yet") {
                expect(isFinished).to(beFalse())
            }
            
            context("when getPositions fails") {
                beforeEach {
                    isFinished = false
                    let tradeItErrorResult = TradeItErrorResult()
                    let completionBlock = tradeItPositionService.calls.forMethod("getAccountPositions(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! (tradeItResult: TradeItResult!) -> Void
                    completionBlock(tradeItResult: tradeItErrorResult)
                }
                
                it("updates the property isPositionsError to true") {
                    expect(tradeItLinkedBrokerAccount.isPositionsError).to(beTrue())
                }
                
                it("calls onFinished") {
                    expect(isFinished).to(beTrue())
                }
            }
            
            context("when getPositions succeeds") {
                var positions: [TradeItPosition] = []
                beforeEach {
                    isFinished = false
                    let tradeItGetPositionsResult = TradeItGetPositionsResult()
                    let position = TradeItPosition()
                    position.costbasis = 123
                    position.holdingType = "LONG"
                    position.lastPrice = 345
                    position.quantity = 12
                    position.symbol = "My special symbol"
                    position.symbolClass = "My special symbol class"
                    position.todayGainLossDollar = 234
                    position.todayGainLossPercentage = 12
                    positions = [position]
                    tradeItGetPositionsResult.positions = positions
                    tradeItGetPositionsResult.fxPositions = []
                    let completionBlock = tradeItPositionService.calls.forMethod("getAccountPositions(_:withCompletionBlock:)")[0].args["withCompletionBlock"] as! (tradeItResult: TradeItResult!) -> Void
                    completionBlock(tradeItResult: tradeItGetPositionsResult)
                }
                
                it("updates the property isPositionsError to false") {
                    expect(tradeItLinkedBrokerAccount.isPositionsError).to(beFalse())
                }
                
                it("fills the positions table on the linkedBrokerAccount") {
                    expect(tradeItLinkedBrokerAccount.positions[0].position).to(be(positions[0]))
                }
                
                it("calls onFinished") {
                    expect(isFinished).to(beTrue())
                }
            }
        }
        
        describe("getFormattedAccountName") {
            context("when account number > 4 and accountName < 10") {
                var returnedValue = ""
                beforeEach {
                    tradeItLinkedBrokerAccount.accountNumber = "123456"
                    tradeItLinkedBrokerAccount.accountName = "short name"
                    returnedValue =  tradeItLinkedBrokerAccount.getFormattedAccountName()
                }
                
                it("returns the expected formatted account name") {
                    expect(returnedValue).to(equal("short name**3456"))
                }
            }
            context("when account number < 4 and accountName < 10") {
                var returnedValue = ""
                beforeEach {
                    tradeItLinkedBrokerAccount.accountNumber = "123"
                    tradeItLinkedBrokerAccount.accountName = "short name"
                    returnedValue =  tradeItLinkedBrokerAccount.getFormattedAccountName()
                }
                
                it("returns the expected formatted account name") {
                    expect(returnedValue).to(equal("short name 123"))
                }
            }
            context("when account number > 4 and accountName > 10") {
                var returnedValue = ""
                beforeEach {
                    tradeItLinkedBrokerAccount.accountNumber = "123456"
                    tradeItLinkedBrokerAccount.accountName = "My super long account name"
                    returnedValue =  tradeItLinkedBrokerAccount.getFormattedAccountName()
                }
                
                it("returns the expected formatted account name") {
                    expect(returnedValue).to(equal("My super l**3456"))
                }
            }
            
            context("when account number < 4 and accountName > 10") {
                var returnedValue = ""
                beforeEach {
                    tradeItLinkedBrokerAccount.accountNumber = "123"
                    tradeItLinkedBrokerAccount.accountName = "My super long account name"
                    returnedValue =  tradeItLinkedBrokerAccount.getFormattedAccountName()
                }
                
                it("returns the expected formatted account name") {
                    expect(returnedValue).to(equal("My super l**123"))
                }
            }
            
        }
        
        describe("getFormattedBuyingPower") {
            context("when balance and fxBalance are nil") {
                var returnedValue = ""
                beforeEach {
                    tradeItLinkedBrokerAccount.fxBalance = nil
                    tradeItLinkedBrokerAccount.balance = nil
                    returnedValue =  tradeItLinkedBrokerAccount.getFormattedBuyingPower()

                }
                it("returns N/A") {
                    expect(returnedValue).to(equal("N/A"))
                }
            }
            
            context("when balance only is not nil") {
                var returnedValue = ""
                beforeEach {
                    let accountOverview = TradeItAccountOverview()
                    accountOverview.accountBaseCurrency = "My account base currency"
                    accountOverview.availableCash = 12345
                    accountOverview.buyingPower = 2345
                    accountOverview.dayAbsoluteReturn = 145
                    accountOverview.dayPercentReturn = 5.43
                    tradeItLinkedBrokerAccount.balance = accountOverview
                    tradeItLinkedBrokerAccount.fxBalance = nil
                    returnedValue =  tradeItLinkedBrokerAccount.getFormattedBuyingPower()
                    
                }
                it("returns the expected format") {
                    expect(returnedValue).to(equal("$2,345.00"))
                }
            }
            
            context("when fxBalance only is not nil") {
                var returnedValue = ""
                beforeEach {
                    let fxAccountOverview = TradeItFxAccountOverview()
                    fxAccountOverview.buyingPowerBaseCurrency = 6543678
                    fxAccountOverview.realizedProfitAndLossBaseCurrency = 12345
                    fxAccountOverview.totalValueBaseCurrency = 45678
                    fxAccountOverview.totalValueUSD = 9876
                    fxAccountOverview.unrealizedProfitAndLossBaseCurrency = 45463
                    
                    tradeItLinkedBrokerAccount.fxBalance = fxAccountOverview
                    tradeItLinkedBrokerAccount.balance = nil
                    returnedValue =  tradeItLinkedBrokerAccount.getFormattedBuyingPower()
                    
                }
                it("returns the expected format") {
                    expect(returnedValue).to(equal("$6,543,678.00"))
                }
            }
        }
        
        describe("getFormattedTotalValue") {
            context("when balance and fxBalance are nil") {
                var returnedValue = ""
                beforeEach {
                    tradeItLinkedBrokerAccount.fxBalance = nil
                    tradeItLinkedBrokerAccount.balance = nil
                    returnedValue =  tradeItLinkedBrokerAccount.getFormattedTotalValueWithPercentage()
                    
                }
                it("returns N/A") {
                    expect(returnedValue).to(equal("N/A"))
                }
            }
            context("when balance only is not nil and there is no totalPercent returned") {
                var returnedValue = ""
                beforeEach {
                    let accountOverview = TradeItAccountOverview()
                    accountOverview.accountBaseCurrency = "My account base currency"
                    accountOverview.availableCash = 12345
                    accountOverview.buyingPower = 2345
                    accountOverview.dayAbsoluteReturn = 145
                    accountOverview.dayPercentReturn = 5.43
                    accountOverview.totalValue = 45678
                    tradeItLinkedBrokerAccount.balance = accountOverview
                    tradeItLinkedBrokerAccount.fxBalance = nil
                    returnedValue =  tradeItLinkedBrokerAccount.getFormattedTotalValueWithPercentage()
                    
                }
                it("returns the expected format") {
                    expect(returnedValue).to(equal("$45,678.00"))
                }
            }
            
            context("when balance only is not nil and there is totalPercent returned") {
                var returnedValue = ""
                beforeEach {
                    let accountOverview = TradeItAccountOverview()
                    accountOverview.accountBaseCurrency = "My account base currency"
                    accountOverview.availableCash = 12345
                    accountOverview.buyingPower = 2345
                    accountOverview.dayAbsoluteReturn = 145
                    accountOverview.dayPercentReturn = 5.43
                    accountOverview.totalValue = 45678
                    accountOverview.totalPercentReturn = 5.43
                    tradeItLinkedBrokerAccount.balance = accountOverview
                    tradeItLinkedBrokerAccount.fxBalance = nil
                    returnedValue =  tradeItLinkedBrokerAccount.getFormattedTotalValueWithPercentage()
                    
                }
                it("returns the expected format") {
                    expect(returnedValue).to(equal("$45,678.00 (5.43%)"))
                }
            }
            
            context("when fxBalance only is not nil and unrealized profit == 0") {
                var returnedValue = ""
                beforeEach {
                    let fxAccountOverview = TradeItFxAccountOverview()
                    fxAccountOverview.buyingPowerBaseCurrency = 6543678
                    fxAccountOverview.realizedProfitAndLossBaseCurrency = 12345
                    fxAccountOverview.totalValueBaseCurrency = 40678
                    fxAccountOverview.totalValueUSD = 9876
                    
                    tradeItLinkedBrokerAccount.fxBalance = fxAccountOverview
                    tradeItLinkedBrokerAccount.balance = nil
                    returnedValue =  tradeItLinkedBrokerAccount.getFormattedTotalValueWithPercentage()
                    
                }
                it("returns the expected format") {
                    expect(returnedValue).to(equal("$40,678"))
                }
            }
            
            context("when fxBalance only is not nil and unrealized profit != 0") {
                var returnedValue = ""
                beforeEach {
                    let fxAccountOverview = TradeItFxAccountOverview()
                    fxAccountOverview.buyingPowerBaseCurrency = 6543678
                    fxAccountOverview.realizedProfitAndLossBaseCurrency = 12345
                    fxAccountOverview.totalValueBaseCurrency = 40678
                    fxAccountOverview.totalValueUSD = 9876
                    fxAccountOverview.unrealizedProfitAndLossBaseCurrency = 45463
                    
                    tradeItLinkedBrokerAccount.fxBalance = fxAccountOverview
                    tradeItLinkedBrokerAccount.balance = nil
                    returnedValue =  tradeItLinkedBrokerAccount.getFormattedTotalValueWithPercentage()
                    
                }
                it("returns the expected format") {
                    expect(returnedValue).to(equal("$40,678 (-9.5%)"))
                }
            }
        }
    }
}
