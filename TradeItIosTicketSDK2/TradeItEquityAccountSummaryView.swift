import UIKit

class TradeItEquityAccountSummaryView: UIView {
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var dayReturnValueLabel: UILabel!
    @IBOutlet weak var availableCashValueLabel: UILabel!
    @IBOutlet weak var totalReturnValueLabel: UILabel!

    func populate(withAccount account: TradeItLinkedBrokerAccount) {
        let presenter = TradeItPortfolioBalanceEquityPresenter(account)
        self.totalValueLabel.text = presenter.getFormattedTotalValue()
        self.dayReturnValueLabel.text = presenter.getFormattedDayReturnWithPercentage()
        self.availableCashValueLabel.text = presenter.getFormattedAvailableCash()
        self.totalReturnValueLabel.text = presenter.getFormattedTotalReturnValueWithPercentage()
    }
}
