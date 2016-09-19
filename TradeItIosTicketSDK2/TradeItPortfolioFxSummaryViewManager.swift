class TradeItPortfolioFxSummaryViewManager {

    var fxSummaryView: TradeItFxSummaryView!
    
    func showOrHideFxSummarySection(selectedAccount: TradeItLinkedBrokerAccount) {
        if selectedAccount.fxBalance == nil {
            self.fxSummaryView.summaryFxLabel.hidden = true
            self.fxSummaryView.hidden = true
            self.fxSummaryView.fxSummaryHeightConstraint.constant = 0
        }
        else {
            self.fxSummaryView.summaryFxLabel.hidden = false
            self.fxSummaryView.hidden = false
            self.fxSummaryView.fxSummaryHeightConstraint.constant = 110
            self.fxSummaryView.summaryFxLabel.text = selectedAccount.getFormattedAccountName() + " Summary"
            let fxBalance = selectedAccount.fxBalance
            self.fxSummaryView.fxTotalValueLabel.text = selectedAccount.getFormattedTotalValue()
            self.fxSummaryView.fxUnrealizedPlLabel.text = NumberFormatter.formatPercentage(fxBalance.unrealizedProfitAndLossBaseCurrency)
            self.fxSummaryView.fxRealizedPlLabel.text = NumberFormatter.formatPercentage(fxBalance.realizedProfitAndLossBaseCurrency)
            self.fxSummaryView.fxMarginBalanceLabel.text = NumberFormatter.formatPercentage(fxBalance.marginBalanceBaseCurrency)
        }
    }
    
}
