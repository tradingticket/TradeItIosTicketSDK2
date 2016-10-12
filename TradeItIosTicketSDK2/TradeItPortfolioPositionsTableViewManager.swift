import UIKit

class TradeItPortfolioPositionsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {

    private var positions: [TradeItPortfolioPosition] = []
    private var _table: UITableView?
    var positionsTable: UITableView? {
        get {
            return _table
        }

        set(newTable) {
            if let newTable = newTable {
                newTable.dataSource = self
                newTable.delegate = self
                _table = newTable
            }
        }
    }
    
    private var selectedPositionIndex = -1
    
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
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            self.selectedPositionIndex = indexPath.row
            self.positions[self.selectedPositionIndex].refreshQuote(onFinished: {
                self.positionsTable?.reloadData()
                self.positionsTable?.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
            })
        }

        self.positionsTable?.beginUpdates()
        self.positionsTable?.endUpdates()
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.positions.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var cell: UITableViewCell!

        if self.positions.count > 0 {
            // TODO: Change this to make position.position and position.fxPosition optional
            if self.positions[0].position != nil {
                cell = tableView.dequeueReusableCellWithIdentifier("PORTFOLIO_EQUITY_POSITIONS_HEADER_ID")
            } else if self.positions[0].fxPosition != nil {
                cell = tableView.dequeueReusableCellWithIdentifier("PORTFOLIO_FX_POSITIONS_HEADER_ID")
            }
        }

        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        let position = self.positions[indexPath.row]

        // TODO: Change this to make position.position and position.fxPosition optional
        if position.position != nil {
            let equityCell = tableView.dequeueReusableCellWithIdentifier("PORTFOLIO_EQUITY_POSITIONS_CELL_ID") as! TradeItPortfolioEquityPositionsTableViewCell
            equityCell.populate(withPosition: position)
            cell = equityCell
        } else if position.fxPosition != nil {
            let fxCell = tableView.dequeueReusableCellWithIdentifier("PORTFOLIO_FX_POSITIONS_CELL_ID") as! TradeItPortfolioFxPositionsTableViewCell
            fxCell.populate(withPosition: position)
            cell = fxCell
        }

        if self.selectedPositionIndex == indexPath.row {
            cell.setSelected(true, animated: true)
        }

        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == self.selectedPositionIndex {
            return 150
        }

        return 50
    }
}
