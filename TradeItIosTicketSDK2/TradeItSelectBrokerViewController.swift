import UIKit
import TradeItIosEmsApi

class TradeItSelectBrokerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var brokerTable: UITableView!

    var brokers: [TradeItBroker] = []
    let toLoginScreenSegueId = "TO_LOGIN_SCREEN_SEGUE"
    var ezLoadingActivityManager: EZLoadingActivityManager = EZLoadingActivityManager()
    var selectedBroker: TradeItBroker?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.selectedBroker = nil

        ezLoadingActivityManager.show(text: "Loading Brokers", disableUI: true)

        TradeItLauncher.tradeItConnector.getAvailableBrokersAsObjectsWithCompletionBlock { (availableBrokers: [TradeItBroker]?) in
            if let availableBrokers = availableBrokers {
                self.brokers = availableBrokers
                self.brokerTable.reloadData()
            } else {
                let alert = UIAlertController(title: "Could not fetch brokers",
                                              message: "Could not fetch the brokers list. Please try again later.",
                                              preferredStyle: UIAlertControllerStyle.Alert)

                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }

            self.ezLoadingActivityManager.hide()
        }
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedBroker = self.brokers[indexPath.row]
        self.performSegueWithIdentifier(toLoginScreenSegueId, sender: self)
        self.brokerTable.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: UITableViewDataSource

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

        if let brokerLongName = self.brokers[indexPath.row].brokerLongName {
            cell?.textLabel?.text = brokerLongName
        }
        
        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == toLoginScreenSegueId {
            if let destinationViewController = segue.destinationViewController as? TradeItLoginViewController,
                broker = self.selectedBroker {
                destinationViewController.selectedBroker = broker
            }
        }
    }

}