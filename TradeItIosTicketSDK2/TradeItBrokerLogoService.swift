import UIKit

enum TradeItBrokerLogoSize: String {
    case small
    case large
}

class TradeItBrokerLogoService {
    static func setLogo(forBroker broker: TradeItBroker, onImageView imageView: UIImageView, withSize size: TradeItBrokerLogoSize) {
        guard let logoMetadata = broker.logos as? [TradeItBrokerLogo],
            let logoData = logoMetadata.first(where: { $0.name == size.rawValue }),
            let logoUrlString = logoData.url,
            let logoUrl = URL(string: logoUrlString) else {
                return print("TradeIt ERROR: No broker logo provided for \(broker.shortName ?? "")")
        }
        print("TradeIt Logo: Fetching remote logo for \(broker.shortName ?? "")")
        imageView.sd_setImage(with: logoUrl) { _, error, _, _ in
            if (error != nil) {
                print("TradeIt Logo: Failed to download image for \(broker.shortName ?? ""). \(error?.localizedDescription ?? "")")
            }
        }
        imageView.sd_setIndicatorStyle(.gray)
        imageView.sd_setShowActivityIndicatorView(true)
    }
}
