import UIKit

class TradeItSelectionCellTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryView = DisclosureIndicator()
    }

    func configure(selection: String, onTapped: () -> Void) {
        self.detailTextLabel?.text = selection
    }
}
