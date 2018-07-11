internal class ValueCellData: PreviewCellData {
    let label: String
    let value: String?

    init(label: String, value: String?) {
        self.label = label
        self.value = value
    }
}
