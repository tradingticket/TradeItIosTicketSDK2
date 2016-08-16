import UIKit
import PromiseKit

class TradeItPortfolioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var cellPortfolioId = "CUSTOM_PORTFOLIO_CELL_ID"
    var tradeItConnector = TradeItLauncher.tradeItConnector
    var accounts: [TradeItAccount] = []
    var linkedLogin: TradeItLinkedLogin!
    var tradeItSession: TradeItSession!
    var _tradeItBalanceService : TradeItBalanceService!
    var ezLoadingActivityManager: EZLoadingActivityManager = EZLoadingActivityManager()
    var portfolios : [TradeItSDKPortfolio] = []
    var selectedPortfolioIndex = 0
    var tradeItBalanceService : TradeItBalanceService! {
        get {
            if self._tradeItBalanceService == nil {
                self._tradeItBalanceService = TradeItBalanceService(session: tradeItSession)
            }
            return self._tradeItBalanceService
        }
        set (tradeItBalanceService) {
            self._tradeItBalanceService = tradeItBalanceService
        }
    }
    
    
    @IBOutlet weak var accountsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authenticateAndFetchBalancesLinkedAccounts()
    }
        
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedPortfolioIndex = indexPath.row
        self.accountsTable.reloadData()
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.portfolios.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CUSTOM_PORTFOLIO_CELL_ID"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! CustomPortfolioCell
        let portfolio = self.portfolios[indexPath.row]
        if (indexPath.row == self.selectedPortfolioIndex ) {
            cell.selector.hidden = false
        }
        else {
            cell.selector.hidden = true
        }
        cell.rowCellValue1.text = portfolio.accountName
        
        if (!portfolio.isBalanceError && portfolio.balance != nil) {
            cell.rowCellValue2.text = "$\(portfolio.balance.totalValue)"
            cell.rowCellValue3.text = "$\(portfolio.balance.buyingPower)"
        }
        else {
            cell.rowCellValue2.text = "N/A"
            cell.rowCellValue3.text = "N/A"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCellIdentifier = "CUSTOM_PORTFOLIO_HEADER_ID"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(headerCellIdentifier) as! CustomPortfolioHeaderCell
        return cell
    }
    
    
    // MARK: private
    
    private func showTradeItErrorResultAlert(tradeItErrorResult: TradeItErrorResult, completion: () -> Void = {}) {
        let alertController = UIAlertController(title: tradeItErrorResult.shortMessage,
                                                message: (tradeItErrorResult.longMessages as! [String]).joinWithSeparator(" "),
                                                preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK",
                                     style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
                                        completion()
        }
        
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func getAccountName(account: TradeItAccount , broker: String) -> String {
        let accountNumber = account.accountNumber
        let startIndex = accountNumber.endIndex.advancedBy(-4)
        return "\(broker) *\(String(accountNumber.characters.suffixFrom(startIndex)))"
    }
    
    private func authenticateAndFetchBalancesLinkedAccounts() -> Void {
        let linkedLogins = self.tradeItConnector.getLinkedLogins() as! [TradeItLinkedLogin]
        print("linkedLogin: \(linkedLogins)")
        firstly {  _ -> Promise<[TradeItResult]> in
            self.ezLoadingActivityManager.show(text: "Authenticating", disableUI: true)
            var promises: [Promise<TradeItResult>] = []
            for linkedLogin in linkedLogins {
                if (self.linkedLogin == nil || self.linkedLogin.userId != linkedLogin.userId) {
                    promises.append(self.authenticateAccount(linkedLogin))
                }
                else {
                    for account in self.accounts {
                        let accountName = self.getAccountName(account, broker: self.linkedLogin.broker)
                        let tradeItSDKPortfolio =  TradeItSDKPortfolio(tradeItSession: self.tradeItSession, broker: self.linkedLogin.broker, accountName: accountName, accountNumber: account.accountNumber, balance: nil)
                        self.portfolios.append(tradeItSDKPortfolio)
                    }
                }
                
            }
            return when(promises)
        }
        .then { _ -> Promise<[TradeItResult]> in
            self.ezLoadingActivityManager.hide()
            self.ezLoadingActivityManager.show(text: "Retreiving Account Summary", disableUI: true)
            var promises: [Promise<TradeItResult>] = []
            for portfolio in self.portfolios {
                promises.append(self.getAccountOverView(portfolio))
            }
            return when(promises)
        }.always {
            self.accountsTable.reloadData()
            self.ezLoadingActivityManager.hide()
        }.error { (error:ErrorType) in
                // Display a message to the user, etc
            print("error type: \(error)")
        }
        

    }
    
    private func authenticateAccount(linkedLogin: TradeItLinkedLogin) -> Promise<TradeItResult> {
        return Promise { fulfill, reject in
                let tradeItSession = TradeItSession(connector: TradeItLauncher.tradeItConnector)
                tradeItSession.authenticateAsObject(linkedLogin, withCompletionBlock: { (tradeItResult: TradeItResult!) in
                    if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                        //TODO
                        print("Error \(tradeItErrorResult)")
                        //reject()
                    
                    } else if let tradeItSecurityQuestionResult = tradeItResult as? TradeItSecurityQuestionResult{
                        print("Security question result: \(tradeItSecurityQuestionResult)")
                        //TODO
                        //reject()
                    } else if let tradeItResult = tradeItResult as? TradeItAuthenticationResult {
                        for account in tradeItResult.accounts {
                            let accountName = self.getAccountName(account as! TradeItAccount, broker: linkedLogin.broker)
                            let tradeItSDKPortfolio = TradeItSDKPortfolio(tradeItSession: tradeItSession, broker: linkedLogin.broker, accountName: accountName, accountNumber: account.accountNumber,  balance: nil)
                            self.portfolios.append(tradeItSDKPortfolio)
                        }
                    }
                    fulfill(tradeItResult)
                })
        }
    }
    
    private func getAccountOverView(portfolio: TradeItSDKPortfolio) -> Promise<TradeItResult> {
        return Promise { fulfill, reject in
            let request = TradeItAccountOverviewRequest(accountNumber: portfolio.accountNumber)
            self.tradeItBalanceService.session = portfolio.tradeItSession
            self.tradeItBalanceService.getAccountOverview(request, withCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
                if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                    //TODO
                    print("Error \(tradeItErrorResult)")
                    portfolio.isBalanceError = true
                } else if let tradeItAccountOverviewResult = tradeItResult as? TradeItAccountOverviewResult {
                    portfolio.balance = tradeItAccountOverviewResult
                }
                fulfill(tradeItResult)
            })
        }
        
    }
    

    
    
}
