import UIKit

class CloseableViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationItem()
    }

    func configureNavigationItem() {
        guard let viewControllers = self.navigationController?.viewControllers else {
            self.createCloseButton()
            return
        }

        if viewControllers.count == 1 {
            self.createCloseButton()
        }

        TradeItThemeConfigurator.configureBarButtonItem(button: self.navigationItem.leftBarButtonItem)
    }

    func createCloseButton() {
        if self.navigationItem.leftBarButtonItem == nil {
            let closeButtonItem = UIBarButtonItem(title: closeButtonTitle(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(closeButtonWasTapped(_:)))
            self.navigationItem.leftBarButtonItem = closeButtonItem
        }
    }
    
    func closeButtonTitle() -> String {
        return "Close"
    }

    func closeButtonWasTapped(_ sender: UIBarButtonItem) {
        if let viewControllers = self.navigationController?.viewControllers , viewControllers.count > 1 {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
