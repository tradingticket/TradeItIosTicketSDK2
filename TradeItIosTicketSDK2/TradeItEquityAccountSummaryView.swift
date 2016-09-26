import UIKit

class TradeItEquityAccountSummaryView: UIView {

    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var dayReturnValueLabel: UILabel!
    @IBOutlet weak var availableCashValueLabel: UILabel!
    @IBOutlet weak var totalReturnValueLabel: UILabel!

    func populate(withAccount selectedAccount: TradeItLinkedBrokerAccount) {
        let presenter = TradeItPortfolioBalanceEquityPresenter(selectedAccount)
        self.totalValueLabel.text = presenter.getFormattedTotalValue()
        self.dayReturnValueLabel.text = presenter.getFormattedDayReturn()
        self.availableCashValueLabel.text = presenter.getFormattedAvailableCash()
        self.totalReturnValueLabel.text = presenter.getFormattedTotalReturnValue()
    }
    
}
