class DateTimeFormatter: NSObject {
    private static let formatter = DateFormatter()

    static func time(_ datetime: Date = Date(), format: String = "hh:mma zzz") -> String {
        formatter.dateFormat = format
        return formatter.string(from: datetime)
    }
    
    static func getDateFromString(_ string:String, format:String = "dd/MM/yy h:mm a z")-> Date? {
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
}
