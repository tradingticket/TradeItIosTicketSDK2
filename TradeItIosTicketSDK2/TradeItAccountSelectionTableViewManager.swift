import UIKit

class TradeItAccountSelectionTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var _table: UITableView?
    private var refreshControl: UIRefreshControl?
    internal weak var delegate: TradeItAccountSelectionTableViewManagerDelegate?
    private var linkedBrokerSectionPresenters: [LinkedBrokerSectionPresenter] = []
    private var selectedLinkedBrokerAccount: TradeItLinkedBrokerAccount?

    var accountsTable: UITableView? {
        get {
            return _table
        }
        set(newTable) {
            if let newTable = newTable {
                newTable.tableFooterView = UIView()
                newTable.dataSource = self
                newTable.delegate = self
                addRefreshControl(toTableView: newTable)
                _table = newTable
            }
        }
    }

    func updateLinkedBrokers(withLinkedBrokers linkedBrokers: [TradeItLinkedBroker], withSelectedLinkedBrokerAccount selectedLinkedBrokerAccount: TradeItLinkedBrokerAccount?) {
        self.selectedLinkedBrokerAccount = selectedLinkedBrokerAccount
        self.linkedBrokerSectionPresenters = linkedBrokers.map { linkedBroker in
            return LinkedBrokerSectionPresenter(
                linkedBroker: linkedBroker,
                selectedLinkedBrokerAccount: selectedLinkedBrokerAccount
            )
        }
        self.accountsTable?.reloadData()
    }

    func initiateRefresh(animated: Bool = true) {
        if animated {
            self.refreshControl?.beginRefreshing()
        }
        self.delegate?.refreshRequested(
            fromAccountSelectionTableViewManager: self,
            onRefreshComplete: { linkedBrokers in
                if let linkedBrokers = linkedBrokers  {
                    self.updateLinkedBrokers(
                        withLinkedBrokers: linkedBrokers,
                        withSelectedLinkedBrokerAccount: self.selectedLinkedBrokerAccount)
                }

                self.refreshControl?.endRefreshing()
            }
        )
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let linkedBrokerIndex = indexPath.section
        guard let linkedBrokerPresenter = self.linkedBrokerSectionPresenters[safe: linkedBrokerIndex] else { return }

        if linkedBrokerPresenter.isAccountLinkDelayedError() {
            guard let error = linkedBrokerPresenter.linkedBroker.error else { return }
            if error.requiresAuthentication() {
                self.delegate?.authenticate(linkedBroker: linkedBrokerPresenter.linkedBroker)
            } else {
                self.initiateRefresh()
            }
        } else {
            guard let selectedAccount = linkedBrokerPresenter.accountFor(row: indexPath.row) else { return }
            self.delegate?.linkedBrokerAccountWasSelected(selectedAccount)
        }
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.linkedBrokerSectionPresenters.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection sectionIndex: Int) -> UIView? {
        let cell = UITableViewCell()
        let linkedBroker = self.linkedBrokerSectionPresenters[safe: sectionIndex]?.linkedBroker
        cell.textLabel?.text = linkedBroker?.brokerName
        TradeItThemeConfigurator.configureTableHeader(header: cell)

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let linkedBrokerSectionPresenter = self.linkedBrokerSectionPresenters[safe: section] else { return 0 }
            return linkedBrokerSectionPresenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionPresenter = self.linkedBrokerSectionPresenters[safe: indexPath.section] else { return UITableViewCell() }
        return sectionPresenter.cell(forTableView: tableView, andRow: indexPath.row)
    }

    // MARK: Private

    private func addRefreshControl(toTableView tableView: UITableView) {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl.addTarget(self,
                                 action: #selector(initiateRefresh),
                                 for: UIControlEvents.valueChanged)
        TradeItThemeConfigurator.configure(view: refreshControl)
        tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
    }

    fileprivate class LinkedBrokerSectionPresenter {
        let linkedBroker: TradeItLinkedBroker
        let selectedLinkedBrokerAccount: TradeItLinkedBrokerAccount?

        init(linkedBroker: TradeItLinkedBroker, selectedLinkedBrokerAccount: TradeItLinkedBrokerAccount?) {
            self.linkedBroker = linkedBroker
            self.selectedLinkedBrokerAccount = selectedLinkedBrokerAccount
        }

        func numberOfRows() -> Int {
            if isAccountLinkDelayedError() {
                return 1
            } else {
                return self.linkedBroker.getEnabledAccounts().count
            }
        }

        func cell(forTableView tableView: UITableView, andRow row: Int) -> UITableViewCell {
            if isAccountLinkDelayedError() {
                 let cell = tableView.dequeueReusableCell(withIdentifier: "ACCOUNT_SELECTION_ERROR_CELL_ID") as? TradeItLinkedBrokerErrorTableViewCell
                cell?.populate(withLinkedBroker: linkedBroker)
                return cell ?? UITableViewCell()
            }

            guard let account = accountFor(row: row) else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: "ACCOUNT_SELECTION_CELL_ID") as? TradeItAccountSelectionTableViewCell
            cell?.populate(withLinkedBrokerAccount: account)
            if selectedLinkedBrokerAccount?.accountNumber == account.accountNumber
                && selectedLinkedBrokerAccount?.brokerName == account.brokerName {
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }
            return cell ?? UITableViewCell()
        }

        func accountFor(row: Int) -> TradeItLinkedBrokerAccount? {
            return self.linkedBroker.getEnabledAccounts()[safe: row]
        }

        func isAccountLinkDelayedError() -> Bool {
            return self.linkedBroker.isAccountLinkDelayedError
        }
    }

}

protocol TradeItAccountSelectionTableViewManagerDelegate: class {
    func linkedBrokerAccountWasSelected(_ linkedBrokerAccount: TradeItLinkedBrokerAccount)
    func authenticate(linkedBroker: TradeItLinkedBroker)
    func relink(linkedBroker: TradeItLinkedBroker)
    func refreshRequested(fromAccountSelectionTableViewManager manager: TradeItAccountSelectionTableViewManager,
                          onRefreshComplete: @escaping ([TradeItLinkedBroker]?) -> Void)
}
