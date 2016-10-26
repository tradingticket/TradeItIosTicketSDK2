protocol TradeItPortfolioBalancePresenter {
    func getFormattedBuyingPower() -> String
    func getFormattedTotalValueWithPercentage() -> String
}

class TradeItPortfolioBalancePresenterFactory  {

    static func forTradeItLinkedBrokerAccount(_ tradeItLinkedBrokerAccount: TradeItLinkedBrokerAccount) -> TradeItPortfolioBalancePresenter {
        if tradeItLinkedBrokerAccount.balance != nil {
            return TradeItPortfolioBalanceEquityPresenter(tradeItLinkedBrokerAccount)
        } else if tradeItLinkedBrokerAccount.fxBalance != nil {
            return TradeItPortfolioBalanceFXPresenter(tradeItLinkedBrokerAccount)
        } else {
            return TradeItPortfolioBalanceDefaultPresenter(tradeItLinkedBrokerAccount)
        }
    }
}

class TradeItPortfolioBalanceDefaultPresenter: TradeItPortfolioBalanceEquityPresenter{
}
