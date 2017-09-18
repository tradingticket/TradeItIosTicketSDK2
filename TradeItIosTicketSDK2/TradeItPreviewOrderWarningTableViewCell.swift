import UIKit

class TradeItPreviewOrderWarningTableViewCell: UITableViewCell {
    @IBOutlet weak var warning: UILabel!

    override func awakeFromNib() {
        TradeItThemeConfigurator.configureWarningCell(cell: self)
    }

    func populate(withWarning warning: String) {
        self.warning.text = warning
    }
}
