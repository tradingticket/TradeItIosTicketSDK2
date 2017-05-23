import UIKit

class TradeItSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adContainer: UIView!

    var initialSelection: String?
    var selections = [String]()
    var onSelected: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self

        TradeItSDK.adService?.configure(adContainer: adContainer, rootViewController: self, pageType: .trading, position: .bottom)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.reloadData()
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.onSelected?(self.selections[indexPath.row])
    }
    
    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selection = self.selections[indexPath.row]

        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_SELECTION_CELL_ID") ?? UITableViewCell()
        cell.textLabel?.text = selection

        if selection == self.initialSelection {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
}
