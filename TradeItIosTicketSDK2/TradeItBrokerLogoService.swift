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
        TradeItSDK.uiConfigService.getUiConfig(onSuccess: { uiConfig in
            guard let brokerId = broker.shortName,
                let brokerConfigs = uiConfig.brokers as? [TradeItUiBrokerConfig],
                let brokerConfig = brokerConfigs.first(where: { $0.brokerId == brokerId }),
                let logoMetaData = brokerConfig.logos as? [TradeItBrokerLogo],
                let logoData = logoMetaData.first(where: { $0.name == size.rawValue }),
                let logoUrlString = logoData.url,
                let logoUrl = URL(string: logoUrlString)
                else {
                    return print("TradeIt Logo: No broker logo provided for \(broker.shortName ?? "")")
                }
            
            if let cachedImage = self.getCachedLogo(brokerId: brokerId, size: size) {
                print("TradeIt Logo: Fetching cached logo for \(brokerId)")
                return onSuccess(cachedImage)
            }
            print("TradeIt Logo: Fetching remote logo for \(brokerId)")
            
            DispatchQueue.global(qos: .userInitiated).async {
                guard let imageData = NSData(contentsOf: logoUrl),
                    let image = UIImage(data: imageData as Data) else {
                        print("TradeIt Logo: Broker logo failed to load. \(logoUrl)")
                        DispatchQueue.main.async(execute: onFailure)
                        return
                }
                
                DispatchQueue.main.async {
                    self.setCachedLogo(brokerId: brokerId, size: size, image: image)
                    onSuccess(image)
                }
            }
        }, onFailure: { _ in
            onFailure()
        })
        

    }

    func clearCache() {
        self.cache = [:]
    }

    private func getCachedLogo(brokerId: String, size: TradeItBrokerLogoSize) -> UIImage? {
        return cache[brokerId]?[size]
    }

    private func setCachedLogo(brokerId: String, size: TradeItBrokerLogoSize, image: UIImage) {
        cache[brokerId] = cache[brokerId] ?? [:]
        cache[brokerId]?[size] = image
    }
}
