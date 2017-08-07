import UIKit

class TradeItPreviewOrderValueTableViewCell: UITableViewCell {
    func populate(withLabel label: String, andValue value: String) {
        self.textLabel?.text = label
        self.detailTextLabel?.text = value
    }
}
