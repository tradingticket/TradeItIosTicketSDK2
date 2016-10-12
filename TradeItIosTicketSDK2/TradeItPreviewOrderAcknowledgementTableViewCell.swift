import UIKit

internal protocol AcknowledgementDelegate {
    func acknowledgementWasChanged()
}

class TradeItPreviewOrderAcknowledgementTableViewCell: UITableViewCell {
    @IBOutlet weak var acknowledgementSwitch: UISwitch!
    @IBOutlet weak var acknowledgementLabel: UILabel!

    var cellData: AcknowledgementCellData?
    var delegate: AcknowledgementDelegate?

    func populate(withCellData cellData: AcknowledgementCellData, andDelegate delegate: AcknowledgementDelegate) {
        self.cellData = cellData
        self.acknowledgementLabel.text = cellData.acknowledgement
        self.delegate = delegate
    }

    @IBAction func switchChanged(sender: UISwitch) {
        cellData?.isAcknowledged = sender.on
        delegate?.acknowledgementWasChanged()
    }
}
