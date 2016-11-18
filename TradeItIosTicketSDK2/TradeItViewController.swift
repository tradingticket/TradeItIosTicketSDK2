import UIKit

class TradeItViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        self.configureTheme(targetView: self.view)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    func configureNavigationItem() {
        guard let viewControllers = self.navigationController?.viewControllers else {
            self.createCloseButton()
            return
        }
        
        if viewControllers.count == 1 {
            self.createCloseButton()
        }
    }
    
    func createCloseButton() {
        let closeButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(closeButtonWasTapped(_:)))
        
        self.navigationItem.rightBarButtonItem = closeButtonItem
    }
    
    func closeButtonWasTapped(_ sender: UIBarButtonItem) {
        if let viewControllers = self.navigationController?.viewControllers , viewControllers.count > 1 {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }


    let TEMPLATE_ACCESSIBILITY_IDENTIFIERS = [
        "chevron_up",
        "chevron_down",
        "native_arrow"
    ]

    func configureTheme(targetView: UIView) {
        targetView.backgroundColor = TradeItTheme.backgroundColor
        targetView.subviews.forEach({ subview in
            switch subview {
            case let label as UILabel:
                label.textColor = TradeItTheme.textColor
            case let button as UIButton:
                if button.backgroundColor == UIColor.clear {
                    button.setTitleColor(TradeItTheme.interactiveElementColor, for: .normal)
                } else {
                    button.setTitleColor(TradeItTheme.interactiveTextColor, for: .normal)
                    button.backgroundColor = TradeItTheme.interactiveElementColor
                }
            case let input as UITextField:
                input.backgroundColor = UIColor.clear
                input.layer.borderColor = TradeItTheme.textColor.cgColor
                input.layer.borderWidth = 1
                input.layer.cornerRadius = 4
                input.layer.masksToBounds = true
                input.textColor = TradeItTheme.textColor
                input.attributedPlaceholder = NSAttributedString(
                    string: input.placeholder ?? "",
                    attributes: [NSForegroundColorAttributeName: TradeItTheme.inputPlaceholderColor]
                )
            case let input as UISwitch:
                input.tintColor = TradeItTheme.interactiveElementColor
                input.onTintColor = TradeItTheme.interactiveElementColor
            case let imageView as UIImageView:
                if isTemplateImage(imageView: imageView) {
                    let image = imageView.image?.withRenderingMode(.alwaysTemplate)
                    imageView.image = image
                    imageView.tintColor = TradeItTheme.interactiveElementColor
                }
            default:
                configureTheme(targetView: subview)
            }
        })
    }

    private func isTemplateImage(imageView: UIImageView) -> Bool {
        return self.TEMPLATE_ACCESSIBILITY_IDENTIFIERS.contains(imageView.accessibilityIdentifier ?? "")
    }
}
