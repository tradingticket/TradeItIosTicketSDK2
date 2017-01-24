@objc public class TradeItYahooLauncher: NSObject {
    let viewControllerProvider = TradeItViewControllerProvider(storyboardName: "TradeItYahoo")
    var deviceManager = TradeItDeviceManager()
    let tradingUIFlow = TradeItYahooTradingUIFlow()

    override internal init() {}

    // TODO: Change get to launch using presentView
    public func getOAuthConfirmationScreen(withLinkedBroker linkedBroker: TradeItLinkedBroker) -> TradeItYahooBrokerLinkedViewController? {
        let viewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.yahooBrokerLinkedView) as? TradeItYahooBrokerLinkedViewController

        viewController?.linkedBroker = linkedBroker

        return viewController
    }

    public func launchTrading(fromViewController viewController: UIViewController, withOrder order: TradeItOrder) -> Void {
        deviceManager.authenticateUserWithTouchId(
            onSuccess: {
                print("Access granted")
                self.tradingUIFlow.presentTradingFlow(fromViewController: viewController, withOrder: order)
            },
            onFailure: {
                print("Access denied")
            }
        )
    }
}
