import UIKit

class TradeItAccountManagementTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var _table: UITableView?
    private var linkedBrokerAccounts: [TradeItLinkedBrokerAccount] = []
    private var refreshControl: UIRefreshControl?
    internal weak var delegate: TradeItAccountManagementTableViewManagerDelegate?

    private enum SECTIONS: Int {
        case accounts = 0
        case manage
        case count
    }

    var accountsTableView: UITableView? {
        get {
            return _table
        }
        set(newTable) {
            if let newTable = newTable {
                newTable.dataSource = self
                newTable.delegate = self
                addRefreshControl(toTableView: newTable)
                _table = newTable
                _table?.reloadData()
            }
        }
    }

    func updateAccounts(withAccounts linkedBrokerAccounts: [TradeItLinkedBrokerAccount]) {
        self.linkedBrokerAccounts = linkedBrokerAccounts
        self.accountsTableView?.reloadData()
    }
    
    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SECTIONS.init(rawValue: indexPath.section) else { return }
        if section == .manage {
            if indexPath.row == 0 {
                self.delegate?.relink()
            } else if indexPath.row == 1 {
                self.delegate?.unlink()
            }
        }
    }
    
    
    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return SECTIONS.count.rawValue
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection sectionIndex: Int) -> UIView? {
        return TradeItThemeConfigurator.tableHeader(withText: headerLabelFor(sectionIndex))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
        guard let section = SECTIONS.init(rawValue: sectionIndex) else { return 0 }
        switch section {
        case .accounts: return linkedBrokerAccounts.count
        case .manage: return 2
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = SECTIONS.init(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .accounts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ACCOUNT_MANAGEMENT_CELL_ID") as! TradeItAccountManagementTableViewCell
            cell.populate(self.linkedBrokerAccounts[indexPath.row])
            return cell
        case .manage:
            return provideActionCell(forTableView: tableView, andRow: indexPath.row)
        default:
            return UITableViewCell()
        }
    }

    // MARK: Private

    func addRefreshControl(toTableView tableView: UITableView) {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl.addTarget(self,
                                 action: #selector(refreshControlActivated),
                                 for: UIControlEvents.valueChanged)
        TradeItThemeConfigurator.configure(view: refreshControl)
        tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
    }

    func refreshControlActivated() {
        self.delegate?.refreshRequested(fromAccountManagementTableViewManager: self,
                                        onRefreshComplete: { (accounts: [TradeItLinkedBrokerAccount]?) in
                                            if let accounts = accounts {
                                                self.updateAccounts(withAccounts: accounts)
                                            }

                                            self.refreshControl?.endRefreshing()
                                        })
    }

    private func provideActionCell(forTableView tableView: UITableView, andRow row: Int) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACCOUNT_MANAGEMENT_ACTION_CELL_ID")!
        TradeItThemeConfigurator.configure(view: cell)
        switch row {
        case 0:
            cell.textLabel?.text = "Relink"
            cell.textLabel?.textColor = TradeItSDK.theme.textColor
        case 1:
            cell.textLabel?.text = "Unlink"
            cell.textLabel?.textColor = TradeItSDK.theme.warningTextColor
        default:
            return UITableViewCell()
        }
        return cell
    }

    private func headerLabelFor(_ sectionIndex: Int) -> String? {
        guard let section = SECTIONS.init(rawValue: sectionIndex) else { return nil }
        switch section {
        case .accounts: return "ACCOUNTS"
        case .manage: return "MANAGE"
        default: return nil
        }
    }
}

protocol TradeItAccountManagementTableViewManagerDelegate: class {
    func refreshRequested(
        fromAccountManagementTableViewManager manager: TradeItAccountManagementTableViewManager,
        onRefreshComplete: @escaping (_ withAccounts: [TradeItLinkedBrokerAccount]?) -> Void
    )

    func relink()

    func unlink()
}
