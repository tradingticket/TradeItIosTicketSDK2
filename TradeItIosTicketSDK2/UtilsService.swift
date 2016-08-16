class UtilsService: NSObject {
    
    static func formatCurrency(number: Float) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        return formatter.stringFromNumber(number)!
    }

}
