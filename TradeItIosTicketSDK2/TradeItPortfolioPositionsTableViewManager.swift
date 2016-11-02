import UIKit

class TradeItPortfolioPositionsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource, TradeItPortfolioPositionsTableViewCellDelegate {

    fileprivate var positions: [TradeItPortfolioPosition] = []
    fileprivate var selectedPositionIndex = -1

    fileprivate var _table: UITableView?
    var positionsTable: UITableView? {
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

    weak var delegate: TradeItPortfolioPositionsTableDelegate?
    
    func updatePositions(withPositions positions: [TradeItPortfolioPosition]) {
        self.selectedPositionIndex = -1
        self.positions = positions
        self.positionsTable?.reloadData()
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
    
    fileprivate func reloadTableViewAtIndexPath(_ indexPaths: [IndexPath]) {
        self.positionsTable?.beginUpdates()
        self.positionsTable?.reloadRows(at: indexPaths, with: .automatic)
        self.positionsTable?.endUpdates()
        self.positionsTable?.selectRow(at: indexPaths.last, animated: true, scrollPosition: .top)
    }

    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.positions.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var cell: UITableViewCell?

        if self.positions.count > 0 {
            if self.positions[0].position != nil {
                cell = tableView.dequeueReusableCell(withIdentifier: "PORTFOLIO_EQUITY_POSITIONS_HEADER_ID")
            } else if self.positions[0].fxPosition != nil {
                cell = tableView.dequeueReusableCell(withIdentifier: "PORTFOLIO_FX_POSITIONS_HEADER_ID")
            }
        }

        return cell?.contentView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let position = self.positions[indexPath.row]
        let cell = self.provideCell(forTableView: tableView,
                                    forPortfolioPosition: position,
                                    selected: self.selectedPositionIndex == indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let buyAction = UITableViewRowAction(style: .normal, title: "BUY") { action, index in
            let position = self.positions[(index as NSIndexPath).row]
            self.delegate?.tradeButtonWasTapped(forPortFolioPosition: position, orderAction: .buy)
        }
        buyAction.backgroundColor = UIColor.tradeItBuyGreenColor()
        
        let sellAction = UITableViewRowAction(style: .normal, title: "SELL") { action, index in
            let position = self.positions[(index as NSIndexPath).row]
            self.delegate?.tradeButtonWasTapped(forPortFolioPosition: position, orderAction: .sell)
        }
        sellAction.backgroundColor = UIColor.tradeItSellRedColor()
        
        
        return [sellAction, buyAction]
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let nonFxPosition = self.positions[safe: indexPath.row]?.position , nonFxPosition.instrumentType() == .EQUITY_OR_ETF && self.selectedPositionIndex != indexPath.row {
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

    func provideCell(forTableView tableView: UITableView,
                     forPortfolioPosition position: TradeItPortfolioPosition,
                     selected: Bool = false) -> UITableViewCell {
        var cell: UITableViewCell?

        if let nonFxPosition = position.position {
            let equityCell = tableView.dequeueReusableCell(withIdentifier: "PORTFOLIO_EQUITY_POSITIONS_CELL_ID") as! TradeItPortfolioEquityPositionsTableViewCell
            equityCell.delegate = self
            equityCell.populate(withPosition: position)
            equityCell.showPositionDetails(selected)
            cell = equityCell
        } else if let fxPosition = position.fxPosition {
            let fxCell = tableView.dequeueReusableCell(withIdentifier: "PORTFOLIO_FX_POSITIONS_CELL_ID") as! TradeItPortfolioFxPositionsTableViewCell
            fxCell.populate(withPosition: position)
            fxCell.showPositionDetails(selected)
            cell = fxCell
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
}

protocol TradeItPortfolioPositionsTableDelegate: class {
    func tradeButtonWasTapped(forPortFolioPosition portfolioPosition: TradeItPortfolioPosition?, orderAction: TradeItOrderAction?)

}
