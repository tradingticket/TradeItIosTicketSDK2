import UIKit

@objc class TradeItViewControllerProvider: NSObject {
    func provideNavigationController(withRootViewStoryboardId storyboardId: TradeItStoryboardID) -> UINavigationController {
        let storyboard = UIStoryboard(name: "TradeIt", bundle: TradeItBundleProvider.provide())

        let navController = UINavigationController()

        let rootViewController = storyboard.instantiateViewControllerWithIdentifier(storyboardId.rawValue)
        navController.setViewControllers([rootViewController], animated: false)

        return navController
    }

    func provideViewController(forStoryboardId storyboardId: TradeItStoryboardID) -> UIViewController {
        let storyboard = UIStoryboard(name: "TradeIt", bundle: TradeItBundleProvider.provide())

        return storyboard.instantiateViewControllerWithIdentifier(storyboardId.rawValue)
    }
}
