import UIKit

class TradeItPortfolioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var accounts: [TradeItAccount] = []
    var selectedBroker: TradeItBroker!
    var tradeItSession: TradeItSession!
    var tradeItBalanceService : TradeItBalanceService!
    @IBOutlet weak var accountsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tradeItBalanceService = TradeItBalanceService(session: tradeItSession)
        self.accountsTable.reloadData()
    }
    
   
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CUSTOM_PORTFOLIO_CELL_ID"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! CustomPortfolioCell
        let selectedAccount = self.accounts[indexPath.row]
        cell.rowCellValue1.text = getAccountName(selectedAccount, broker: selectedBroker.brokerShortName)
        
        getAccountOverviewForAccountNumber(selectedAccount.accountNumber, completionBlock: { (tradeItErrorResult: TradeItErrorResult!, tradeItAccountOverviewResult: TradeItAccountOverviewResult!) in
            if tradeItErrorResult != nil {
                self.showTradeItErrorResultAlert(tradeItErrorResult)
            }
            else {
                cell.rowCellValue2.text = "$\(tradeItAccountOverviewResult.totalValue)"
                cell.rowCellValue3.text = "$\(tradeItAccountOverviewResult.buyingPower)"
            }
        })
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCellIdentifier = "CUSTOM_PORTFOLIO_HEADER_ID"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(headerCellIdentifier) as! CustomPortfolioHeaderCell
        return cell
    }
    
    
    // MARK: private
    
    private func getAccountOverviewForAccountNumber(accountNumber: String, completionBlock: (tradeItErrorResult: TradeItErrorResult!, tradeItAccountOverviewResult: TradeItAccountOverviewResult!) -> Void) -> Void {
        let request = TradeItAccountOverviewRequest(accountNumber: accountNumber)
        tradeItBalanceService.getAccountOverview(request, withCompletionBlock: { (tradeItResult: TradeItResult!) -> Void in
            if let tradeItErrorResult = tradeItResult as? TradeItErrorResult {
                completionBlock(tradeItErrorResult: tradeItErrorResult, tradeItAccountOverviewResult: nil)
            } else if let tradeItResult = tradeItResult as? TradeItAccountOverviewResult {
                completionBlock(tradeItErrorResult: nil, tradeItAccountOverviewResult: tradeItResult)
            }
        })
    }
    
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
    
    
}
