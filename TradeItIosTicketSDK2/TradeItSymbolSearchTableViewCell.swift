import UIKit

class TradeItSymbolSearchTableViewCell: UITableViewCell {
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!

    override func awakeFromNib() {
        self.symbolLabel.textColor = UIButton().tintColor
    }

    func populateWith(_ symbolResult: TradeItSymbolLookupCompany) {
        self.symbolLabel.text = symbolResult.symbol
        self.companyNameLabel.text = symbolResult.name
    }
}
