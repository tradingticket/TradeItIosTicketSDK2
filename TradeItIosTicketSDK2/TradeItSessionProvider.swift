class TradeItSessionProvider {
    func provide(connector connector: TradeItConnector) -> TradeItSession! {
        return TradeItSession(connector: connector)
    }
}
