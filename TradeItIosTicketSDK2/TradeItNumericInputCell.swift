import UIKit

class TradeItNumericInputCell: UITableViewCell {
    @IBOutlet weak var textField: TradeItNumberField!

    var onValueUpdated: ((_ newValue: NSDecimalNumber?) -> Void)?

    override func awakeFromNib() {
        self.textField.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }

    func configure(initialValue: NSDecimalNumber?,
                   placeholderText: String,
                   onValueUpdated: @escaping (_ newValue: NSDecimalNumber?) -> Void) {
        self.onValueUpdated = onValueUpdated
        self.textField.placeholder = placeholderText
        if let initialValue = initialValue {
            self.textField.text = "\(initialValue)"
        }
    }

    // MARK: IBActions

    @IBAction func textFieldDidChange(_ sender: TradeItNumberField) {
        let numericValue = NSDecimalNumber.init(string: sender.text)

        print("=====> textFieldValueDidChange: \(numericValue)") //AKAKTRACE

        if numericValue == NSDecimalNumber.notANumber {
            self.onValueUpdated?(nil)
        } else {
            self.onValueUpdated?(numericValue)
        }
    }
}
