import UIKit

class TradeItBrokerCenterViewController: TradeItViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        TradeItLauncher.brokerCenterService.getPublishers(onSuccess: { publishers in
            print(publishers)
        }, onFailure: { error in
            print(error)
        })
    }
}
