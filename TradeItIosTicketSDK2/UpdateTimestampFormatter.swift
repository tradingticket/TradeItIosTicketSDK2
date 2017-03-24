class UpdateTimestampFormatter {
    private static let _formatter = DateFormatter()

    private static var dateFormatter: DateFormatter {
        self._formatter.dateFormat = "MM/dd/yyyy"
        return self._formatter
    }

    private static var timeFormatter: DateFormatter {
        self._formatter.dateFormat = "HH:mm:ss"
        return self._formatter
    }

    static func displayString(forUpdateTimestamp timestamp: Date) -> String {
        if NSCalendar.current.isDateInToday(timestamp) {
            return timeFormatter.string(from: timestamp)
        } else {
            return dateFormatter.string(from: timestamp)
        }
    }
}
