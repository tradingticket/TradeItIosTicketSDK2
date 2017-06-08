import UIKit

class TradeItNumericInputCell: UITableViewCell {
    @IBOutlet weak var textField: TradeItNumberField!

    var onValueUpdated: ((_ newValue: NSDecimalNumber?) -> Void)?

    override func awakeFromNib() {
        self.textField.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        let numberToolbar: UIToolbar = UIToolbar()
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.items=[
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: "done")
        ]
        
        numberToolbar.sizeToFit()
        
        textField.inputAccessoryView = numberToolbar
    }

    func configure(initialValue: NSDecimalNumber?,
                   placeholderText: String,
                   onValueUpdated: @escaping (_ newValue: NSDecimalNumber?) -> Void) {
        self.onValueUpdated = onValueUpdated
        self.textField.placeholder = placeholderText

        if let initialValue = initialValue {
            self.textField.text = "\(initialValue)"
        } else {
            self.textField.text = nil
        }
    }

    // MARK: IBActions

    @IBAction func textFieldDidChange(_ sender: TradeItNumberField) {
        let numericValue = NSDecimalNumber.init(string: sender.text)

        if numericValue == NSDecimalNumber.notANumber {
            self.onValueUpdated?(nil)
        } else {
            self.onValueUpdated?(numericValue)
        }
    }
    
    func done () {
        textField.resignFirstResponder()
    }
}
