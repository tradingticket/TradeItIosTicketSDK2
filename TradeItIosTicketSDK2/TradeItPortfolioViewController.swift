import UIKit

class TradeItPortfolioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var accounts: [TradeItAccount] = []
    var selectedBroker: TradeItBroker!
    
    @IBOutlet weak var accountsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountsTable.reloadData()
    }
    
   
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CUSTOM_PORTFOLIO_CELL_ID"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! CustomPortfolioCell
        
        cell.rowCellValue1.text = getAccountName(self.accounts[indexPath.row], broker: selectedBroker.brokerShortName)
        //cell.rowCellValue2.text = "" //TODO total value
        //cell.rowCellValue3.text = "" //TODO buyingpower
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCellIdentifier = "CUSTOM_PORTFOLIO_HEADER_ID"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(headerCellIdentifier) as! CustomPortfolioHeaderCell
        return cell
    }
    
    
    // MARK: private
    
    private func getAccountName(account: TradeItAccount , broker: String) -> String {
        let accountNumber = account.accountNumber
        let startIndex = accountNumber.endIndex.advancedBy(-4)
        return "\(broker) *\(String(accountNumber.characters.suffixFrom(startIndex)))"
    }
    
    
}
