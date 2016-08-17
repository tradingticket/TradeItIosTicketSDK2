class UtilsService: NSObject {
    private static let formatter = NSNumberFormatter()

    static func formatCurrency(number: Float) -> String {
        formatter.numberStyle = .CurrencyStyle
        return formatter.stringFromNumber(number)!
    }

}
