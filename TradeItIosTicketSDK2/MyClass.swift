import UIKit

@objc public class MyClass: NSObject {
    public static func doSomething() {
        print("=====> DOIN' SOMETHING!")

        let connector = TradeItConnector.init(apiKey: "tradeit-test-api-key")
        connector.environment = TradeItEmsTestEnv

        connector.getAvailableBrokersWithCompletionBlock { (availableBrokers: [AnyObject]!) in
            for broker in availableBrokers {
                if let name = broker["longName"] as? String {
                    print("=====> \(name)")
                }
            }
        }
    }
}
