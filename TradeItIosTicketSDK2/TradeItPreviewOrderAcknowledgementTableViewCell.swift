import UIKit

internal protocol AcknowledgementDelegate: class {
    func acknowledgementWasChanged()
}

class TradeItPreviewOrderAcknowledgementTableViewCell: UITableViewCell {
    @IBOutlet weak var acknowledgementSwitch: UISwitch!
    @IBOutlet weak var acknowledgementLabel: UILabel!

    var cellData: AcknowledgementCellData?
    internal weak var delegate: AcknowledgementDelegate?

    override func awakeFromNib() {
        TradeItThemeConfigurator.configure(view: self)
        self.acknowledgementLabel.textColor = TradeItTheme.warningTextColor
    }

    func populate(withCellData cellData: AcknowledgementCellData, andDelegate delegate: AcknowledgementDelegate) {
        self.cellData = cellData
        self.acknowledgementLabel.text = cellData.acknowledgement
        self.delegate = delegate
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        cellData?.isAcknowledged = sender.isOn
        delegate?.acknowledgementWasChanged()
    }
}
