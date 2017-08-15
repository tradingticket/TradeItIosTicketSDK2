class TradeItSessionProvider {
    func provide(connector: TradeItConnector) -> TradeItSession {
        return TradeItSession(connector: connector)
    }
}
