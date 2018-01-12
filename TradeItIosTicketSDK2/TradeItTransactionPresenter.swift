import UIKit

class TradeItTransactionPresenter: NSObject {

    private var transaction: TradeItTransaction
    private var currencyCode: String
    
    private let DEBIT_CATEGORY: [TradeItTransaction.Action] = [.buy, .buyOpen, .buyClose, .debit, .cover]
    private let CREDIT_CATEGORY: [TradeItTransaction.Action] = [.sell, .credit, .sellOpen, .sellClose, .short, .rebate, .restructure]

    init(_ transaction: TradeItTransaction, currencyCode: String) {
        self.transaction = transaction
        self.currencyCode = currencyCode
    }
    
    func getAmountLabel() -> String {
        guard let amount = transaction.amount, amount != 0 as NSNumber else {
            return ""
        }
        return NumberFormatter.formatCurrency(amount, currencyCode: self.currencyCode)
    }
    
    func getAmountLabelColor() -> UIColor {
        if isDebit() {
            return UIColor.tradeItDeepRoseColor
        } else if isCredit() {
            return UIColor.tradeItMoneyGreenColor
        } else {
            return TradeItSDK.theme.textColor
        }
    }
    
    func getDescriptionLabel() -> String {
        guard self.transaction.typeEnum == .trade else {
            return ""
        }
        let action = self.transaction.action ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
        let quantity = (self.transaction.quantity != nil) ? NumberFormatter.formatQuantity(self.transaction.quantity!) : TradeItPresenter.MISSING_DATA_PLACEHOLDER
        let symbol = self.transaction.symbol ?? TradeItPresenter.MISSING_DATA_PLACEHOLDER
        let price = self.transaction.price != nil ? NumberFormatter.formatCurrency(self.transaction.price!, currencyCode: self.currencyCode) : TradeItPresenter.MISSING_DATA_PLACEHOLDER
        
        return "\(formatLabel(action)) \(quantity) \(symbol) @ \(price)"
    }

    func getTransactionDescriptionLabel() -> String {
        guard self.transaction.typeEnum != .trade else {
            return getDescriptionLabel()
        }
        return self.transaction.transactionDescription ?? ""
    }

    func getTransactionTypeLabel() -> String {
        var label = formatLabel(self.transaction.type ?? "")
        if self.transaction.typeEnum == .corp_action {
            label = "Corporate Action"
        }
        guard [.trade, .reinvestment, .dividend].contains(self.transaction.typeEnum) else {
            return label
        }
        return "\(label) \(self.transaction.symbol ?? "")"
    }

    func getTransactionActionLabel() -> String {
        return formatLabel(self.transaction.action ?? "")
    }

    func getTransactionQuantityLabel() -> String {
        guard let quantity = self.transaction.quantity, quantity != 0 as NSNumber else {
            return ""
        }
        return  NumberFormatter.formatQuantity(quantity)
    }

    func getTransactionSymbolLabel() -> String {
        return self.transaction.symbol ?? ""
    }

    func getTransactionPriceLabel() -> String {
        guard let price = transaction.price, price != 0 as NSNumber else {
            return ""
        }
        return NumberFormatter.formatCurrency(price, currencyCode: self.currencyCode)
    }

    func getTransactionIdLabel() -> String {
        return self.transaction.id ?? ""
    }

    func getTransactionDateLabel() -> String {
        return self.transaction.date ?? ""
    }

    func getTransactionCommissionLabel() -> String {
        guard let commission = transaction.commission, commission != 0 as NSNumber else {
            return ""
        }
        return NumberFormatter.formatCurrency(commission, currencyCode: self.currencyCode)
    }

    func belongsToFilter(filter: TransactionFilterType) -> Bool {
        switch filter {
        case .ALL_TRANSACTIONS: return true
        case .TRADES: return self.transaction.typeEnum == .trade
        case .DIVIDENDS_AND_INTEREST: return [.dividend, .interest].contains(self.transaction.typeEnum)
        case .TRANSFERS: return self.transaction.typeEnum == .transfer
        case .FEES: return self.transaction.typeEnum == .fee
        case .OTHER: return [.conversion, .corp_action, .journaled, .reinvestment, .unknown].contains(self.transaction.typeEnum)
        }
    }
    
    // MARK: private
    
    private func isDebit() -> Bool {
        return DEBIT_CATEGORY.contains(self.transaction.actionEnum)
    }
    
    private func isCredit() -> Bool {
        return CREDIT_CATEGORY.contains(self.transaction.actionEnum)
    }
    
    private func formatLabel(_ string: String) -> String {
        return string.replacingOccurrences(of: "_", with: " ").lowercased().capitalizingFirstLetter()
    }
}
