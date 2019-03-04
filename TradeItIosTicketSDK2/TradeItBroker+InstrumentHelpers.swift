import Foundation

enum TradeItTradeInstrumentType: String {
    case equities
    case options
    case fx
}


extension TradeItBroker {
    private var brokerInstrumentsSwiftArray: [TradeItBrokerInstrument]? { // Sigh...
        get {
            return self.brokerInstruments
        }
    }

    func equityServices() -> TradeItBrokerInstrument? {
        return brokerInstrumentsSwiftArray?.filter { instrument in
            return instrument.instrument == TradeItTradeInstrumentType.equities.rawValue
        }.first
    }

    func fxServices() -> TradeItBrokerInstrument? {
        return brokerInstrumentsSwiftArray?.filter { instrument in
            return instrument.instrument == TradeItTradeInstrumentType.fx.rawValue
        }.first
    }

    func optionsServices() -> TradeItBrokerInstrument? {
        return brokerInstrumentsSwiftArray?.filter { instrument in
            return instrument.instrument == TradeItTradeInstrumentType.options.rawValue
        }.first
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
}
