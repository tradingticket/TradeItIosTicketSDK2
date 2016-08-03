import UIKit

class TradeItSelectBrokerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var brokerTable: UITableView!

    var tradeItConnector: TradeItConnector = TradeItConnector.init(apiKey: "tradeit-test-api-key")
    let activityIndicator = UIActivityIndicatorView()
    var brokers: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tradeItConnector.environment = TradeItEmsTestEnv

        initializeActivityIndicator()

        activityIndicator.startAnimating()

        tradeItConnector.getAvailableBrokersWithCompletionBlock { (availableBrokers: [AnyObject]?) in
            if let availableBrokers = availableBrokers {
                for broker in availableBrokers {
                    if let name = broker["longName"] as? String {
                        self.brokers.append(name)
                    }
                }
            }

            self.brokerTable.reloadData()

            self.activityIndicator.stopAnimating()
        }
    }

    // Mark: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("SELECTED: \(indexPath.row) \(self.brokers[indexPath.row])")
    }

    // Mark: - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.brokers.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let brokerCellIdentifier = "BROKER_CELL_IDENTIFIER"

        var cell = tableView.dequeueReusableCellWithIdentifier(brokerCellIdentifier)

        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: brokerCellIdentifier)
            cell?.textLabel?.font = UIFont.systemFontOfSize(13.0)
            cell?.textLabel?.textColor = UIColor.darkTextColor()
        }

        cell?.textLabel?.text = self.brokers[indexPath.row]
        
        return cell!
    }

    // Mark - private

    private func initializeActivityIndicator() {
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.color = UIColor.darkGrayColor()
        activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y)
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
    }

}