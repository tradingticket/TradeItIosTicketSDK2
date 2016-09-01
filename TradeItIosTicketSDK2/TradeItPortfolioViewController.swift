import UIKit
import PromiseKit
import TradeItIosEmsApi

class TradeItPortfolioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tradeItConnector = TradeItLauncher.tradeItConnector
    var ezLoadingActivityManager: EZLoadingActivityManager = EZLoadingActivityManager()
    var tradeItSession: TradeItSession!
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

    var linkedLogin: TradeItLinkedLogin!
    var accounts: [TradeItBrokerAccount] = []
    var portfolios: [TradeItLinkedAccountPortfolio] = []

    var selectedPortfolioIndex = 0
    var selectedPositionIndex = -1

    @IBOutlet weak var accountsTable: UITableView!
    @IBOutlet weak var holdingsTable: UITableView!
    @IBOutlet weak var totalAccountsValueLabel: UILabel!
    @IBOutlet weak var summaryFxLabel: UILabel!
    @IBOutlet weak var holdingsLabel: UILabel!
    @IBOutlet weak var positionsSpinner: UIActivityIndicatorView!
    @IBOutlet weak var holdingsLabelConstraintY: NSLayoutConstraint!
    @IBOutlet weak var fxSummaryView: UIView!
    @IBOutlet weak var fxTotalValueLabel: UILabel!
    @IBOutlet weak var fxRealizedPlLabel: UILabel!
    @IBOutlet weak var fxUnrealizedPlLabel: UILabel!
    @IBOutlet weak var fxMarginBalanceLabel: UILabel!
    
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
            self.summaryFxLabel.text = self.getSummaryFxLabel()
            self.updateConstraintFxTable()
            self.accountsTable.reloadData()

            firstly {
                return when(self.getPositions(self.portfolios[self.selectedPortfolioIndex]))
            }.always {
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
            } else {
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
        } else if tableView == self.holdingsTable {
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
            } else {
                cell.selector.hidden = true
            }

            cell.rowCellValue1.text = portfolio.accountName
            cell.rowCellUnderValue1.text = portfolio.broker

            if (!portfolio.isBalanceError && portfolio.balance != nil) {
                cell.rowCellValue2.text = UtilsService.formatCurrency(portfolio.balance.buyingPower)
                
                if let totalPercentReturn = portfolio.balance.totalPercentReturn {
                        cell.rowCellValue3.text = UtilsService.formatCurrency(portfolio.balance.totalValue) + " (" + UtilsService.formatPercentage(totalPercentReturn) + ")"
                } else {
                    cell.rowCellValue3.text = UtilsService.formatCurrency(portfolio.balance.totalValue)
                }
            } else if (!portfolio.isBalanceError && portfolio.fxBalance != nil) {
                cell.rowCellValue2.text = UtilsService.formatCurrency(portfolio.fxBalance.buyingPowerBaseCurrency)
                cell.rowCellValue3.text = UtilsService.formatCurrency(portfolio.fxBalance.totalValueBaseCurrency)

                if portfolio.fxBalance.unrealizedProfitAndLossBaseCurrency?.floatValue != 0 {
                    let totalReturn = portfolio.fxBalance.unrealizedProfitAndLossBaseCurrency.floatValue
                    let totalPercentReturn = totalReturn / (portfolio.fxBalance.totalValueBaseCurrency.floatValue - abs(totalReturn))

                    if abs(totalPercentReturn) > 0.01 {
                        cell.rowCellValue3.text = UtilsService.formatCurrency(portfolio.fxBalance.totalValueBaseCurrency) + " (" + UtilsService.formatPercentage(totalPercentReturn) + ")"
                    }
                    
                    fxTotalValueLabel.text = UtilsService.formatCurrency(portfolio.fxBalance.totalValueBaseCurrency)
                    fxRealizedPlLabel.text = UtilsService.formatCurrency(portfolio.fxBalance.realizedProfitAndLossBaseCurrency)
                    fxUnrealizedPlLabel.text = UtilsService.formatCurrency(portfolio.fxBalance.unrealizedProfitAndLossBaseCurrency)
                    fxMarginBalanceLabel.text = UtilsService.formatCurrency(portfolio.fxBalance.marginBalanceBaseCurrency)
                }
            } else {
                cell.rowCellValue2.text = "N/A"
                cell.rowCellValue3.text = "N/A"
            }
        } else if tableView == self.holdingsTable {
            let portfolio = self.portfolios[self.selectedPortfolioIndex]

            if (!portfolio.isPositionsError && portfolio.positions.count > 0) {
                let portfolioSelectedPosition = portfolio.positions[indexPath.row]
                
                if (portfolioSelectedPosition.position != nil) {
                    cell.rowCellValue1.text = portfolioSelectedPosition.position.symbol
                    var qtyLabel = "\(UtilsService.formatQuantity(portfolioSelectedPosition.position.quantity as Float))"
                    qtyLabel += (portfolioSelectedPosition.position.holdingType == "LONG" ? " shares": " short")
                    cell.rowCellUnderValue1.text = qtyLabel
                    cell.rowCellValue2.text = UtilsService.formatCurrency(portfolioSelectedPosition.position.costbasis)
                    cell.rowCellValue3.text = UtilsService.formatCurrency(portfolioSelectedPosition.position.lastPrice)
                }
                else if portfolioSelectedPosition.fxPosition != nil {
                    cell.rowCellValue1.text = portfolioSelectedPosition.fxPosition.symbol
                    let qtyLabel = "\(UtilsService.formatQuantity(portfolioSelectedPosition.fxPosition.quantity as Float))"
                    cell.rowCellUnderValue1.text = qtyLabel
                    cell.rowCellValue2.text = UtilsService.formatCurrency(portfolioSelectedPosition.fxPosition.averagePrice)
                    cell.rowCellValue3.text = UtilsService.formatCurrency(portfolioSelectedPosition.fxPosition.totalUnrealizedProfitAndLossBaseCurrency)
                }
                
            }

            // Set background to white when/select deselect row
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.whiteColor()
            cell.selectedBackgroundView = backgroundView
            
            if (indexPath.row == self.selectedPositionIndex) {
                cell.selector.image = UIImage(named: "chevron_up")
                let portfolioSelectedPosition = portfolio.positions[indexPath.row]

                if portfolioSelectedPosition.quote != nil {
                    cell.positionDetailsLabel1.text = "Bid"
                    cell.positionDetailsLabel2.text = "Ask"
                    cell.positionDetailsLabel4.text = "Total Value"
                    
                    cell.positionDetailsLabel3.hidden = false
                    cell.positionDetailsLabel5.hidden = false
                    cell.positionDetailsValue3.hidden = false
                    cell.positionDetailsValue5.hidden = false
                    
                    cell.positionDetailsValue1.text = UtilsService.formatCurrency(portfolioSelectedPosition.quote.bidPrice) //Bid
                    cell.positionDetailsValue2.text = UtilsService.formatCurrency(portfolioSelectedPosition.quote.askPrice) //Ask
                    if (portfolioSelectedPosition.position != nil) {
                        cell.positionDetailsValue3.text = UtilsService.formatCurrency(portfolioSelectedPosition.quote.low) + " - " + UtilsService.formatCurrency(portfolioSelectedPosition.quote.high)  //Day

                        if (portfolioSelectedPosition.quote.lastPrice != nil) {
                            cell.positionDetailsValue4.text = UtilsService.formatCurrency((portfolioSelectedPosition.position.quantity as Float) * (portfolioSelectedPosition.quote.lastPrice as Float)); //Total value
                        }
                        
                        cell.positionDetailsValue5.text = formatTotalReturnPosition(portfolioSelectedPosition.position) //Total return
                    }
                    else if portfolioSelectedPosition.fxPosition != nil {
                        cell.positionDetailsLabel1.text = "Ask"
                        cell.positionDetailsLabel2.text = "Bid"
                        cell.positionDetailsLabel4.text = "Spread"
                        
                        cell.positionDetailsLabel3.hidden = true
                        cell.positionDetailsLabel5.hidden = true
                        cell.positionDetailsValue3.hidden = true
                        cell.positionDetailsValue5.hidden = true
                        
                        cell.positionDetailsValue1.text = UtilsService.formatCurrency(portfolioSelectedPosition.quote.askPrice) //Ask
                        cell.positionDetailsValue2.text = UtilsService.formatCurrency(portfolioSelectedPosition.quote.bidPrice) //Bid
                        let spread = (portfolioSelectedPosition.quote.high as Float) - (portfolioSelectedPosition.quote.low as Float)
                        cell.positionDetailsValue4.text = UtilsService.formatCurrency(spread)
                    }
                    
                }
                cell.selector.image = UIImage(named: "chevron_down")
            }

        }
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("CUSTOM_PORTFOLIO_HEADER_ID") as! CustomPortfolioHeaderCell
        if (tableView == self.holdingsTable && self.portfolios.count > 0 && self.portfolios[self.selectedPortfolioIndex].fxBalance != nil) {
            cell.headerNameColumn2.text = "Avg. Rate"
            cell.headerNameColumn3.text = "Unrealized P/L"
        }
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
    
    private func getAccountName(account: TradeItBrokerAccount , broker: String) -> String {
        var formattedAccountNumber = account.accountNumber
        var formattedAccountName = account.name
        
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
        } else {
            return "Holdings"
        }
    }
    
    private func getSummaryFxLabel() -> String{
        if self.portfolios.count > 0 {
            return self.portfolios[self.selectedPortfolioIndex].accountName + " Summary"
        } else {
            return "Summary"
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
                            fxBalance: nil,
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
            self.updateConstraintFxTable()
            self.accountsTable.reloadData()
            self.holdingsTable.reloadData()
            self.totalAccountsValueLabel.text = self.getTotalAccountsValue()
            self.summaryFxLabel.text = self.getSummaryFxLabel()
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

            tradeItSession.authenticate(linkedLogin, withCompletionBlock: { (tradeItResult: TradeItResult!) in
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
                        let accountName = self.getAccountName(account as! TradeItBrokerAccount, broker: linkedLogin.broker)
                        let tradeItLinkedAccountPortfolio = TradeItLinkedAccountPortfolio(
                            tradeItSession: tradeItSession,
                            broker: linkedLogin.broker,
                            accountName: accountName,
                            accountNumber: account.accountNumber,
                            balance: nil,
                            fxBalance: nil,
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
                    portfolio.balance = tradeItAccountOverviewResult.accountOverview
                    portfolio.fxBalance = tradeItAccountOverviewResult.fxAccountOverview
                }

                fulfill(tradeItResult)
            })
        }
    }
    
    private func getPositions(portfolio: TradeItLinkedAccountPortfolio) -> Promise<TradeItResult> {
        return Promise { fulfill, reject in
            self.positionsSpinner.startAnimating()

            let request = TradeItGetPositionsRequest(accountNumber: portfolio.accountNumber)
            self.tradeItPositionService.session = portfolio.tradeItSession

            self.tradeItPositionService.getAccountPositions(request, withCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
                self.positionsSpinner.stopAnimating()

                if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                    //TODO
                    print("Error \(tradeItErrorResult)")
                    portfolio.isPositionsError = true
                } else if let tradeItGetPositionsResult = tradeItResult as? TradeItGetPositionsResult {
                    var positionsPortfolio:[TradeItPortfolioPosition] = []

                    let positions = tradeItGetPositionsResult.positions as! [TradeItPosition]
                    for position in positions {
                        let positionPortfolio = TradeItPortfolioPosition(position: position)
                        positionsPortfolio.append(positionPortfolio)
                    }
                    
                    let fxPositions = tradeItGetPositionsResult.fxPositions as! [TradeItFxPosition]
                    for fxPosition in fxPositions {
                        let positionPortfolio = TradeItPortfolioPosition(fxPosition: fxPosition)
                        positionsPortfolio.append(positionPortfolio)
                    }

                    portfolio.positions = positionsPortfolio
                }

                fulfill(tradeItResult)
            })
        }
    }
    
    private func getQuoteForPortfolioSelectedPosition(portfolio: TradeItLinkedAccountPortfolio) -> Promise<TradeItQuote> {
        return Promise { fulfill, reject in
            let selectedPositionPortfolio = portfolio.positions[self.selectedPositionIndex]
            self.tradeItMarketDataService.session = portfolio.tradeItSession
            var symbol = ""
            var tradeItQuoteRequest:TradeItQuotesRequest!
            if let position = selectedPositionPortfolio.position {
                symbol = position.symbol
                tradeItQuoteRequest = TradeItQuotesRequest(symbol: symbol)
            }
            else if let position = selectedPositionPortfolio.fxPosition {
                symbol = position.symbol
                tradeItQuoteRequest = TradeItQuotesRequest(fxSymbol: symbol, andBroker: portfolio.broker)
            }
            var quote = TradeItQuote()
            self.tradeItMarketDataService.getQuoteData(tradeItQuoteRequest, withCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
                if let tradeItQuoteResult = tradeItResult as? TradeItQuotesResult {
                    let results = tradeItQuoteResult.quotes.filter { return $0.symbol == symbol}
                    if results.count > 0 {
                        quote = results[0] as! TradeItQuote
                        selectedPositionPortfolio.quote = quote
                    }
                } else {
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
    
    private func updateConstraintFxTable() {
        if self.portfolios[self.selectedPortfolioIndex].fxBalance == nil {
            self.summaryFxLabel.hidden = true
            self.fxSummaryView.hidden = true
            self.holdingsLabelConstraintY.constant = 150
        }
        else {
            self.summaryFxLabel.hidden = false
            self.fxSummaryView.hidden = false
            self.holdingsLabelConstraintY.constant = 250
        }
    }
}
