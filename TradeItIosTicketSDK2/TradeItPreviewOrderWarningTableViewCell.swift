import UIKit

class TradeItPreviewOrderWarningTableViewCell: UITableViewCell {
    @IBOutlet weak var warning: UILabel!

    override func awakeFromNib() {
        TradeItThemeConfigurator.configureTableCell(cell: self)
        self.warning.textColor = TradeItTheme.warningTextColor
    }

    func populate(withWarning warning: String) {
        self.warning.text = warning
    }
}
