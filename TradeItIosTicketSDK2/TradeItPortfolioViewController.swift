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
    var _tradeItMarketDataService: TradeItMarketDataService!
    var tradeItMarketDataService: TradeItMarketDataService! {
        get {
            if self._tradeItMarketDataService == nil {
                self._tradeItMarketDataService = TradeItMarketDataService(session: tradeItSession)
            }
            return self._tradeItMarketDataService
        }
        set (tradeItMarketDataService) {
            self._tradeItMarketDataService = tradeItMarketDataService
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
            if self.selectedPositionIndex != indexPath.row {
                self.selectedPositionIndex = indexPath.row
                
                self.getQuoteForPortfolioSelectedPosition(self.portfolios[self.selectedPortfolioIndex])
                .then { _ -> Void in
                    self.holdingsTable.beginUpdates()
                    self.holdingsTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    self.holdingsTable.endUpdates()
                }
            }
            else {
                // there is no cell selected anymore
                self.selectedPositionIndex = -1
            }
        }
        self.holdingsTable.reloadData()
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
            cell.rowCellUnderValue1.text = portfolio.broker
            if (!portfolio.isBalanceError && portfolio.balance != nil) {
                cell.rowCellValue2.text = UtilsService.formatCurrency(portfolio.balance.buyingPower)
                
                if let totalPercentReturn = portfolio.balance.totalPercentReturn {
                        cell.rowCellValue3.text = UtilsService.formatCurrency(portfolio.balance.totalValue) + " (" + UtilsService.formatPercentage(totalPercentReturn) + ")"
                }
                else {
                    cell.rowCellValue3.text = UtilsService.formatCurrency(portfolio.balance.totalValue)
                }
            }
            else {
                cell.rowCellValue2.text = "N/A"
                cell.rowCellValue3.text = "N/A"
            }
        }
        else if tableView == self.holdingsTable {
            let portfolio = self.portfolios[self.selectedPortfolioIndex]
            if (!portfolio.isPositionsError && portfolio.positions.count > 0) {
                let portfolioSelectedPosition = portfolio.positions[indexPath.row]
                cell.rowCellValue1.text = portfolioSelectedPosition.position.symbol
                var qtyLabel = "\(UtilsService.formatQuantity(portfolioSelectedPosition.position.quantity as Float))"
                qtyLabel += (portfolioSelectedPosition.position.holdingType == "LONG" ? " shares": " short")
                cell.rowCellUnderValue1.text = qtyLabel
                cell.rowCellValue2.text = UtilsService.formatCurrency(portfolioSelectedPosition.position.costbasis)
                cell.rowCellValue3.text = UtilsService.formatCurrency(portfolioSelectedPosition.position.lastPrice)
            }
            
            //Set background to white when/select deselect row
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.whiteColor()
            cell.selectedBackgroundView = backgroundView
            
            if (indexPath.row == self.selectedPositionIndex) {
                cell.selector.image = UIImage(named: "chevron_up")
                let portfolioSelectedPosition = portfolio.positions[indexPath.row]
                if portfolioSelectedPosition.quote != nil {
                    cell.positionDetailsValue1.text = UtilsService.formatCurrency(portfolioSelectedPosition.quote.bidPrice) //Bid
                    cell.positionDetailsValue2.text = UtilsService.formatCurrency(portfolioSelectedPosition.quote.askPrice) //Ask
                    cell.positionDetailsValue3.text = UtilsService.formatCurrency(portfolioSelectedPosition.quote.low) + " - " + UtilsService.formatCurrency(portfolioSelectedPosition.quote.high)  //Day
                    if (portfolioSelectedPosition.quote.lastPrice != nil) {
                        cell.positionDetailsValue4.text = UtilsService.formatCurrency((portfolioSelectedPosition.position.quantity as Float) * (portfolioSelectedPosition.quote.lastPrice as Float)); //Total value
                    }
                    
                    cell.positionDetailsValue5.text = formatTotalReturnPosition(portfolioSelectedPosition.position) //Total return
                }
            }
            else {
                cell.selector.image = UIImage(named: "chevron_down")
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
                return 150
            }
            return 50
        }
        return 50
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
        var formattedAccountNumber = account.accountNumber
        var formattedAccountName = account.accountName
        
        if formattedAccountNumber.characters.count > 4 {
            let startIndex = formattedAccountNumber.endIndex.advancedBy(-4)
            formattedAccountNumber = String(formattedAccountNumber.characters.suffixFrom(startIndex))
        }
        
        if formattedAccountName.characters.count > 10 {
            formattedAccountName = String(formattedAccountName.characters.prefix(10))
        }
        return "\(formattedAccountName)**\(formattedAccountNumber)"
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
            self.ezLoadingActivityManager.updateText(text: "Retreiving Account Summary")
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
                    let positions = tradeItGetPositionsResult.positions as! [TradeItPosition]
                    var positionsPortfolio:[TradeItPositionPortfolio] = []
                    for position in positions {
                        let positionPortfolio = TradeItPositionPortfolio(position: position, quote: nil)
                        positionsPortfolio.append(positionPortfolio)
                    }
                    portfolio.positions = positionsPortfolio
                }

                fulfill(tradeItResult)
            })
        }
    }
    
    private func getQuoteForPortfolioSelectedPosition(portfolio: TradeItLinkedAccountPortfolio) -> Promise<TradeItQuote>{
        return Promise { fulfill, reject in
            let selectedPositionPortfolio = portfolio.positions[self.selectedPositionIndex]
            self.tradeItMarketDataService.session = portfolio.tradeItSession
            let tradeItQuoteRequest = TradeItQuotesRequest(symbol: selectedPositionPortfolio.position.symbol)
            var quote = TradeItQuote()
            self.tradeItMarketDataService.getQuoteDataAsArray(tradeItQuoteRequest, withCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
                    if let tradeItQuoteResult = tradeItResult as? TradeItQuotesResult {
                        let results = tradeItQuoteResult.quotes.filter { return $0.symbol == selectedPositionPortfolio.position.symbol}
                        if results.count > 0 {
                            quote = results[0] as! TradeItQuote
                            selectedPositionPortfolio.quote = quote
                        }
                    }
                    else {
                        //TODO handle error
                        print("error quote")
                    }
                     fulfill(quote)

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
    
    private func formatTotalReturnPosition(position: TradeItPosition) -> String {
        let totalGainLossDollar = position.totalGainLossDollar
        let totalGainLossPercentage = position.totalGainLossPercentage
        var returnStr = ""
        if (totalGainLossDollar != nil) {
            var returnPrefix = ""
            if (totalGainLossDollar.floatValue > 0) {
                returnPrefix = "+";
            } else if (totalGainLossDollar.floatValue == 0) {
                returnStr = "N/A";
            }
            var returnPctStr = ""
            if (totalGainLossPercentage != nil) {
                returnPctStr = UtilsService.formatPercentage(totalGainLossPercentage.floatValue);
            } else {
                returnPctStr = "N/A";
            }
            
            if (returnStr == "") {
                returnStr = "\(returnPrefix)\(UtilsService.formatCurrency(totalGainLossDollar.floatValue))(\(returnPctStr))";
            }
        } else {
            returnStr = "N/A";
        }
        return returnStr
    }
}
