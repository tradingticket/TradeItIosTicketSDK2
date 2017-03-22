import UIKit

class TradeItPortfolioAccountDetailsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource, TradeItPortfolioPositionsTableViewCellDelegate {
    private enum SECTIONS: Int {
        case accountDetails = 0
        case positions
        case count
    }

    private var account: TradeItLinkedBrokerAccount
    private var positions: [TradeItPortfolioPosition] = []
    private var selectedPositionIndex = -1
    private var refreshControl: UIRefreshControl?

    private var _table: UITableView?
    var table: UITableView? {
        get {
            return _table
        }

        set(newTable) {
            if let newTable = newTable {
                newTable.dataSource = self
                newTable.delegate = self
                addRefreshControl(toTableView: newTable)
                _table = newTable
            }
        }
    }

    weak var delegate: TradeItPortfolioAccountDetailsTableDelegate?

    init(account: TradeItLinkedBrokerAccount) {
        self.account = account
    }

    func updateAccount(withAccount account: TradeItLinkedBrokerAccount) {
        self.account = account
    }

    func updatePositions(withPositions positions: [TradeItPortfolioPosition]) {
        self.selectedPositionIndex = -1
        self.positions = positions
        self.table?.reloadData()
    }

    func initiateRefresh() {
        self.refreshControl?.beginRefreshing()
        self.delegate?.refreshRequested(
            onRefreshComplete: {
                self.refreshControl?.endRefreshing()
            }
        )
    }

    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if the user click on the already expanded row, deselect it
        if self.selectedPositionIndex == indexPath.row {
            self.selectedPositionIndex = -1
            self.reloadTableViewAtIndexPath([indexPath])
        } else if self.selectedPositionIndex != -1 {
            let prevPath = IndexPath(row: self.selectedPositionIndex, section: SECTIONS.positions.rawValue)
            self.selectedPositionIndex = indexPath.row
            self.positions[self.selectedPositionIndex].refreshQuote(onFinished: {
                self.reloadTableViewAtIndexPath([prevPath, indexPath])
            })
        } else {
            self.selectedPositionIndex = indexPath.row
            self.positions[self.selectedPositionIndex].refreshQuote(onFinished: {
                self.reloadTableViewAtIndexPath([indexPath])
            })
        }
    }
    
    private func reloadTableViewAtIndexPath(_ indexPaths: [IndexPath]) {
        self.table?.beginUpdates()
        self.table?.reloadRows(at: indexPaths, with: .automatic)
        self.table?.endUpdates()
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return SECTIONS.count.rawValue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTIONS.accountDetails.rawValue {
            return 1
        } else {
            return self.positions.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == SECTIONS.accountDetails.rawValue {
            return nil
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PORTFOLIO_EQUITY_POSITIONS_HEADER_ID")
            //TradeItThemeConfigurator.configureTableHeader(header: cell)
            return cell?.contentView
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == SECTIONS.accountDetails.rawValue {
            return 0.0
        } else {
            return 36.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTIONS.accountDetails.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_PORTFOLIO_ACCOUNT_DETAILS") as! TradeItPortfolioAccountDetailsTableViewCell
            cell.populate(withAccount: account)
            return cell
        } else {
            let position = self.positions[indexPath.row]
            let cell = self.providePositionCell(
                forTableView: tableView,
                forPortfolioPosition: position,
                selected: self.selectedPositionIndex == indexPath.row
            )
            return cell
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let buyAction = UITableViewRowAction(style: .normal, title: "BUY") { (action, indexPath: IndexPath) in
            let position = self.positions[indexPath.row]
            self.delegate?.tradeButtonWasTapped(forPortFolioPosition: position, orderAction: .buy)
        }
        buyAction.backgroundColor = UIColor.tradeItBuyGreenColor
        
        let sellAction = UITableViewRowAction(style: .normal, title: "SELL") { (action, indexPath: IndexPath) in
            let position = self.positions[indexPath.row]
            self.delegate?.tradeButtonWasTapped(forPortFolioPosition: position, orderAction: .sell)
        }
        sellAction.backgroundColor = UIColor.tradeItSellRedColor
        
        
        return [sellAction, buyAction]
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == SECTIONS.positions.rawValue &&
            self.positions[safe: indexPath.row]?.position?.instrumentType() == .EQUITY_OR_ETF &&
            self.selectedPositionIndex != indexPath.row
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // nothing to do but need to be defined to display the actions
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    // MARK: TradeItPortfolioPositionsTableViewCellDelegate
    
    func tradeButtonWasTapped(forPortFolioPosition portfolioPosition: TradeItPortfolioPosition?, orderAction: TradeItOrderAction?) {
        self.delegate?.tradeButtonWasTapped(forPortFolioPosition: portfolioPosition, orderAction: orderAction)
    }

    // MARK: Private

    func providePositionCell(forTableView tableView: UITableView,
                     forPortfolioPosition position: TradeItPortfolioPosition,
                     selected: Bool = false) -> UITableViewCell {
        var cell: UITableViewCell?

        if position.position != nil {
            let equityCell = tableView.dequeueReusableCell(withIdentifier: "PORTFOLIO_EQUITY_POSITIONS_CELL_ID") as! TradeItPortfolioEquityPositionsTableViewCell
            equityCell.delegate = self
            equityCell.populate(withPosition: position)
            equityCell.showPositionDetails(selected)
            cell = equityCell
        } else if position.fxPosition != nil {
            return UITableViewCell()
        }

        if let cell = cell {
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        } else {
            assertionFailure("Failed to create portfolio position table view cell")
            return UITableViewCell()
        }
    }

    func addRefreshControl(toTableView tableView: UITableView) {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl.addTarget(
            self,
            action: #selector(initiateRefresh),
            for: UIControlEvents.valueChanged
        )
        tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
    }
}

protocol TradeItPortfolioAccountDetailsTableDelegate: class {
    func tradeButtonWasTapped(forPortFolioPosition portfolioPosition: TradeItPortfolioPosition?, orderAction: TradeItOrderAction?)
    func refreshRequested(onRefreshComplete: @escaping () -> Void)
}
