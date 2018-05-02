import UIKit

class TradeItSymbolSearchTableViewCell: UITableViewCell {
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!

    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
        self.symbolLabel.textColor = TradeItSDK.theme.interactivePrimaryColor
        self.companyNameLabel.textColor = TradeItSDK.theme.textColor
    }

    func populateWith(_ symbolResult: TradeItSymbol) {
        self.symbolLabel.text = symbolResult.symbol
        self.companyNameLabel.text = symbolResult.name
    }
}
