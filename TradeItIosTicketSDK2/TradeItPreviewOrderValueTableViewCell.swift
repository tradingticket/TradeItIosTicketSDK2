import UIKit

class TradeItPreviewOrderValueTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var value: UILabel!

    override func awakeFromNib() {
        TradeItThemeConfigurator.configureTableCell(cell: self)
    }

    func populate(withLabel label: String, andValue value: String) {
        self.label.text = label
        self.value.text = value
    }
}
