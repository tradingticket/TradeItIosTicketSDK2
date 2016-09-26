import UIKit

class TradeItFxAccountSummaryView: UIView {

    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var realizedPlValueLabel: UILabel!
    @IBOutlet weak var unrealizedPlValue: UILabel!
    @IBOutlet weak var marginBalanceValueLabel: UILabel!
    
    func populate(withAccount selectedAccount: TradeItLinkedBrokerAccount) {
        let presenter = TradeItPortfolioBalanceFXPresenter(selectedAccount)
        self.totalValueLabel.text = presenter.getFormattedTotalValue()
        self.unrealizedPlValue.text = presenter.getUnrealizedProfitAndLoss()
        self.realizedPlValueLabel.text = presenter.getRealizedProfitAndLoss()
        self.marginBalanceValueLabel.text = presenter.getMarginBalance()
        
    }
}
