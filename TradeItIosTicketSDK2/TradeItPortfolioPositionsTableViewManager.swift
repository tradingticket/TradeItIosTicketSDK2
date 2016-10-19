import UIKit

class TradeItPortfolioPositionsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource, TradeItPortfolioPositionsTableViewCellDelegate {

    private var positions: [TradeItPortfolioPosition] = []
    private var selectedPositionIndex = -1

    private var _table: UITableView?
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // if the user click on the already expanded row, deselect it
        if self.selectedPositionIndex == indexPath.row {
            self.selectedPositionIndex = -1
            self.reloadTableViewAtIndexPath([indexPath])
        } else if self.selectedPositionIndex != -1 {
            let prevPath = NSIndexPath(forRow: self.selectedPositionIndex, inSection: 0);
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
    
    private func reloadTableViewAtIndexPath(indexPaths: [NSIndexPath]) {
        self.positionsTable?.beginUpdates()
        self.positionsTable?.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        self.positionsTable?.endUpdates()
    }

    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.positions.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var cell: UITableViewCell?

        if self.positions.count > 0 {
            // TODO: Change this to make position.position and position.fxPosition optional
            if self.positions[0].position != nil {
                cell = tableView.dequeueReusableCellWithIdentifier("PORTFOLIO_EQUITY_POSITIONS_HEADER_ID")
            } else if self.positions[0].fxPosition != nil {
                cell = tableView.dequeueReusableCellWithIdentifier("PORTFOLIO_FX_POSITIONS_HEADER_ID")
            }
        }

        return cell?.contentView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let position = self.positions[indexPath.row]
        let cell = self.provideCell(forTableView: tableView,
                                    forPortfolioPosition: position,
                                    selected: self.selectedPositionIndex == indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let buyAction = UITableViewRowAction(style: .Normal, title: "BUY") { action, index in
            let position = self.positions[index.row]
            self.delegate?.tradeButtonWasTapped(forPortFolioPosition: position, orderAction: .Buy)
        }
        buyAction.backgroundColor = UIColor.tradeItBuyGreenColor()
        
        let sellAction = UITableViewRowAction(style: .Normal, title: "SELL") { action, index in
            let position = self.positions[index.row]
            self.delegate?.tradeButtonWasTapped(forPortFolioPosition: position, orderAction: .Sell)
        }
        sellAction.backgroundColor = UIColor.tradeItSellRedColor()
        
        
        return [sellAction, buyAction]
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let nonFxPosition = self.positions[safe: indexPath.row]?.position where nonFxPosition.instrumentType() == .EQUITY_OR_ETF && self.selectedPositionIndex != indexPath.row {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
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
            let equityCell = tableView.dequeueReusableCellWithIdentifier("PORTFOLIO_EQUITY_POSITIONS_CELL_ID") as! TradeItPortfolioEquityPositionsTableViewCell
            equityCell.delegate = self
            equityCell.populate(withPosition: position)
            equityCell.showPositionDetails(selected)
            cell = equityCell
        } else if let fxPosition = position.fxPosition {
            let fxCell = tableView.dequeueReusableCellWithIdentifier("PORTFOLIO_FX_POSITIONS_CELL_ID") as! TradeItPortfolioFxPositionsTableViewCell
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
