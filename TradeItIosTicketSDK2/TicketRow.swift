enum TicketRow {
    case account
    case orderAction
    case orderType
    case quantity
    case expiration
    case limitPrice
    case stopPrice
    case symbol
    case marketPrice
    case estimatedCost

    private enum CellReuseId: String {
        case readOnly = "TRADING_TICKET_READ_ONLY_CELL_ID"
        case numericInput = "TRADING_TICKET_NUMERIC_INPUT_CELL_ID"
        case selection = "TRADING_TICKET_SELECTION_CELL_ID"
        case selectionDetail = "TRADING_TICKET_SELECTION_DETAIL_CELL_ID"
        case marketData = "TRADING_TICKET_MARKET_DATA_CELL_ID"
    }

    var cellReuseId: String {
        var cellReuseId: CellReuseId

        switch self {
        case .symbol:
            cellReuseId = .selection
        case .orderAction:
            cellReuseId = .selection
        case .estimatedCost:
            cellReuseId = .readOnly
        case .quantity, .limitPrice, .stopPrice:
            cellReuseId = .numericInput
        case .orderType, .expiration:
            cellReuseId = .selection
        case .marketPrice:
            cellReuseId = .marketData
        case .account:
            cellReuseId = .selectionDetail
        }

        return cellReuseId.rawValue
    }

    func getTitle(forAction action: TradeItOrderAction) -> String {
        switch self {
        case .symbol:
            return "Symbol"
        case .orderAction:
            return "Action"
        case .estimatedCost:
            let sellActions: [TradeItOrderAction] = [.sell, .sellShort]
            let title = "Estimated \(sellActions.contains(action) ? "proceeds" : "cost")"
            return title
        case .quantity:
            return "Shares"
        case .limitPrice:
            return "Limit"
        case .stopPrice:
            return "Stop"
        case .orderType:
            return "Order type"
        case .expiration:
            return "Time in force"
        case .marketPrice:
            return "Market price"
        case .account:
            return "Account"
        }
    }
}
