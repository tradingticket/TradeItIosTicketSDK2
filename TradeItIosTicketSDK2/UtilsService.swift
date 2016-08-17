class UtilsService: NSObject {
    private static let formatter = NSNumberFormatter()

    static func formatCurrency(number: Float) -> String {
        formatter.numberStyle = .CurrencyStyle
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.stringFromNumber(number)!
    }
    
    static func formatQuantity(number: Float) -> String {
        formatter.numberStyle = .DecimalStyle
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.stringFromNumber(number)!
    }
    
    static func formatPercentage(number: Float) -> String {
        formatter.numberStyle = .PercentStyle
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.stringFromNumber(number/100)!
    }

}
