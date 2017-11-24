class MarginPresenter {
    public static let LABELS = [CASH_LABEL, MARGIN_LABEL]
    private static let CASH_LABEL = "Cash"
    private static let MARGIN_LABEL = "Margin"

    static func labelFor(value: Bool) -> String {
        return value ? CASH_LABEL : MARGIN_LABEL
    }

    static func valueFor(label: String) -> Bool {
        return label == CASH_LABEL
    }
}
