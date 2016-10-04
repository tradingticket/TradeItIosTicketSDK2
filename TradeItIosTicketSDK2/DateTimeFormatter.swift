class DateTimeFormatter: NSObject {
    private static let formatter = NSDateFormatter()

    static func time(datetime: NSDate = NSDate()) -> String {
        formatter.dateFormat = "hh:mma zzz"
        return formatter.stringFromDate(datetime)
    }
}
