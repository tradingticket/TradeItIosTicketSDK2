import PromiseKit

class TradeItBrokerService {
    private let connector: TradeItConnector
    private var brokersPromise: Promise<([TradeItBroker], TradeItBrokerListResult)>? = nil

    init(connector: TradeItConnector) {
        self.connector = connector
    }

    func getAvailableBrokersPromise() -> Promise<([TradeItBroker], TradeItBrokerListResult)> {
        //        TODO: Add locking in case this gets called multiple times
        //        let lockQueue = DispatchQueue(label: "getAvailableBrokersPromiseLock")
        //        lockQueue.sync() { CODE GOES HERE }
        if let brokersPromise = self.brokersPromise {
            return brokersPromise
        } else {
            let brokersPromise = Promise<([TradeItBroker], TradeItBrokerListResult)> { fulfill, reject in
                getAvailableBrokers(
                    userCountryCode: TradeItSDK.userCountryCode,
                    onSuccess: { (availableBrokers: [TradeItBroker], result: TradeItBrokerListResult) -> Void in
                        fulfill(availableBrokers, result)
                    }, onFailure: { error in
                        self.brokersPromise = nil
                        reject(error)
                    }
                )
            }

            self.brokersPromise = brokersPromise
            return brokersPromise
        }
    }

    private func getAvailableBrokers(
        userCountryCode: String?,
        onSuccess: @escaping ([TradeItBroker], TradeItBrokerListResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) {
        let data = TradeItBrokerListRequest(apiKey: self.connector.apiKey, userCountryCode: userCountryCode)

        let request = TradeItRequestFactory.buildJsonRequest(
            for: data,
            emsAction: "preference/getBrokerList?fidelityPilot=true",
            environment: self.connector.environment
        )

        self.connector.send(request, targetClassType: TradeItBrokerListResult.self) { result in
            if let result = result as? TradeItBrokerListResult,
                let brokerList = result.brokerList as? [TradeItBroker] {
                onSuccess(brokerList, result)
            } else if let error = result as? TradeItErrorResult {
                onFailure(error)
            } else {
                onFailure(TradeItErrorResult(
                    title: "Available brokers failure",
                    message: "Could not fetch the list of available brokers. Please try again later."
                ))
            }
        }
    }
}
