import TradeItIosEmsApi
import PromiseKit

class TradeItLinkedBrokerManager {
    var tradeItConnector: TradeItConnector
    var tradeItSessionProvider: TradeItSessionProvider
    var linkedBrokers: [TradeItLinkedBroker] = []
    //    var tradeItBalanceService: TradeItBalanceService = TradeItBalanceService()
    //    var tradeItPositionService : TradeItPositionService = TradeItPositionService()
    //    var selectedBrokerAccountIndex = -1
    //
    //    func getSelectedBrokerAccount() -> TradeItLinkedAccountPortfolio! {
    //        var selecteBrokerAccount: TradeItLinkedAccountPortfolio! = nil
    //        if selectedBrokerAccountIndex > -1 && linkedBrokerAccounts.count > 0 {
    //            selecteBrokerAccount = linkedBrokerAccounts[selectedBrokerAccountIndex]
    //        }
    //        return selecteBrokerAccount
    //    }

    init(connector: TradeItConnector) {
        tradeItConnector = connector
        tradeItSessionProvider = TradeItSessionProvider()

        self.loadLinkedBrokersFromKeychain()
    }
    
    func loadLinkedBrokersFromKeychain() {
        let linkedLoginsFromKeychain = self.tradeItConnector.getLinkedLogins() as! [TradeItLinkedLogin]
        for linkedLogin in linkedLoginsFromKeychain { loadLinkedBrokerFromLinkedLogin(linkedLogin) }
    }

    func loadLinkedBrokerFromLinkedLogin(linkedLogin: TradeItLinkedLogin) -> TradeItLinkedBroker {
        let tradeItSession = tradeItSessionProvider.provide(connector: self.tradeItConnector)
        let linkedBroker = TradeItLinkedBroker(session: tradeItSession, linkedLogin: linkedLogin)
        self.linkedBrokers.append(linkedBroker)
        return linkedBroker
    }

    func authenticateAll(onSecurityQuestion onSecurityQuestion: (TradeItSecurityQuestionResult) -> String,
                                            onFinished: () -> Void) {
        firstly { _ -> Promise<Void> in
            var promises: [Promise<Void>] = []

            for linkedBroker in self.linkedBrokers {
                let promise = Promise<Void> { fulfill, reject in
                    if !linkedBroker.isAuthenticated {
                        linkedBroker.authenticate(
                            onSuccess: { () -> Void in
                                fulfill()
                            },
                            onSecurityQuestion: { (tradeItSecurityQuestionResult: TradeItSecurityQuestionResult) -> String in
                                return onSecurityQuestion(tradeItSecurityQuestionResult)
                            },
                            onFailure: { (tradeItErrorResult: TradeItErrorResult) -> Void in
                                fulfill()
                            }
                        )
                    }
                    else {
                        fulfill()
                    }
                }

                promises.append(promise)
            }

            return when(promises)
        }
        .always() {
            onFinished()
        }
    }

    func refreshAccountBalances(onFinished onFinished: () -> Void) {
        firstly { _ -> Promise<Void> in
            var promises: [Promise<Void>] = []
            for linkedBroker in self.linkedBrokers {
                    let promise = Promise<Void> { fulfill, reject in
                        if linkedBroker.isAuthenticated {
                            linkedBroker.refreshAccountBalances(
                                onFinished: {
                                    fulfill()
                                }
                            )
                        }
                        else {
                            fulfill()
                        }
                    }
                    promises.append(promise)
            }
            return when(promises)
        }
        .always() {
            onFinished()
        }
    }

    func getAvailableBrokers(onSuccess onSuccess: (availableBrokers: [TradeItBroker]) -> Void,
                                       onFailure: () -> Void) {
        self.tradeItConnector.getAvailableBrokersWithCompletionBlock { (availableBrokers: [TradeItBroker]?) in
            if let availableBrokers = availableBrokers {
                onSuccess(availableBrokers: availableBrokers)
            } else {
                onFailure()
            }
        }
    }

    func linkBroker(authInfo authInfo: TradeItAuthenticationInfo,
                             onSuccess: (linkedBroker: TradeItLinkedBroker) -> Void,
                             onFailure: (TradeItErrorResult) -> Void) -> Void {

        self.tradeItConnector.linkBrokerWithAuthenticationInfo(authInfo) { (tradeItResult: TradeItResult?) in
            if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                onFailure(tradeItErrorResult)
            } else if let tradeItResult = tradeItResult as? TradeItAuthLinkResult {
                let broker = authInfo.broker
                let linkedLogin = self.tradeItConnector.saveLinkToKeychain(tradeItResult, withBroker: broker)
                if let linkedLogin = linkedLogin {
                    let linkedBroker = self.loadLinkedBrokerFromLinkedLogin(linkedLogin)
                    onSuccess(linkedBroker: linkedBroker)
                } else {
                    let errorResult = TradeItErrorResult()
                    errorResult.systemMessage = "Failed to save linked login to keychain"
                    onFailure(errorResult)
                }
            }
        }
    }

    func getAllAccounts() -> [TradeItLinkedBrokerAccount] {
        var accounts: [TradeItLinkedBrokerAccount] = []

        for linkedBroker in self.linkedBrokers {
            accounts.appendContentsOf(linkedBroker.accounts)
        }

        return accounts
    }
}

//    func getLinkedBrokerAccountsAndFetchBalances() -> Void {
//        let linkedLogins = self.tradeItConnector.getLinkedLogins() as! [TradeItLinkedLogin]
//        self.delegate?.showActivityManager(text: "Authenticating")
//        
//        firstly { _ -> Promise<[TradeItResult]> in
//            var promises: [Promise<TradeItResult>] = []
            //TODO authenticate only linkedLogin which are not authenticated in linkedBrokerAccounts
