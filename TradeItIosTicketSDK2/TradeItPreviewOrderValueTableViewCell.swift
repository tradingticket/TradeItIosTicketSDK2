import UIKit

class TradeItPreviewOrderValueTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
    }

    func populate(withLabel label: String, andValue value: String?) {
        self.textLabel?.text = label
        self.detailTextLabel?.text = value
    }
}
