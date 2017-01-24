import UIKit

class TradeItYahooTradingTicketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var order: TradeItOrder!
    var delegate: TradeItYahooTradingTicketViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.order == nil {
            self.order = TradeItOrder()
        }

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

@objc protocol TradeItYahooTradingTicketViewControllerDelegate {
    
}
