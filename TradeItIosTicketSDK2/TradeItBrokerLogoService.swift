import UIKit

enum TradeItBrokerLogoSize: String {
    case small
    case large
}

class TradeItBrokerLogoService {
    private var cache: [String: [TradeItBrokerLogoSize: UIImage]] = [:]

    func loadLogo(
        forBroker broker: TradeItBroker,
        withSize size: TradeItBrokerLogoSize,
        onSuccess: @escaping (UIImage) -> Void,
        onFailure: @escaping () -> Void
    ) {
        guard let brokerName = broker.shortName,
            let logoMetadata = broker.logos as? [TradeItBrokerLogo],
            let logoData = logoMetadata.first(where: { $0.name == size.rawValue }),
            let logoUrlString = logoData.url,
            let logoUrl = URL(string: logoUrlString) else {
                return print("TradeIt Logo: No broker logo provided for \(broker.shortName ?? "")")
        }

        if let cachedImage = getCachedLogo(brokerName: brokerName, size: size) {
            print("TradeIt Logo: Fetching cached logo for \(brokerName)")
            return onSuccess(cachedImage)
        }

        print("TradeIt Logo: Fetching remote logo for \(brokerName)")

        DispatchQueue.global(qos: .userInitiated).async {
            guard let imageData = NSData(contentsOf: logoUrl),
                let image = UIImage(data: imageData as Data) else {
                print("TradeIt Logo: Broker logo failed to load. \(logoUrl)")
                DispatchQueue.main.async(execute: onFailure)
                return
            }

            DispatchQueue.main.async {
                self.setCachedLogo(brokerName: brokerName, size: size, image: image)
                onSuccess(image)
            }
        }
    }

    func clearCache() {
        self.cache = [:]
    }

    private func getCachedLogo(brokerName: String, size: TradeItBrokerLogoSize) -> UIImage? {
        return cache[brokerName]?[size]
    }

    private func setCachedLogo(brokerName: String, size: TradeItBrokerLogoSize, image: UIImage) {
        cache[brokerName] = cache[brokerName] ?? [:]
        cache[brokerName]?[size] = image
    }
}
