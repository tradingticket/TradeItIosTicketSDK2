internal enum TradeItInstrumentOrderCapabilityField {
    case priceTypes
    case expirationTypes
    case orderTypes
    case actions
}

public enum OrderQuantityType: String {
    case baseCurrency = "BASE_CURRENCY"
    case quoteCurrency = "QUOTE_CURRENCY"
    case shares = "SHARES"
    case totalValue = "TOTAL_VALUE"
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

    func supportedOrderQuantityTypesFor(action: TradeItOrderAction) -> [OrderQuantityType] {
        let capabilities = capabilitiesFor(field: .actions) as? [TradeItInstrumentActionCapability] ?? []
        let capability = capabilities.first { $0.value == action.rawValue } ?? capabilities.first
        return capability?.supportedOrderQuantityTypes.compactMap(OrderQuantityType.init) ?? []
    }

    func maxDecimalPlacesFor(orderQuantityType: OrderQuantityType?) -> Int {
        // TODO: API needs to provide this configuration. Setting to 8 for BTC case.
        switch orderQuantityType {
        case .some(.baseCurrency): return 8
        case .some(.shares): return 0
        default: return 2
        }
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
