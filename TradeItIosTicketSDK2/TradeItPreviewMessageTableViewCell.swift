import UIKit
import BEMCheckBox

internal protocol PreviewMessageDelegate: class {
    func acknowledgementWasChanged()
}

class TradeItPreviewMessageTableViewCell: UITableViewCell, BEMCheckBoxDelegate {
    @IBOutlet weak var message: UILabel!

    var cellData: MessageCellData?
    var checkbox: BEMCheckBox?
    internal weak var delegate: PreviewMessageDelegate?

    override func awakeFromNib() {
        TradeItThemeConfigurator.configureWarningCell(cell: self)
    }

    func populate(withCellData cellData: MessageCellData, andDelegate delegate: PreviewMessageDelegate) {
        self.cellData = cellData
        self.message.text = cellData.message.message
        if cellData.message.requiresAcknowledgement {
            self.checkbox = BEMCheckBox(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            self.checkbox?.delegate = self
        } else {
            self.checkbox = nil
        }
        self.accessoryView = self.checkbox
        self.delegate = delegate
    }

    func didTap(_ checkBox: BEMCheckBox) {
        self.cellData?.isAcknowledged = checkBox.on
        self.delegate?.acknowledgementWasChanged()
    }
}
