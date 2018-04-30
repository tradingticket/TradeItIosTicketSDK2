import Foundation

enum TradeItTradeInstrumentType: String {
    case equities
    case options
    case fx
    case crypto
}

extension TradeItBroker {
    private var brokerInstrumentsSwiftArray: [TradeItBrokerInstrument]? { // Sigh...
        get {
            return self.brokerInstruments as? [TradeItBrokerInstrument]
        }
    }

    func equityServices() -> TradeItBrokerInstrument? {
        return instrumentFor(targetInstrument: .equities)
    }

    func fxServices() -> TradeItBrokerInstrument? {
        return instrumentFor(targetInstrument: .fx)
    }

    func optionsServices() -> TradeItBrokerInstrument? {
        return instrumentFor(targetInstrument: .options)
    }

    func cryptoServices() -> TradeItBrokerInstrument? {
        return instrumentFor(targetInstrument: .crypto)
    }

    func isFeaturedForAnyInstrument() -> Bool {
        return brokerInstrumentsSwiftArray?.first {
            instrument in instrument.isFeatured
        } != nil
    }

    func supportsTransactionsHistory() -> Bool {
        return brokerInstrumentsSwiftArray?.contains { instrument in
            return instrument.supportsTransactionHistory == true
        } ?? false
    }

    func supportsOrderStatus() -> Bool {
        return brokerInstrumentsSwiftArray?.contains { instrument in
            return instrument.supportsOrderStatus == true
        } ?? false
    }

    func supportsTrading() -> Bool {
        return brokerInstrumentsSwiftArray?.contains { instrument in
            return instrument.supportsTrading == true
        } ?? false
    }

    private func instrumentFor(targetInstrument: TradeItTradeInstrumentType) -> TradeItBrokerInstrument? {
        return brokerInstrumentsSwiftArray?.filter { instrument in
            return instrument.instrument == targetInstrument.rawValue
        }.first
    }
}
