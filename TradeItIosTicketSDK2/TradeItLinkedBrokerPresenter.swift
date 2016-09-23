class TradeItLinkedBrokerPresenter: NSObject {
    let linkedBroker: TradeItLinkedBroker
    
    init(linkedBroker: TradeItLinkedBroker) {
        self.linkedBroker = linkedBroker
    }
    
    func getFormattedBrokerLibelle() -> String {
        var brokerLibelle = self.linkedBroker.linkedLogin.broker
        let nbAccounts = self.linkedBroker.accounts.count
        if nbAccounts > 1 {
            brokerLibelle = brokerLibelle + (" (\(nbAccounts) accounts)")
        }
        return brokerLibelle
    }
    
    func getFormattedBrokerAccountsLabel() -> String {
        let accounts = self.linkedBroker.accounts
        var accountsLabel = ""
        let maxNbAccountToShow = 2
        var countAccounts = 0
        let nbAccounts = accounts.count
        if (nbAccounts > 0) {
            for account in accounts {
                let accountName = account.getFormattedAccountName()
                accountsLabel += accountName
                countAccounts += 1
                if countAccounts >= maxNbAccountToShow || countAccounts == nbAccounts {
                    break
                }
                accountsLabel += ", "
            }
        }
        if nbAccounts >= 3 {
            accountsLabel += " and \(nbAccounts - 2) more"
        }
        return accountsLabel
    }
}
