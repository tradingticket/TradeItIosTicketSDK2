@objc class TradeItThemeConfigurator: NSObject {
    static let ACCESSIBILITY_IDENTIFIERS_TO_HIGHLIGHT = [
        "STOCK_SYMBOL",
        "CHEVRON_UP",
        "CHEVRON_DOWN",
        "NATIVE_ARROW",
        "SELECTED_INDICATOR"
    ]

    static let ELEMENTS_TO_SKIP = [
        "POSITION_DETAILS_VIEW"
    ]

    static let BUTTON_TEXT_TO_HIGHLIGHT = [
        "Unlink Account"
    ]

    static let ALTERNATIVE_VIEWS = [
        "PORTFOLIO_VIEW"
    ]

    static func configure(view: UIView?) {
        guard let view = view else { return }
        if self.ALTERNATIVE_VIEWS.contains(view.accessibilityIdentifier ?? "") {
            view.backgroundColor = TradeItSDK.theme.alternativeBackgroundColor
        } else {
            view.backgroundColor = TradeItSDK.theme.backgroundColor
        }
        configureTheme(view: view)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    static func configureTableHeader(header: UIView?) {
        guard let header = header else { return }
        header.backgroundColor = TradeItSDK.theme.tableHeaderBackgroundColor
        configureTableHeaderTheme(view: header)
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
        case let label as UILabel:
            if isViewToHighlight(label) {
                label.textColor = TradeItSDK.theme.interactivePrimaryColor
            } else {
                label.textColor = TradeItSDK.theme.textColor
            }
        case let tableView as UITableView:
            tableView.backgroundColor = TradeItSDK.theme.backgroundColor
        case let activityIndicator as UIActivityIndicatorView:
            activityIndicator.color = TradeItSDK.theme.interactivePrimaryColor
        case is UITableViewCell:
            break
        default:
            break
        }

        if !self.ELEMENTS_TO_SKIP.contains(view.accessibilityIdentifier ?? "") {
            view.subviews.forEach { subview in
                configureTheme(view: subview)
            }
        }
    }

    private static func styleImage(_ imageView: UIImageView) {
        if isViewToHighlight(imageView) {
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
        } else {
            button.setTitleColor(TradeItSDK.theme.interactiveSecondaryColor, for: .normal)
            button.backgroundColor = TradeItSDK.theme.interactivePrimaryColor
        }
    }

    private static func styleTextField(_ input: UITextField) {
        input.backgroundColor = UIColor.clear
        input.layer.borderColor = TradeItSDK.theme.inputFrameColor.cgColor
        input.layer.borderWidth = 1
        input.layer.cornerRadius = 4
        input.layer.masksToBounds = true
        input.textColor = TradeItSDK.theme.textColor
        input.attributedPlaceholder = NSAttributedString(
            string: input.placeholder ?? "",
            attributes: [NSForegroundColorAttributeName: TradeItSDK.theme.inputFrameColor]
        )
    }

    private static func styleSwitch(_ input: UISwitch) {
        input.tintColor = TradeItSDK.theme.interactivePrimaryColor
        input.onTintColor = TradeItSDK.theme.interactivePrimaryColor
    }

    private static func isViewToHighlight(_ view: UIView) -> Bool {
        return self.ACCESSIBILITY_IDENTIFIERS_TO_HIGHLIGHT.contains(view.accessibilityIdentifier ?? "")
    }
}
