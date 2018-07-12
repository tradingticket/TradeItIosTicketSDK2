import UIKit

class TradeItStepperInputTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: TradeItNumberField!
    @IBOutlet weak var decrementButton: UIButton!
    @IBOutlet weak var incrementButton: UIButton!

    var onValueUpdated: ((_ newValue: NSDecimalNumber?) -> Void)?
    private var maxDecimalPlaces: Int = 4

    override func awakeFromNib() {
        self.textField.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        self.theme(button: self.decrementButton, roundingCorners: [.topLeft, .bottomLeft])
        self.theme(button: self.incrementButton, roundingCorners: [.topRight, .bottomRight])
        self.addDoneButtonToKeyboard()
    }

    func configure(
        initialValue: String?,
        placeholderText: String,
        maxDecimalPlaces: Int?,
        onValueUpdated: @escaping (_ newValue: NSDecimalNumber?) -> Void
    ) {
        self.onValueUpdated = onValueUpdated
        self.textField.placeholder = placeholderText
        self.maxDecimalPlaces = maxDecimalPlaces ?? 4
        self.textField.maxDecimalPlaces = self.maxDecimalPlaces

        if let initialValue = initialValue {
            self.textField.text = "\(initialValue)"
        } else {
            self.textField.text = nil
        }
    }

    @objc func dismissKeyboard() {
        self.textField.resignFirstResponder()
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

    @IBAction func incrementButtonTapped(_ sender: UIButton) {
        let numericValue = NSDecimalNumber.init(string: self.textField.text)

        if numericValue != NSDecimalNumber.notANumber {
            let newValue = numericValue.adding(stepSizeToChange(numericValue))
            self.textField.text = newValue.stringValue
            self.onValueUpdated?(numericValue)
        }
    }

    @IBAction func decrementButtonTapped(_ sender: UIButton) {
        let numericValue = NSDecimalNumber.init(string: self.textField.text)

        if numericValue != NSDecimalNumber.notANumber {
            let newValue = numericValue.subtracting(stepSizeToChange(numericValue))
            self.textField.text = newValue.stringValue
            self.onValueUpdated?(numericValue)
        }
    }

    // MARK: Private

    private func stepSizeToChange(_ value: NSDecimalNumber) -> NSDecimalNumber {
        let decimalPlaces16 = Int16(maxDecimalPlaces * -1)
        return NSDecimalNumber(mantissa: 1, exponent: decimalPlaces16, isNegative: false)
    }

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

        TradeItThemeConfigurator.configureBarButtonItem(button: doneBarButtonItem)

        var barButtonItems = [UIBarButtonItem]()
        barButtonItems.append(flexSpace)
        barButtonItems.append(doneBarButtonItem)

        doneToolbar.items = barButtonItems
        doneToolbar.sizeToFit()

        self.textField.inputAccessoryView = doneToolbar
    }

    private func theme(button: UIButton, roundingCorners: UIRectCorner) {
        let path = UIBezierPath(
            roundedRect: button.bounds,
            byRoundingCorners: roundingCorners,
            cornerRadii: CGSize(width: 5, height:  5)
        )

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath

        button.layer.mask = maskLayer
        button.layer.borderWidth = 1
        button.layer.borderColor = TradeItSDK.theme.interactivePrimaryColor.withAlphaComponent(0.5).cgColor
    }
}
