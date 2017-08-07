import UIKit

class TradeItPreviewOrderWarningTableViewCell: UITableViewCell {
    @IBOutlet weak var warning: UILabel!

    override func awakeFromNib() {
        self.warning.textColor = UIColor.tradeItDeepRoseColor
    }

    func populate(withWarning warning: String) {
        self.warning.text = warning
    }
}
