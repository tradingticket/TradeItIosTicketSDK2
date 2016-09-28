import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func clearUserDefaults() {
        let appDomain = NSBundle.mainBundle().bundleIdentifier;
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!);
    }
}

