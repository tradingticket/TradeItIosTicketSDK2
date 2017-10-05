import UIKit
import BEMCheckBox

class TradeItPreviewMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var checkbox: BEMCheckBox!
    @IBOutlet weak var message: UILabel!

    var cellData: MessageCellData?

    override func awakeFromNib() {
        TradeItThemeConfigurator.configureWarningCell(cell: self)
    }

    func populate(withCellData cellData: MessageCellData) {
        self.cellData = cellData
        self.message.text = cellData.message.message
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        cellData?.isAcknowledged = sender.isOn
    }
}
