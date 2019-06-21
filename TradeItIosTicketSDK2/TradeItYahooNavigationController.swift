import UIKit

class TradeItYahooNavigationController: UINavigationController {
    var navigationBarHeight: CGFloat {
        get {
            return self.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupFuji()
    }

    private func setupFuji() {
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = .white
        self.navigationBar.tintColor = UIColor(red: 24/255, green: 143/255, blue: 1, alpha: 1)

        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        self.navigationBar.titleTextAttributes = textAttributes
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
}
