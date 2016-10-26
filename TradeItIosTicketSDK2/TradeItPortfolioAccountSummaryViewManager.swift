class TradeItPortfolioAccountSummaryViewManager {

    var accountSummaryView: TradeItAccountSummaryView!
    
    func populateSummarySection(_ selectedAccount: TradeItLinkedBrokerAccount) {
        self.accountSummaryView.summaryLabel.text = selectedAccount.getFormattedAccountName() + " Summary"
        self.accountSummaryView.populate(withAccount: selectedAccount)
    }

}
