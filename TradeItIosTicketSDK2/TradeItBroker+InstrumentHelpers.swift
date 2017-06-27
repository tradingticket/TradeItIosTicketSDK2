import Foundation

enum TradeItTradeInstrumentType: String {
    case equities
    case options
    case fx
}


extension TradeItBroker {
    private var brokerInstrumentsSwiftArray: [TradeItBrokerInstrument]? { // Sigh...
        get {
            return self.brokerInstruments as? [TradeItBrokerInstrument]
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
}
