import UIKit

class TradeItViewController: CloseableViewController {

    public var enableThemeOnLoad: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        if enableThemeOnLoad {
            TradeItThemeConfigurator.configure(view: self.view)
        }
    }
    
    func enableCustomNavController() {
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        let navigationBarHeight = navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
        self.view.backgroundColor = .clear
        // Add a white background behind everything below the navigation bar.
        // The clear background above would show previous VCs when transitions are happening otherwise.
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(containerView)
        self.view.sendSubview(toBack: containerView)
        self.view.addConstraints([
            containerView.heightAnchor.constraint(equalToConstant: self.view.frame.height - navigationBarHeight),
            containerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}
