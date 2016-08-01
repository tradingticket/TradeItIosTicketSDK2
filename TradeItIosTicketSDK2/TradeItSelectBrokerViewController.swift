import UIKit

class TradeItSelectBrokerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var brokerTable: UITableView!

    var brokers: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        brokers = ["broker 1", "broker 2", "broker 3"]
    }

    // Mark: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("SELECTED: \(indexPath.row) \(brokers[indexPath.row])")
    }

    // Mark: - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brokers.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let brokerCellIdentifier = "BROKER_CELL_IDENTIFIER"

        var cell = tableView.dequeueReusableCellWithIdentifier(brokerCellIdentifier)

        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: brokerCellIdentifier)
            cell?.textLabel?.font = UIFont.systemFontOfSize(13.0)
            cell?.textLabel?.textColor = UIColor.darkTextColor()
        }

        cell?.textLabel?.text = brokers[indexPath.row]
        
        return cell!
    }
}