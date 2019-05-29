import UIKit

class TradeItNumericToggleInputCell: UITableViewCell {
    @IBOutlet weak var textField: TradeItNumberField!
    @IBOutlet weak var quantityTypeButton: UIButton!
    @IBOutlet weak var disclosureIndicatorWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var disclosureIndicator: DisclosureIndicator!
    @IBOutlet weak var toggleView: UIView!
    
    var onValueUpdated: ((_ newValue: NSDecimalNumber?) -> Void)?
    var onQuantityTypeTapped: (() -> Void)?

    override func awakeFromNib() {
        self.addDoneButtonToKeyboard()
    }

    func configure(
        onValueUpdated: @escaping (_ newValue: NSDecimalNumber?) -> Void,
        onQuantityTypeTapped: (() -> Void)? = nil
    ) {
        self.onValueUpdated = onValueUpdated
        self.onQuantityTypeTapped = onQuantityTypeTapped
        self.textField.isPrice = false
    }

    func configureQuantityType(
        label: String?,
        quantity: NSDecimalNumber?,
        maxDecimalPlaces: Int,
        showToggle: Bool = false
    ) {
        self.quantityTypeButton.setTitle(label, for: .normal)
        self.textField.text = quantity?.stringValue
        self.textField.maxDecimalPlaces = maxDecimalPlaces

        if showToggle {
            self.disclosureIndicatorWidthConstraint.constant = 15
            self.disclosureIndicator.setNeedsDisplay()
            self.quantityTypeButton.isHidden = false
            self.textField.attributedPlaceholder = NSAttributedString(
                string: "Enter",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
            )
        } else {
            self.disclosureIndicatorWidthConstraint.constant = 0
            self.quantityTypeButton.isHidden = true
            self.textField.attributedPlaceholder = NSAttributedString(
                string: "Enter \(label ?? "")",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
            )
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
            barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
            target: nil,
            action: nil
        )

        let doneBarButtonItem: UIBarButtonItem  = UIBarButtonItem(
            title: "Done",
            style: UIBarButtonItem.Style.done,
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
        let numericValue = NSDecimalNumber.init(string: sender.text, locale: Locale.current)

        if numericValue == NSDecimalNumber.notANumber {
            self.onValueUpdated?(nil)
        } else {
            self.onValueUpdated?(numericValue)
        }
    }

    @IBAction func quantityTypeTapped(_ sender: UIButton) {
        self.onQuantityTypeTapped?()
    }
}
