class NumberFormatter: NSObject {
    private let formatter = NSNumberFormatter()

    func formatCurrency(number: NSNumber) -> String {
        formatter.numberStyle = .CurrencyStyle
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.stringFromNumber(number)!
    }
    
    func formatCurrency(number: NSNumber, currencyCode: String) -> String {
        formatter.numberStyle = .CurrencyStyle
        formatter.currencyCode = currencyCode
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.stringFromNumber(number)!
    }
    
    func formatQuantity(number: Float) -> String {
        formatter.numberStyle = .DecimalStyle
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.stringFromNumber(number)!
    }
    
    func formatPercentage(number: NSNumber) -> String {
        formatter.numberStyle = .PercentStyle
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.stringFromNumber((number as Float)/100)!
    }

}
