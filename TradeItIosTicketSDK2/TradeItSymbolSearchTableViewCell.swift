import UIKit

class TradeItSymbolSearchTableViewCell: UITableViewCell {
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!

    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
        self.symbolLabel.textColor = TradeItTheme.interactivePrimaryColor
        self.companyNameLabel.textColor = TradeItTheme.textColor
    }

    func populateWith(_ symbolResult: TradeItSymbolLookupCompany) {
        self.symbolLabel.text = symbolResult.symbol
        self.companyNameLabel.text = symbolResult.name
    }
}
