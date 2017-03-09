class TradeItPortfolioAccountTableViewCell: UITableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var returnLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!

    override func awakeFromNib() {
        // TODO: Test themes
        //TradeItThemeConfigurator.configure(view: self)
    }

    func populate(withAccount account: TradeItLinkedBrokerAccount) {
        let presenter = TradeItPortfolioBalanceEquityPresenter(account)
        self.accountNameLabel.text = account.getFormattedAccountName()
        self.totalValueLabel.text = presenter.getFormattedTotalValue()
        self.returnLabel.text = presenter.getFormattedDayReturnWithPercentage()
        self.returnLabel.textColor = TradeItPresenter.stockChangeColor(account.balance?.dayAbsoluteReturn?.doubleValue)

    }

    private func setFailedState(account: TradeItLinkedBrokerAccount) {
        if account.linkedBroker?.error == nil {
            self.alpha = 1.0
        } else {
            self.alpha = 0.5
        }
    }
}
