@objc public class TradeItYahooLauncher: NSObject {
    let viewControllerProvider = TradeItViewControllerProvider(storyboardName: "TradeItYahoo")
    var deviceManager = TradeItDeviceManager()

    override internal init() {}

    public func getOAuthConfirmationScreen(withLinkedBroker linkedBroker: TradeItLinkedBroker) -> TradeItYahooBrokerLinkedViewController? {
        let viewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.yahooBrokerLinkedView) as? TradeItYahooBrokerLinkedViewController

        viewController?.linkedBroker = linkedBroker

        return viewController
    }
}
