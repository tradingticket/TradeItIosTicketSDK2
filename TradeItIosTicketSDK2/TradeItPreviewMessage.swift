import UIKit

class TradeItPreviewMessage: Codable {
    var message: String?
    var requiresAcknowledgment: Bool
    var links: [TradeItPreviewMessageLink]
}
