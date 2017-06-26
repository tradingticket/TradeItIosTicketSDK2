import UIKit

@objc class TradeItThemeConfigurator: NSObject {
    static let BUTTON_TEXT_TO_HIGHLIGHT = [
        "Unlink Account"
    ]

    static let SQUARE_TEXT_FIELD_IDENTIFIERS = [
        "Stepper"
    ]

    static func configure(view: UIView?) {
        guard let view = view else { return }
        view.backgroundColor = TradeItSDK.theme.backgroundColor
        configureTheme(view: view)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    static func configureTableHeader(header: UIView?) {
        guard let header = header else { return }
        header.backgroundColor = TradeItSDK.theme.tableHeaderBackgroundColor
        configureTableHeaderTheme(view: header)
    }

    static func configureBarButtonItem(button: UIBarButtonItem?) {
        guard let button = button else { return }
        button.tintColor = TradeItSDK.theme.interactivePrimaryColor
    }

    private static func configureTableHeaderTheme(view: UIView) {
        switch view {
        case let label as UILabel:
            label.textColor = TradeItSDK.theme.tableHeaderTextColor
        default:
            break
        }

        view.subviews.forEach { subview in
            configureTableHeaderTheme(view: subview)
        }
    }

    private static func configureTheme(view: UIView) {
        switch view {
        case let button as UIButton: styleButton(button)
        case let input as UITextField: styleTextField(input)
        case let input as UISwitch: styleSwitch(input)
        case let imageView as UIImageView: styleImage(imageView)
        case let label as UILabel: styleLabel(label)
        case let tableView as UITableView: styleTableView(tableView)
        case let cell as UITableViewCell: styleTableViewCell(cell)
        case let refreshControl as UIRefreshControl:
            refreshControl.tintColor = TradeItSDK.theme.interactivePrimaryColor
            refreshControl.backgroundColor = UIColor.clear
        case let activityIndicator as UIActivityIndicatorView:
            activityIndicator.color = TradeItSDK.theme.interactivePrimaryColor
        default:
            if check(view: view, hasTrait: UIAccessibilityTraitSelected) {
                view.backgroundColor = TradeItSDK.theme.tableBackgroundSecondaryColor
            }
            break
        }

        view.subviews.forEach { subview in
            configureTheme(view: subview)
        }
    }

    private static func styleImage(_ imageView: UIImageView) {
        if imageView.superview is UIButton || imageView.accessibilityIdentifier == "LOGO" {
            // Do nothing
        } else {
            let image = imageView.image?.withRenderingMode(.alwaysTemplate)
            imageView.image = image
            imageView.tintColor = TradeItSDK.theme.interactivePrimaryColor
        }
    }

    private static func styleButton(_ button: UIButton) {
        if button.backgroundColor == UIColor.clear {
            button.setTitleColor(TradeItSDK.theme.interactivePrimaryColor, for: .normal)
        } else if self.BUTTON_TEXT_TO_HIGHLIGHT.contains(button.title(for: .normal) ?? "") {
            button.setTitleColor(TradeItSDK.theme.warningSecondaryColor, for: .normal)
            button.backgroundColor = TradeItSDK.theme.warningPrimaryColor
        } else if button.currentTitle == nil && button.superview is UITableViewCell {
            button.tintColor = TradeItSDK.theme.interactivePrimaryColor
        } else if button.accessibilityIdentifier == "BUY_BUTTON" {
            button.backgroundColor = UIColor.tradeItBuyGreenColor
            button.setTitleColor(UIColor.white, for: .normal)
        } else if button.accessibilityIdentifier == "SELL_BUTTON" {
            button.backgroundColor = UIColor.tradeItSellRedColor
            button.setTitleColor(UIColor.white, for: .normal)
        } else {
            button.setTitleColor(TradeItSDK.theme.interactiveSecondaryColor, for: .normal)
            button.setTitleColor(TradeItSDK.theme.interactiveSecondaryColor, for: .selected)
            button.backgroundColor = TradeItSDK.theme.interactivePrimaryColor
        }
    }

    private static func styleTextField(_ input: UITextField) {
        input.backgroundColor = TradeItSDK.theme.interactivePrimaryColor.withAlphaComponent(0.1)
        input.layer.borderColor = TradeItSDK.theme.interactivePrimaryColor.withAlphaComponent(0.2).cgColor
        input.layer.borderWidth = 1

        if !self.SQUARE_TEXT_FIELD_IDENTIFIERS.contains(input.accessibilityIdentifier ?? "") {
            input.layer.cornerRadius = 4
            input.layer.masksToBounds = true
        }

        input.textColor = TradeItSDK.theme.textColor
        input.attributedPlaceholder = NSAttributedString(
            string: input.placeholder ?? "",
            attributes: [NSForegroundColorAttributeName: TradeItSDK.theme.interactivePrimaryColor.withAlphaComponent(0.8)]
        )
        input.setNeedsLayout()
        input.layoutIfNeeded()
    }

    private static func styleSwitch(_ input: UISwitch) {
        input.tintColor = TradeItSDK.theme.interactivePrimaryColor
        input.onTintColor = TradeItSDK.theme.interactiveSecondaryColor
    }

    private static func styleTableView(_ tableView: UITableView) {
        if tableView.style == .grouped {
            tableView.superview?.backgroundColor = TradeItSDK.theme.tableHeaderBackgroundColor
            tableView.backgroundColor = TradeItSDK.theme.tableHeaderBackgroundColor
        } else {
            tableView.superview?.backgroundColor = TradeItSDK.theme.tableBackgroundPrimaryColor
            tableView.backgroundColor = TradeItSDK.theme.tableBackgroundPrimaryColor
        }
        tableView.separatorColor = TradeItSDK.theme.tableHeaderBackgroundColor
    }

    private static func styleTableViewCell(_ cell: UITableViewCell) {
        let view = UIView()
        view.backgroundColor = TradeItSDK.theme.interactivePrimaryColor.withAlphaComponent(0.3)
        cell.selectedBackgroundView = view
    }

    private static func styleLabel(_ label: UILabel) {
        if check(view: label, hasTrait: UIAccessibilityTraitButton) {
            label.textColor = TradeItSDK.theme.interactivePrimaryColor
        } else if check(view: label, hasTrait: UIAccessibilityTraitHeader) {
            label.textColor = TradeItSDK.theme.textColor.withAlphaComponent(0.6)
        } else {
            label.textColor = TradeItSDK.theme.textColor
        }
    }

    private static func check(view: UIView, hasTrait trait: UIAccessibilityTraits) -> Bool {
        return view.accessibilityTraits & trait != 0
    }
}
