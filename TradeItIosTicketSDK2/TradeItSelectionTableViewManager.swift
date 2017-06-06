import UIKit

class TradeItSelectionTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var selectionTableView: UITableView
    private var initialSelection: String?
    private var selections = [String]()
    private var onSelected: ((String) -> Void)?

    init(
        selectionTableView: UITableView,
        selections: [String],
        initialSelection: String?,
        onSelected: ((String) -> Void)?
    ) {
        self.selectionTableView = selectionTableView
        self.initialSelection = initialSelection
        self.selections = selections
        self.onSelected = onSelected

        super.init()

        self.selectionTableView.dataSource = self
        self.selectionTableView.delegate = self
    }

    func update(
        selections: [String],
        initialSelection: String?
    ) {
        self.initialSelection = initialSelection
        self.selections = selections

        self.selectionTableView.reloadData()
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

        let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_SELECTION_CELL_ID") ?? UITableViewCell()
        cell.textLabel?.text = selection

        if selection == self.initialSelection {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}
