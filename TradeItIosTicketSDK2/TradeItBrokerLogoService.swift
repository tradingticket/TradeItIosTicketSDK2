import UIKit

enum TradeItBrokerLogoSize: String {
    case small
    case large
}

class TradeItBrokerLogoService {
    static func setLogo(forBroker broker: TradeItBroker, onImageView imageView: UIImageView, withSize size: TradeItBrokerLogoSize) {
        guard let brokerShortName = broker.brokerShortName else { return }

        if let brokerLogoImage = TradeItSDK.brokerLogoService.getLogo(forBroker: brokerShortName) {
            imageView.image = brokerLogoImage
        } else if setRemoteLogo(forBroker: broker, onImageView: imageView, withSize: size) {
            print("TradeIt Logo: Fetching remote logo for \(brokerShortName)")
        } else {
            print("TradeIt ERROR: No broker logo provided for \(brokerShortName)")
        }
    }

    static private func setRemoteLogo(forBroker broker: TradeItBroker, onImageView imageView: UIImageView, withSize size: TradeItBrokerLogoSize) -> Bool {
        guard let logoMetadata = broker.logos as? [TradeItBrokerLogo],
            let logoData = logoMetadata.first(where: { $0.name == size.rawValue }),
            let logoUrlString = logoData.url,
            let logoUrl = URL(string: logoUrlString) else {
                return false
        }

        imageView.sd_setImage(with: logoUrl)
        imageView.sd_setIndicatorStyle(.gray)
        imageView.sd_setShowActivityIndicatorView(true)
        return true
    }
}
