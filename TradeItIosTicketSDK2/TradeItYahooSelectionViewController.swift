import UIKit

class TradeItYahooSelectionViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var initialSelection: String?
    var selections = [String]()
    var onSelected: ((String) -> Void)?
    private var selectionTableViewManager: TradeItSelectionTableViewManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.selectionTableViewManager = TradeItSelectionTableViewManager(
            selectionTableView: self.tableView,
            selections: self.selections,
            initialSelection: self.initialSelection,
            onSelected: { selection in
                self.onSelected?(selection)
            }
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.selectionTableViewManager?.update(
            selections: self.selections,
            initialSelection: self.initialSelection
        )
    }
}
