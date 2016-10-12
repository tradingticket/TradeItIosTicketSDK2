import UIKit

class TradeItPreviewOrderWarningTableViewCell: UITableViewCell {
    @IBOutlet weak var warning: UILabel!

    func populate(withWarning warning: String) {
        self.warning.text = warning
    }
}
