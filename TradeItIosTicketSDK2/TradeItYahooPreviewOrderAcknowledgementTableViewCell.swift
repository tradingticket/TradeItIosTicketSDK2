import UIKit
import BEMCheckBox

class TradeItYahooPreviewOrderAcknowledgementTableViewCell: UITableViewCell {

    @IBOutlet weak var acknowledgmentCheckbox: BEMCheckBox!
    @IBOutlet weak var acknowledgementLabel: UILabel!
    
    var cellData: PreviewCellData?//AcknowledgementCellData?
//    internal weak var delegate: AcknowledgementDelegate?

//    func populate(withCellData cellData: AcknowledgementCellData, andDelegate delegate: AcknowledgementDelegate) {
//        self.cellData = cellData
//        self.acknowledgementLabel.text = cellData.acknowledgement
//        self.delegate = delegate
//    }
    
    @IBAction func didCheckboxValueChanged(_ sender: BEMCheckBox) {
//        cellData?.isAcknowledged = sender.on
//        delegate?.acknowledgementWasChanged()
    }
}
