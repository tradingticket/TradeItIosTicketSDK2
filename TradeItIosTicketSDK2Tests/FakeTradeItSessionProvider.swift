class FakeTradeItSessionProvider: TradeItSessionProvider {
    var tradeItSessionToProvide: TradeItSession?

    override func provide(connector connector: TradeItConnector) -> TradeItSession! {
        guard let tradeItSession = tradeItSessionToProvide else {
            assertionFailure("FakeTradeItSessionProvider: No TradeItSession was set to be provided.")
            return nil
        }

        return tradeItSession
    }
}
