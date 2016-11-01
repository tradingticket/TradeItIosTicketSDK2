@testable import TradeItIosTicketSDK2

class FakeTradeItSessionProvider: TradeItSessionProvider {
    var tradeItSessionToProvide: TradeItSession?

    override func provide(connector: TradeItConnector) -> TradeItSession! {
        guard let tradeItSession = tradeItSessionToProvide else {
            assertionFailure("FakeTradeItSessionProvider: No TradeItSession was set to be provided.")
            return nil
        }

        return tradeItSession
    }
}
