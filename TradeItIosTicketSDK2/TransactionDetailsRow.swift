enum TransactionDetailsRow {
    case description
    case action
    case quantity
    case symbol
    case price
    case commission
    case amount
    case date
    case id

    func getTitle() -> String {
        switch self {
        case .description: return "Description"
        case .action: return "Action"
        case .quantity: return "Quantity"
        case .symbol: return "Symbol"
        case .price: return "Price"
        case .commission: return "Commission"
        case .amount: return "Amount"
        case .date: return "Transaction Completed"
        case .id: return "Transaction ID"
        }
    }

    func getValue(presenter: TradeItTransactionPresenter) -> String {
        switch self {
        case .description: return presenter.getTransactionDescriptionLabel()
        case .action: return presenter.getTransactionActionLabel()
        case .quantity: return presenter.getTransactionQuantityLabel()
        case .symbol: return presenter.getTransactionSymbolLabel()
        case .price: return presenter.getTransactionPriceLabel()
        case .commission: return presenter.getTransactionCommissionLabel()
        case .amount: return presenter.getAmountLabel()
        case .date: return presenter.getTransactionDateLabel()
        case .id: return presenter.getTransactionIdLabel()
        }
    }

}
