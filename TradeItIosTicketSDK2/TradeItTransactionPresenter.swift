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
        guard let amount = transaction.amount, amount != 0 else {
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
    
    func getTransactionTypeLabel() -> String {
        return formatLabel(self.transaction.type ?? "")
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
