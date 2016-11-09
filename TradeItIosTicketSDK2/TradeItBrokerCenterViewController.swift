import UIKit

class TradeItBrokerCenterViewController: TradeItViewController {
    @IBOutlet weak var tableView: UITableView!
    var tableManager = TradeItBrokerCenterTableViewManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableManager.publishersTable = tableView
        TradeItLauncher.brokerCenterService.getPublishers(onSuccess: { publishers in
            self.tableManager.update(publishers: publishers)
        }, onFailure: { error in
            print(error)
        })
    }
}
