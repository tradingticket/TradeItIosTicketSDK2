import UIKit

class TradeItPortfolioPositionsTableViewHeader: UITableViewCell {
    @IBOutlet weak var column1NameLabel: UILabel!
    @IBOutlet weak var column2NameLabel: UILabel!
    
    func updateColumns(positions: [TradeItPortfolioPosition]) {
        if positions.count > 0 && positions[0].fxPosition != nil {
            column1NameLabel.text = "Avg. Rate"
            column2NameLabel.text = "Unrealized P/L"
        }
    }

}
