import TradeItIosEmsApi

class TradeItPortfolioPosition : NSObject {

    var position: TradeItPosition
    var quote: TradeItQuote!
    
    init(position: TradeItPosition, quote: TradeItQuote!) {
        self.position = position
        self.quote = quote
    }
}
