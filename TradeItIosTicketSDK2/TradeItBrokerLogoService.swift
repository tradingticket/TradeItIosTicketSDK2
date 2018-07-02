import UIKit
import PromiseKit

enum TradeItBrokerLogoSize: String {
    case small
    case large
}

class TradeItBrokerLogoService {
    private var cache: [String: [TradeItBrokerLogoSize: UIImage]] = [:]

    func loadLogo(
        forBrokerId brokerIdOptional: String?,
        withSize size: TradeItBrokerLogoSize,
        onSuccess: @escaping (UIImage) -> Void,
        onFailure: @escaping () -> Void
    ) {
        TradeItSDK.uiConfigService.getUiConfigPromise().then { uiConfig -> Promise<UIImage> in
            guard let brokerId = brokerIdOptional,
                let brokerConfigs = uiConfig.brokers as? [TradeItUiBrokerConfig],
                let brokerConfig = brokerConfigs.first(where: { $0.brokerId == brokerId }),
                let logoMetaData = brokerConfig.logos as? [TradeItBrokerLogo],
                let logoData = logoMetaData.first(where: { $0.name == size.rawValue }),
                let logoUrlString = logoData.url,
                let logoUrl = URL(string: logoUrlString)
                else {
                    print("TradeIt Logo: No broker logo provided for \(brokerIdOptional ?? "")")
                    return Promise(
                        error: TradeItErrorResult(
                            title: "Logo not found",
                            message: "No logo is enabled for this broker."
                        )
                    )
                }
            
            if let cachedImage = self.getCachedLogo(brokerId: brokerId, size: size) {
                print("TradeIt Logo: Fetching cached logo for \(brokerId)")
                return Promise.value(cachedImage)
            }
            
            print("TradeIt Logo: Fetching remote logo for \(brokerId)")
            return Promise<UIImage> { seal in
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let imageData = NSData(contentsOf: logoUrl),
                        let image = UIImage(data: imageData as Data)
                        else {
                            seal.reject(
                                TradeItErrorResult(
                                    title: "Failed to load logo",
                                    message: "The request to load the broker logo failedg."
                                )
                            )
                            return
                        }
                    
                    DispatchQueue.main.async {
                        self.setCachedLogo(brokerId: brokerId, size: size, image: image)
                        seal.fulfill(image)
                    }
                }
            }
        }.done { image in
            onSuccess(image)
        }.catch { error in
            print(error)
            onFailure()
        }
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
