import UIKit

class TradeItNumericToggleInputCell: UITableViewCell {
    @IBOutlet weak var textField: TradeItNumberField!
    @IBOutlet weak var quantityTypeButton: UIButton!
    @IBOutlet weak var disclosureIndicatorWidthConstraint: NSLayoutConstraint!

    var onValueUpdated: ((_ newValue: NSDecimalNumber?) -> Void)?
    var onQuantityTypeToggled: (() -> Void)?

    override func awakeFromNib() {
        self.addDoneButtonToKeyboard()
    }

    func configure(
        onValueUpdated: @escaping (_ newValue: NSDecimalNumber?) -> Void,
        onQuantityTypeToggled: (() -> Void)? = nil
    ) {
        self.onValueUpdated = onValueUpdated
        self.onQuantityTypeToggled = onQuantityTypeToggled
        self.textField.isPrice = false
    }

    func configureQuantityType(
        quantitySymbol: String?,
        quantity: NSDecimalNumber?,
        maxDecimalPlaces: Int,
        showToggle: Bool = false
    ) {
        self.textField.placeholder = "Enter"
        self.quantityTypeButton.setTitle(quantitySymbol, for: .normal)
        self.textField.text = quantity?.stringValue
        self.textField.maxDecimalPlaces = maxDecimalPlaces
        self.onValueUpdated?(quantity)
        if showToggle {
            self.disclosureIndicatorWidthConstraint.constant = 15
        } else {
            self.disclosureIndicatorWidthConstraint.constant = 0
        }
    }

    @objc func dismissKeyboard() {
        self.textField.resignFirstResponder()
    }

    // MARK: Private

    private func addDoneButtonToKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default

        let flexSpace = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
            target: nil,
            action: nil
        )

        let doneBarButtonItem: UIBarButtonItem  = UIBarButtonItem(
            title: "Done",
            style: UIBarButtonItemStyle.done,
            target: self,
            action: #selector(self.dismissKeyboard)
        )

        var barButtonItems = [UIBarButtonItem]()
        barButtonItems.append(flexSpace)
        barButtonItems.append(doneBarButtonItem)

        doneToolbar.items = barButtonItems
        doneToolbar.sizeToFit()

        self.textField.inputAccessoryView = doneToolbar
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

    @IBAction func quantityTypeToggled(_ sender: UIButton) {
        self.onQuantityTypeToggled?()
    }
}
