import UIKit
import BEMCheckBox

internal protocol PreviewMessageDelegate: class {
    func acknowledgementWasChanged()
}

class TradeItPreviewMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var checkbox: BEMCheckBox!
    @IBOutlet weak var message: UILabel!

    var cellData: MessageCellData?
    internal weak var delegate: PreviewMessageDelegate?

    override func awakeFromNib() {
        TradeItThemeConfigurator.configureWarningCell(cell: self)
    }

    func populate(withCellData cellData: MessageCellData, andDelegate delegate: PreviewMessageDelegate) {
        self.cellData = cellData
        self.message.text = cellData.message.message
        if cellData.message.requiresAcknowledgement {
            showCheckbox()
        } else {
            hideCheckbox()
        }
        self.delegate = delegate
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }

    @IBAction func checkboxChanged(_ sender: BEMCheckBox) {
        self.cellData?.isAcknowledged = sender.on
        self.delegate?.acknowledgementWasChanged()
    }

    private func showCheckbox() {
        self.checkbox.isHidden = false
        self.message.leadingAnchor.constraint(equalTo: self.checkbox.layoutMarginsGuide.trailingAnchor).isActive = true
    }

    private func hideCheckbox() {
        self.checkbox.isHidden = true
        self.message.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor).isActive = true
    }
}
