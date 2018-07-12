internal class MessageCellData: PreviewCellData {
    let message: TradeItPreviewMessage
    var isAcknowledged = false

    init(message: TradeItPreviewMessage) {
        self.message = message
    }

    func isValid() -> Bool {
        return !message.requiresAcknowledgement || isAcknowledged
    }
}
