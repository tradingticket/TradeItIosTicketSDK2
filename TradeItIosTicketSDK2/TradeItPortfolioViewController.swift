import UIKit
import PromiseKit

class TradeItPortfolioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tradeItConnector = TradeItLauncher.tradeItConnector
    var accounts: [TradeItAccount] = []
    var linkedLogin: TradeItLinkedLogin!
    var tradeItSession: TradeItSession!
    var ezLoadingActivityManager: EZLoadingActivityManager = EZLoadingActivityManager()
    var portfolios: [TradeItLinkedAccountPortfolio] = []
    var selectedPortfolioIndex = 0
    var selectedPositionIndex = -1
    var _tradeItBalanceService: TradeItBalanceService!
    var tradeItBalanceService: TradeItBalanceService! {
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
    var _tradeItPositionService : TradeItPositionService!
    var tradeItPositionService: TradeItPositionService! {
        get {
            if self._tradeItPositionService == nil {
                self._tradeItPositionService = TradeItPositionService(session: tradeItSession)
            }
            return self._tradeItPositionService
        }
        set (tradeItPositionService) {
            self._tradeItPositionService = tradeItPositionService
        }
    }
    
    
    @IBOutlet weak var accountsTable: UITableView!
    @IBOutlet weak var holdingsTable: UITableView!
    @IBOutlet weak var totalAccountsValueLabel: UILabel!
    @IBOutlet weak var holdingsLabel: UILabel!
    @IBOutlet weak var positionsSpinner: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.authenticateAndFetchBalancesLinkedAccounts()
    }
        
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.accountsTable {
            self.selectedPositionIndex = -1
            self.selectedPortfolioIndex = indexPath.row
            self.holdingsLabel.text = self.getHoldingLabel()
            self.accountsTable.reloadData()

            firstly {
                return when(self.getPositions(self.portfolios[self.selectedPortfolioIndex]))
            }
            .always {
                self.holdingsTable.reloadData()
            }
        }
        else if tableView == self.holdingsTable {
            self.selectedPositionIndex = indexPath.row
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int = 0
        if tableView == self.accountsTable {
            count = self.portfolios.count
        }
        else if tableView == self.holdingsTable {
            if self.portfolios.count > 0 {
                count = self.portfolios[self.selectedPortfolioIndex].positions.count
            }
        }
        
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CUSTOM_PORTFOLIO_CELL_ID") as! CustomPortfolioCell
        if tableView == self.accountsTable {
            let portfolio = self.portfolios[indexPath.row]
            if (indexPath.row == self.selectedPortfolioIndex ) {
                cell.selector.hidden = false
            }
            else {
                cell.selector.hidden = true
            }
            cell.rowCellValue1.text = portfolio.accountName
            
            if (!portfolio.isBalanceError && portfolio.balance != nil) {
                if let totalPercentReturn = portfolio.balance.totalPercentReturn {
                        cell.rowCellValue2.text = UtilsService.formatCurrency(portfolio.balance.totalValue as Float) + " (" + UtilsService.formatPercentage(totalPercentReturn as Float) + ")"
                }
                else {
                    cell.rowCellValue2.text = UtilsService.formatCurrency(portfolio.balance.totalValue as Float)
                }
                
                cell.rowCellValue3.text = UtilsService.formatCurrency(portfolio.balance.buyingPower as Float)
            }
            else {
                cell.rowCellValue2.text = "N/A"
                cell.rowCellValue3.text = "N/A"
            }
        }
        else if tableView == self.holdingsTable {
            let portfolio = self.portfolios[self.selectedPortfolioIndex]
            if (!portfolio.isPositionsError && portfolio.positions.count > 0) {
                let position = portfolio.positions[indexPath.row]
                cell.rowCellValue1.text = position.symbol + " (\(UtilsService.formatQuantity(position.quantity as Float)))"
                cell.rowCellValue2.text = UtilsService.formatCurrency(position.costbasis as Float)
                cell.rowCellValue3.text = UtilsService.formatCurrency(position.lastPrice as Float)
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("CUSTOM_PORTFOLIO_HEADER_ID") as! CustomPortfolioHeaderCell
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.holdingsTable {
            if indexPath.row == self.selectedPositionIndex {
                return 140
            }
            return 44
        }
        return 44
    }
    
    // MARK: IBAction
    
    @IBAction func closeButtonTapped(sender: UIBarButtonItem) {
        self.parentViewController?.dismissViewControllerAnimated(false, completion: nil)
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
    
    private func getHoldingLabel() -> String {
        if self.portfolios.count > 0 {
            return self.portfolios[self.selectedPortfolioIndex].accountName + " Holdings"
        }
        else {
            return "Holdings"
        }
    }
    
    private func authenticateAndFetchBalancesLinkedAccounts() -> Void {
        let linkedLogins = self.tradeItConnector.getLinkedLogins() as! [TradeItLinkedLogin]
        self.ezLoadingActivityManager.show(text: "Authenticating", disableUI: true)

        firstly { _ -> Promise<[TradeItResult]> in
            var promises: [Promise<TradeItResult>] = []

            for linkedLogin in linkedLogins {
                if (self.linkedLogin == nil || self.linkedLogin.userId != linkedLogin.userId) {
                    promises.append(self.authenticateAccount(linkedLogin))
                } else {
                    for account in self.accounts {
                        let accountName = self.getAccountName(account, broker: self.linkedLogin.broker)
                        let tradeItLinkedAccountPortfolio =  TradeItLinkedAccountPortfolio(
                            tradeItSession: self.tradeItSession,
                            broker: self.linkedLogin.broker,
                            accountName: accountName,
                            accountNumber: account.accountNumber,
                            balance: nil,
                            positions: [])
                        self.portfolios.append(tradeItLinkedAccountPortfolio)
                    }
                }
            }

            return when(promises)
        }.then { _ -> Promise<[TradeItResult]> in
            self.ezLoadingActivityManager.hide()
            self.ezLoadingActivityManager.show(text: "Retreiving Account Summary", disableUI: true)
            var promises: [Promise<TradeItResult>] = []
            for portfolio in self.portfolios {
                promises.append(self.getAccountOverView(portfolio))
            }

            return when(promises)
        }.then { _ -> Promise<[TradeItResult]> in
            var promises: [Promise<TradeItResult>] = []
            if self.portfolios.count > 0 {
                promises.append(self.getPositions(self.portfolios[self.selectedPortfolioIndex]))
            }

            return when(promises)
        }.always {
            self.accountsTable.reloadData()
            self.holdingsTable.reloadData()
            self.totalAccountsValueLabel.text = self.getTotalAccountsValue()
            self.holdingsLabel.text = self.getHoldingLabel()
            self.ezLoadingActivityManager.hide()
        }.error { (error: ErrorType) in
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
                        let tradeItLinkedAccountPortfolio = TradeItLinkedAccountPortfolio(
                            tradeItSession: tradeItSession,
                            broker: linkedLogin.broker,
                            accountName: accountName,
                            accountNumber: account.accountNumber,
                            balance: nil,
                            positions: [])
                        self.portfolios.append(tradeItLinkedAccountPortfolio)
                    }
                }

                fulfill(tradeItResult)
            })
        }
    }

    private func getAccountOverView(portfolio: TradeItLinkedAccountPortfolio) -> Promise<TradeItResult> {
        return Promise { fulfill, reject in
            let request = TradeItAccountOverviewRequest(accountNumber: portfolio.accountNumber)
            self.tradeItBalanceService.session = portfolio.tradeItSession
            self.tradeItBalanceService.getAccountOverview(request, withCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
                if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                    // TODO: reject
                    print("Error \(tradeItErrorResult)")
                    portfolio.isBalanceError = true
                } else if let tradeItAccountOverviewResult = tradeItResult as? TradeItAccountOverviewResult {
                    portfolio.balance = tradeItAccountOverviewResult
                }

                fulfill(tradeItResult)
            })
        }
    }
    
    private func getPositions(portfolio: TradeItLinkedAccountPortfolio) -> Promise<TradeItResult> {
        return Promise { fulfill, reject in
            let request = TradeItGetPositionsRequest(accountNumber: portfolio.accountNumber)
            self.tradeItPositionService.session = portfolio.tradeItSession
            self.positionsSpinner.startAnimating()
            self.tradeItPositionService.getAccountPositions(request, withCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
                self.positionsSpinner.stopAnimating()
                if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                    //TODO
                    print("Error \(tradeItErrorResult)")
                    portfolio.isPositionsError = true
                } else if let tradeItGetPositionsResult = tradeItResult as? TradeItGetPositionsResult {
                    portfolio.positions = tradeItGetPositionsResult.positions as! [TradeItPosition]
                }

                fulfill(tradeItResult)
            })
        }
    }

    private func getTotalAccountsValue() -> String {
        var totalAccountsValue: Float = 0

        for portfolio in self.portfolios {
            if let balance = portfolio.balance {
                    totalAccountsValue += balance.totalValue as Float
            }
        }

        return UtilsService.formatCurrency(totalAccountsValue)
    }
}
