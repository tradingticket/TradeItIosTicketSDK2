import UIKit

class TradeItViewControllerProvider {
    var storyboardName: String = "TradeIt"

    init() {}

    init(storyboardName: String) {
        self.storyboardName = storyboardName
    }

    func provideNavigationController(withRootViewStoryboardId storyboardId: TradeItStoryboardID) -> UINavigationController {
        let storyboard = UIStoryboard(name: self.storyboardName, bundle: TradeItBundleProvider.provide())

        let navController = UINavigationController()

        let rootViewController = storyboard.instantiateViewController(withIdentifier: storyboardId.rawValue)
        navController.setViewControllers([rootViewController], animated: false)

        return navController
    }

    func provideViewController(forStoryboardId storyboardId: TradeItStoryboardID) -> UIViewController {
        let storyboard = UIStoryboard(name: self.storyboardName, bundle: TradeItBundleProvider.provide())

        return storyboard.instantiateViewController(withIdentifier: storyboardId.rawValue)
    }
}
