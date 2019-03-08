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
        self.navigationBar.barStyle = .black
        self.navigationBar.tintColor = .white
        let blankImage = UIImage()
        self.navigationBar.setBackgroundImage(blankImage, for: .default)
        self.navigationBar.shadowImage = blankImage

        let gradientView = TopGradientView(frame: self.view.frame)
        addNavigationGradientView(gradientView)

        let colorGradientView = LinearGradientView()
        addNavigationGradientView(colorGradientView)
    }
    
    private func addNavigationGradientView(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(subview)
        self.view.sendSubviewToBack(subview)
        self.view.addConstraints([
            subview.topAnchor.constraint(equalTo: self.view.topAnchor),
            subview.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            subview.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            subview.heightAnchor.constraint(equalToConstant: self.navigationBarHeight)
        ])
    }
}
