import UIKit

class TradeItPortfolioAccountDetailsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource, TradeItPortfolioPositionsTableViewCellDelegate {
    private var account: TradeItLinkedBrokerAccount?
    private var positions: [TradeItPortfolioPosition] = []
    private var selectedPositionIndex = -1

    private var _table: UITableView?
    var table: UITableView? {
        get {
            return _table
        }

        set(newTable) {
            if let newTable = newTable {
                newTable.dataSource = self
                newTable.delegate = self
                newTable.rowHeight = UITableViewAutomaticDimension
                newTable.estimatedRowHeight = 150
                _table = newTable
            }
        }
    }

    weak var delegate: TradeItPortfolioAccountDetailsTableDelegate?

    func updateAccount(withAccount account: TradeItLinkedBrokerAccount) {
        self.account = account
        let indexPath = IndexPath(row: 0, section: 0)
        self.reloadTableViewAtIndexPath([indexPath])
    }

    func updatePositions(withPositions positions: [TradeItPortfolioPosition]) {
        self.selectedPositionIndex = -1
        self.positions = positions
        self.table?.reloadData()
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if the user click on the already expanded row, deselect it
        if self.selectedPositionIndex == indexPath.row {
            self.selectedPositionIndex = -1
            self.reloadTableViewAtIndexPath([indexPath])
        } else if self.selectedPositionIndex != -1 {
            let prevPath = IndexPath(row: self.selectedPositionIndex, section: 0);
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
        self.table?.selectRow(at: indexPaths.last, animated: true, scrollPosition: .top)
    }

    // MARK: UITableViewDataSource


    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.positions.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }

        var cell: UITableViewCell?

        // TODO: Look at handling FX
        if self.positions.count > 0 {
            if self.positions[0].position != nil {
                cell = tableView.dequeueReusableCell(withIdentifier: "PORTFOLIO_EQUITY_POSITIONS_HEADER_ID")
            } else if self.positions[0].fxPosition != nil {
                cell = tableView.dequeueReusableCell(withIdentifier: "PORTFOLIO_FX_POSITIONS_HEADER_ID")
            }
        }
        
        TradeItThemeConfigurator.configureTableHeader(header: cell)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }

        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let account = self.account {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_PORTFOLIO_ACCOUNT_DETAILS") as! TradeItPortfolioAccountDetailsTableViewCell
                cell.populate(withAccount: account)
                return cell
            } else {
                return UITableViewCell()
            }
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
        let buyAction = UITableViewRowAction(style: .normal, title: "BUY") { action, index in
            let position = self.positions[(index as NSIndexPath).row]
            self.delegate?.tradeButtonWasTapped(forPortFolioPosition: position, orderAction: .buy)
        }
        buyAction.backgroundColor = UIColor.tradeItBuyGreenColor
        
        let sellAction = UITableViewRowAction(style: .normal, title: "SELL") { action, index in
            let position = self.positions[(index as NSIndexPath).row]
            self.delegate?.tradeButtonWasTapped(forPortFolioPosition: position, orderAction: .sell)
        }
        sellAction.backgroundColor = UIColor.tradeItSellRedColor
        
        
        return [sellAction, buyAction]
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section != 0, let nonFxPosition = self.positions[safe: indexPath.row]?.position , nonFxPosition.instrumentType() == .EQUITY_OR_ETF && self.selectedPositionIndex != indexPath.row {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // nothing to do but need to be defined to display the actions
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

        TradeItThemeConfigurator.configure(view: cell)

        if let cell = cell {
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        } else {
            assertionFailure("Failed to create portfolio position table view cell")
            return UITableViewCell()
        }
    }
}

protocol TradeItPortfolioAccountDetailsTableDelegate: class {
    func tradeButtonWasTapped(forPortFolioPosition portfolioPosition: TradeItPortfolioPosition?, orderAction: TradeItOrderAction?)
}
