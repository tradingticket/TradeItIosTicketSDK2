import TradeItIosEmsApi

class TradeItPortfolioPosition : NSObject {

    var position: TradeItPosition!
    var fxPosition: TradeItFxPosition!
    var quote: TradeItQuote!
    
    
    init(position: TradeItPosition) {
        self.position = position
    }
    
    init(fxPosition: TradeItFxPosition) {
        self.fxPosition = fxPosition
    }
}
