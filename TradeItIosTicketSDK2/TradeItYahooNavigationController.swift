import UIKit

class TradeItYahooNavigationController: UINavigationController {
    static let NAVIGATION_BAR_HEIGHT: CGFloat = 64.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barStyle = .black
        self.navigationBar.tintColor = .white
        let blankImage = UIImage()
        self.navigationBar.setBackgroundImage(blankImage, for: .default)
        self.navigationBar.shadowImage = blankImage

        let gradientView = YFTopGradientView(frame: self.view.frame)
        addNavigationGradientView(gradientView)

        let colorGradientView = YFLinearGradientView()
        addNavigationGradientView(colorGradientView)
    }

    private func addNavigationGradientView(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(subview)
        self.view.sendSubview(toBack: subview)
        self.view.addConstraints([
            subview.topAnchor.constraint(equalTo: self.view.topAnchor),
            subview.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            subview.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            subview.heightAnchor.constraint(equalToConstant: TradeItYahooNavigationController.NAVIGATION_BAR_HEIGHT)
        ])
    }
}
