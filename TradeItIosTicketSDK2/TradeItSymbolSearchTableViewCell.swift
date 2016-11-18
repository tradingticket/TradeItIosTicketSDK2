import UIKit

class TradeItSymbolSearchTableViewCell: UITableViewCell {
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!

    override func awakeFromNib() {
        self.symbolLabel.textColor = TradeItTheme.interactiveElementColor
        self.companyNameLabel.textColor = TradeItTheme.textColor
    }

    func populateWith(_ symbolResult: TradeItSymbolLookupCompany) {
        self.symbolLabel.text = symbolResult.symbol
        self.companyNameLabel.text = symbolResult.name
    }
}
