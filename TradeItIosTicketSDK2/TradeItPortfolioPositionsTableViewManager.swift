import UIKit

class TradeItPortfolioPositionsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    let PORTFOLIO_POSITIONS_HEADER_ID = "PORTFOLIO_POSITIONS_HEADER_ID"
    let PORTFOLIO_POSITIONS_CELL_ID = "PORTFOLIO_POSITIONS_CELL_ID"

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
        let cell = tableView.dequeueReusableCellWithIdentifier(PORTFOLIO_POSITIONS_HEADER_ID) as! TradeItPortfolioPositionsTableViewHeader
        cell.updateColumns(self.positions)

        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PORTFOLIO_POSITIONS_CELL_ID) as! TradeItPortfolioPositionsTableViewCell
        
        let position = self.positions[indexPath.row]
        cell.populate(withPosition: position)

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
