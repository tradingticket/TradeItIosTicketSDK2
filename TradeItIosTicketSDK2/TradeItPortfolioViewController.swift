import UIKit

class TradeItPortfolioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var accounts: [TradeItAccount] = []
    
    @IBOutlet weak var accountsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("accounts available on portfolio screen: \(self.accounts)")
        accountsTable.reloadData()
    }
    
   
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CUSTOM_CELL_ID"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! CustomCell
        
        cell.nameLabel.text = getAccountName(self.accounts[indexPath.row], broker: "Dummy") //TODO get broker name
        cell.value1Label.text = "" //TODO total value
        cell.value2Label.text = "" //TODO buyingpower
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCellIdentifier = "CUSTOM_HEADER_ID"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(headerCellIdentifier)
        return cell!
    }
    
    
    // MARK: private
    private func getAccountName(account: TradeItAccount , broker: String) -> String {
        let accountNumber = account.accountNumber
        let startIndex = accountNumber.endIndex.advancedBy(-4)
        return "\(broker) *\(String(accountNumber.characters.suffixFrom(startIndex)))"
    }
    
    
}
