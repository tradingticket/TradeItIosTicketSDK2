class TradeItLinkedBrokerPresenter: NSObject {
    let linkedBroker: TradeItLinkedBroker
    
    init(linkedBroker: TradeItLinkedBroker) {
        self.linkedBroker = linkedBroker
    }
    
    func getFormattedBrokerLabel() -> String {
        var brokerLabel = self.linkedBroker.linkedLogin.broker
        let numberOfAccounts = self.linkedBroker.accounts.count
        if numberOfAccounts > 1 {
            brokerLabel = brokerLabel! + (" (\(numberOfAccounts) accounts)")
        }
        return brokerLabel!
    }
    
    func getFormattedBrokerAccountsLabel() -> String {
        let accounts = self.linkedBroker.accounts
        var accountsLabel = ""
        let maxNumberOfAccountsToShow = 2
        var accountsAddedToLabel = 0
        let numberOfAccounts = accounts.count

        for account in accounts {
            let accountName = account.getFormattedAccountName()
            accountsLabel += accountName
            accountsAddedToLabel += 1
            if accountsAddedToLabel >= maxNumberOfAccountsToShow || accountsAddedToLabel == numberOfAccounts {
                break
            }
            accountsLabel += ", "
        }

        if numberOfAccounts >= 3 {
            accountsLabel += " and \(numberOfAccounts - 2) more"
        }

        return accountsLabel
    }
}
