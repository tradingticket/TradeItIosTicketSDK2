internal enum TradeItInstrumentOrderCapabilityField {
    case priceTypes
    case expirationTypes
    case orderTypes
    case actions
}

extension TradeItInstrumentOrderCapabilities {
    func labelFor(field: TradeItInstrumentOrderCapabilityField, value: String?) -> String? {
        return capabilitiesFor(field: field).first { $0.value == value }?.displayLabel
    }

    func labelsFor(field: TradeItInstrumentOrderCapabilityField) -> [String] {
        return capabilitiesFor(field: field).map { $0.displayLabel }
    }

    func valueFor(field: TradeItInstrumentOrderCapabilityField, label: String) -> String? {
        return capabilitiesFor(field: field).first { $0.displayLabel == label }?.value
    }

    func defaultValueFor(field: TradeItInstrumentOrderCapabilityField, value: String?) -> String? {
        let value = value ?? ""
        let capabilities = capabilitiesFor(field: field)
        return capabilities.first { $0.value == value }?.value ?? capabilities.first?.value
    }

    private func capabilitiesFor(field: TradeItInstrumentOrderCapabilityField) -> [TradeItInstrumentCapability] {
        switch field {
        case .priceTypes: return self.priceTypes as? [TradeItInstrumentCapability] ?? []
        case .actions: return self.actions as? [TradeItInstrumentCapability] ?? []
        case .expirationTypes: return self.expirationTypes as? [TradeItInstrumentCapability] ?? []
        case .orderTypes: return self.orderTypes as? [TradeItInstrumentCapability] ?? []
        }
    }
}
