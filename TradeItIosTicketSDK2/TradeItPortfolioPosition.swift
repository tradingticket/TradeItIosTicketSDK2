import TradeItIosEmsApi

class TradeItPortfolioPosition : NSObject {
    var position: TradeItPosition!
    var fxPosition: TradeItFxPosition!
    var quote: TradeItQuote!
    var tradeItMarketDataService: TradeItMarketDataService!
    unowned var linkedBrokerAccount: TradeItLinkedBrokerAccount

    static let fxMaximumFractionDigits = 5
    
    init(linkedBrokerAccount: TradeItLinkedBrokerAccount, position: TradeItPosition) {
        self.linkedBrokerAccount = linkedBrokerAccount
        self.position = position
        self.tradeItMarketDataService = TradeItMarketDataService(session: linkedBrokerAccount.linkedBroker.session)
    }
    
    init(linkedBrokerAccount: TradeItLinkedBrokerAccount, fxPosition: TradeItFxPosition) {
        self.linkedBrokerAccount = linkedBrokerAccount
        self.fxPosition = fxPosition
        self.tradeItMarketDataService = TradeItMarketDataService(session: linkedBrokerAccount.linkedBroker.session)
    }
    
    func refreshQuote(onFinished onFinished: () -> Void) {
        var tradeItQuoteRequest: TradeItQuotesRequest!
        var symbol = ""
        if let position = self.position {
            symbol = position.symbol
            tradeItQuoteRequest = TradeItQuotesRequest(symbol: symbol)
        }
        if let fxPosition = self.fxPosition {
                symbol = fxPosition.symbol
                tradeItQuoteRequest = TradeItQuotesRequest(fxSymbol: symbol, andBroker: self.linkedBrokerAccount.brokerName)
        }
        var quote = TradeItQuote()
        self.tradeItMarketDataService.getQuoteData(tradeItQuoteRequest, withCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
            if let tradeItQuoteResult = tradeItResult as? TradeItQuotesResult {
                let results = tradeItQuoteResult.quotes.filter { return $0.symbol == symbol}
                if results.count > 0 {
                    quote = results[0] as! TradeItQuote
                    self.quote = quote
                }
            }
            else {
                //TODO handle error
                print("error quote")
            }
            onFinished()
        })
    }
    
    func getFormattedBid() -> String {
        var bid = "N/A"
        if let quote = self.quote {
            if self.position != nil {
                bid = NumberFormatter.formatCurrency(quote.bidPrice)
            }
            else if fxPosition != nil {
                bid = NumberFormatter.formatCurrency(quote.bidPrice, maximumFractionDigits: TradeItPortfolioPosition.fxMaximumFractionDigits)
            }
        }
        return bid
    }
    
    func getFormattedAsk() -> String {
        var ask = "N/A"
        if let quote = self.quote {
            if self.position != nil {
                ask = NumberFormatter.formatCurrency(quote.askPrice)
            }
            else if fxPosition != nil {
                ask = NumberFormatter.formatCurrency(quote.askPrice, maximumFractionDigits: TradeItPortfolioPosition.fxMaximumFractionDigits)
            }
        }
        return ask
    }
    
    func getFormattedSpread() -> String {
        var spread = "N/A"
        if let quote = self.quote {
            let high = quote.high as Float
            let low = quote.low as Float
            if self.position != nil {
                spread = NumberFormatter.formatCurrency(high - low)
            }
            else if fxPosition != nil {
                spread = NumberFormatter.formatCurrency(high - low, maximumFractionDigits: TradeItPortfolioPosition.fxMaximumFractionDigits)
            }
        }
        return spread
    }
    
    func getFormattedTotalValue() -> String {
        var totalValue = "N/A"
        if let quote = self.quote {
            let total = (self.position.quantity as Float) * (quote.lastPrice as Float)
            if self.position != nil {
                totalValue = NumberFormatter.formatCurrency(total);
            }
            else if fxPosition != nil {
                totalValue = NumberFormatter.formatCurrency(total, maximumFractionDigits: TradeItPortfolioPosition.fxMaximumFractionDigits)
            }
        }
        return totalValue
    }

    func getFormattedDayHighLow() -> String {
        var dayHighLow = "N/A"
        if let quote = self.quote {
            let high = quote.high
            let low = quote.low
            if self.position != nil {
                dayHighLow = NumberFormatter.formatCurrency(low) + " - " + NumberFormatter.formatCurrency(high)
            }
            else if self.fxPosition != nil {
                dayHighLow = NumberFormatter.formatCurrency(low, maximumFractionDigits: TradeItPortfolioPosition.fxMaximumFractionDigits) + " - " + NumberFormatter.formatCurrency(high, maximumFractionDigits: TradeItPortfolioPosition.fxMaximumFractionDigits)
            }
        }
        return dayHighLow
    }
    
    func getFormattedSymbol() -> String {
        var symbol = "N/A"
        if let position = self.position {
            symbol = position.symbol
        }
        else if let fxPosition = self.fxPosition {
            symbol = fxPosition.symbol
        }
        return symbol
    }
    
    func getFormattedQuantity() -> String {
        var quantity = "N/A"
        if let position = self.position {
            quantity = NumberFormatter.formatQuantity(position.quantity as Float)
        }
        else if let fxPosition = self.fxPosition {
            quantity = NumberFormatter.formatQuantity(fxPosition.quantity as Float)
        }
        return quantity
    }
    
    func getFormattedTotalReturn() -> String {
        var totalReturn = "N/A"
        if let position = self.position {
            totalReturn = formatTotalReturnPosition(position)
        }
        return totalReturn
    }
    
    private func formatTotalReturnPosition(position: TradeItPosition) -> String {
        let totalGainLossDollar = position.totalGainLossDollar
        let totalGainLossPercentage = position.totalGainLossPercentage
        var returnStr = ""
        if (totalGainLossDollar != nil) {
            var returnPrefix = ""
            if (totalGainLossDollar.floatValue > 0) {
                returnPrefix = "+";
            } else if (totalGainLossDollar.floatValue == 0) {
                returnStr = "N/A";
            }
            var returnPctStr = ""
            if (totalGainLossPercentage != nil) {
                returnPctStr = NumberFormatter.formatPercentage(totalGainLossPercentage.floatValue);
            } else {
                returnPctStr = "N/A";
            }
            
            if (returnStr == "") {
                returnStr = "\(returnPrefix)\(NumberFormatter.formatCurrency(totalGainLossDollar.floatValue))(\(returnPctStr))";
            }
        } else {
            returnStr = "N/A";
        }
        return returnStr
    }
}
