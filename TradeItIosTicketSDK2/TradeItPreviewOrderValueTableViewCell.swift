import UIKit

class TradeItPreviewOrderValueTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var value: UILabel!

    override func awakeFromNib() {
        self.label.textColor = TradeItTheme.textColor
        self.value.textColor = TradeItTheme.textColor
    }

    func populate(withLabel label: String, andValue value: String) {
        self.label.text = label
        self.value.text = value
    }
}
