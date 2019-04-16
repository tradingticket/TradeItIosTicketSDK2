import UIKit

class TradeItPreviewMessage: Codable {
    var message: String?
    var requiresAcknowledgement: Bool
    var links: [TradeItPreviewMessageLink]
}