//            for linkedLogin in linkedLogins {
//                if (self.linkedLogin == nil || self.linkedLogin.userId != linkedLogin.userId) {
//                    promises.append(self.authenticateLinkedLogin(linkedLogin))
//                } else {
//                    for account in self.accounts {
//                        let accountName = self.getAccountName(account, broker: self.linkedLogin.broker)
//                        let tradeItLinkedAccountPortfolio =  TradeItLinkedAccountPortfolio(
//                            tradeItSession: self.tradeItSession,
//                            broker: self.linkedLogin.broker,
//                            accountName: accountName,
//                            accountNumber: account.accountNumber,
//                            balance: nil,
//                            fxBalance: nil,
//                            positions: [])
//                        self.portfolios.append(tradeItLinkedAccountPortfolio)
//                    }
//                }
//            }
            
//            return when(promises)
//            }.then { _ -> Promise<[TradeItResult]> in
//                self.delegate?.updateActivityManager(text: "Retreiving Account Summary")
//                var promises: [Promise<TradeItResult>] = []
//                
//                for linkedBrokerAccount in self.linkedBrokerAccounts {
//                    promises.append(self.getAccountOverView(linkedBrokerAccount))
//                }
//                
//                return when(promises)
//            }.then { _ -> Promise<[TradeItResult]> in
//                var promises: [Promise<TradeItResult>] = []
//                
//                if self.linkedBrokerAccounts.count > 0 {
//                    promises.append(self.getPositions(self.currentLinkedBrokerAccount!))
//                }
//                
//                return when(promises)
//            }.always {
//                self.delegate?.didGetLinkedBrokerAccountsAndFetchBalancesFinished()
//                self.delegate?.hideActivityManager()
//            }.error { (error: ErrorType) in
//                // Display a message to the user, etc in case of reject
//                print("error type: \(error)")
//        }
//    }
//    
//    func getPositions(linkedBrokerAccount: TradeItLinkedAccountPortfolio) -> Promise<TradeItResult> {
//        return Promise { fulfill, reject in
//            self.delegate?.showPositionSpinner()
//            
//            let request = TradeItGetPositionsRequest(accountNumber: linkedBrokerAccount.accountNumber)
//            self.tradeItPositionService.session = linkedBrokerAccount.tradeItSession
//            
//            self.tradeItPositionService.getAccountPositions(request, withCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
//                self.delegate?.hidePositionSpinner()
//                
//                if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
//                    //TODO
//                    print("Error \(tradeItErrorResult)")
//                    linkedBrokerAccount.isPositionsError = true
//                } else if let tradeItGetPositionsResult = tradeItResult as? TradeItGetPositionsResult {
//                    var positionsBrokerAccount:[TradeItPortfolioPosition] = []
//                    
//                    let positions = tradeItGetPositionsResult.positions as! [TradeItPosition]
//                    for position in positions {
//                        let positionBrokerAccount = TradeItPortfolioPosition(position: position)
//                        positionsBrokerAccount.append(positionBrokerAccount)
//                    }
//                    
//                    let fxPositions = tradeItGetPositionsResult.fxPositions as! [TradeItFxPosition]
//                    for fxPosition in fxPositions {
//                        let positionPortfolio = TradeItPortfolioPosition(fxPosition: fxPosition)
//                        positionsBrokerAccount.append(positionPortfolio)
//                    }
//                    
//                    linkedBrokerAccount.positions = positionsBrokerAccount
//                }
//                
//                fulfill(tradeItResult)
//            })
//        }
//    }
//
//    
//    func getAccountOverView(linkedBrokerAccount: TradeItLinkedAccountPortfolio) -> Promise<TradeItResult> {
//        return Promise { fulfill, reject in
//            let request = TradeItAccountOverviewRequest(accountNumber: linkedBrokerAccount.accountNumber)
//            self.tradeItBalanceService.session = linkedBrokerAccount.tradeItSession
//            self.tradeItBalanceService.getAccountOverview(request, withCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
//                if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
//                    // TODO: reject
//                    print("Error \(tradeItErrorResult)")
//                    linkedBrokerAccount.isBalanceError = true
//                } else if let tradeItAccountOverviewResult = tradeItResult as? TradeItAccountOverviewResult {
//                    linkedBrokerAccount.balance = tradeItAccountOverviewResult.accountOverview
//                    linkedBrokerAccount.fxBalance = tradeItAccountOverviewResult.fxAccountOverview
//                }
//                
//                fulfill(tradeItResult)
//            })
//        }
//    }
//    
//    func selectLinkedBrokerAccountByIndex(index index: Int) -> TradeItLinkedAccountPortfolio! {
//        var selecteBrokerAccount: TradeItLinkedAccountPortfolio! = nil
//        if index > -1 && linkedBrokerAccounts.count > 0 {
//            self.currentLinkedBrokerAccount = linkedBrokerAccounts[index]
//            selecteBrokerAccount = self.currentLinkedBrokerAccount
//        }
//        return selecteBrokerAccount
//    }
//
//}
//
//protocol TradeItLinkedLoginManagerDelegate: class {
//    func showActivityManager(text text: String)
//    func updateActivityManager(text text: String)
//    func hideActivityManager()
//    func showPositionSpinner()
//    func hidePositionSpinner()
//    func didGetLinkedBrokerAccountsAndFetchBalancesFinished()
//    
//}