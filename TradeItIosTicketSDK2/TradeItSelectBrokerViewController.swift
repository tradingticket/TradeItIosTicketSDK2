import UIKit

class TradeItSelectBrokerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var brokerTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var tradeItConnector: TradeItConnector = TradeItConnector.init(apiKey: "tradeit-test-api-key")
    var brokers: [[String : AnyObject]] = []
    let segueLoginViewControllerId = "SEGUE_LOGIN_CONTROLLER"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tradeItConnector.environment = TradeItEmsTestEnv

        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.startAnimating()

        self.tradeItConnector.getAvailableBrokersWithCompletionBlock { (availableBrokers: [AnyObject]!) in
            if let availableBrokers = availableBrokers {
                for broker in availableBrokers {
                    if let broker = broker as? Dictionary<String, AnyObject> {
                        self.brokers.append(broker)
                    }
                }
            }
            else {
                let alert = UIAlertController(title: "Could not fetch brokers", message: "Could not fetch the brokers list. Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }

            self.brokerTable.reloadData()

            self.activityIndicator.stopAnimating()
        }
    }

    // Mark: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(segueLoginViewControllerId, sender: self)
        self.brokerTable.deselectRowAtIndexPath(indexPath, animated: true)
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

        cell?.textLabel?.text = self.brokers[indexPath.row]["longName"] as? String
        
        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueLoginViewControllerId {
            if let indexPath = self.brokerTable.indexPathForSelectedRow, let selectedBroker = self.brokers[indexPath.row] as [String : AnyObject]!  {
                let destinationViewController = segue.destinationViewController as! TradeItLoginViewController
                destinationViewController.selectedBroker = selectedBroker
                destinationViewController.tradeItConnector = tradeItConnector
            }
        }
    }

}