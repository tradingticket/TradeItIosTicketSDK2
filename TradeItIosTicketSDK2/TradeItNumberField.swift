import UIKit

class TradeItNumberField: TradeItPaddedTextField, UITextFieldDelegate {
    static let invalidCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ",.")).inverted
    static let disabledActions = [
        #selector(copy(_:)),
        #selector(paste(_:)),
        #selector(select(_:)),
        #selector(selectAll(_:)),
        #selector(cut(_:))
    ]

    public var maxDecimalPlaces = 4
    public var isPrice = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }

    // MARK: UITextField

    override public func canPerformAction(
        _ action: Selector,
        withSender sender: Any?
    ) -> Bool {
        if TradeItNumberField.disabledActions.contains(action) {
            return false
        }

        return super.canPerformAction(action, withSender: sender)
    }

    // MARK: UITextFieldDelegate

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string == "" { return true }

        let currentText: NSString = textField.text as NSString? ?? ""
        let resultText = currentText.replacingCharacters(in: range, with: string)
        let components = resultText.components(separatedBy: CharacterSet(charactersIn: ",."))
        let numericValue = NSDecimalNumber.init(string: resultText)

        // Has at most one decimal point
        guard components.count <= 2 else { return false }

        // Has only valid characters
        let numericCharacters: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", ","]
        guard Set(resultText.characters).isSubset(of: numericCharacters) else { return false }

        let decimalPlaces = (components.count > 1) ?
            components.last?.lengthOfBytes(using: .utf8) ?? 0 :
            0

        var calculatedMaxDecimalPlaces = self.maxDecimalPlaces

        if (self.isPrice
            && numericValue != NSDecimalNumber.notANumber
            && numericValue.doubleValue >= 1
        ) {
            calculatedMaxDecimalPlaces = 2
        }

        // Doesn't have too many decimal places
        guard decimalPlaces <= calculatedMaxDecimalPlaces else { return false }

        return true
    }
}
