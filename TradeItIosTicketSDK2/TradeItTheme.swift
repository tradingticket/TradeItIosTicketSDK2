import UIKit

@objc public class TradeItTheme: NSObject {
    static public var textColor = UIColor.white
    static public var warningTextColor = UIColor.tradeItDeepRoseColor()

    static public var backgroundColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1.0)

    static public var tableBackgroundColor = UIColor(red: 0.36, green: 0.36, blue: 0.36, alpha: 1.0)
    static public var tableBackgroundSecondaryColor = UIColor(red: 0.66, green: 0.66, blue: 0.66, alpha: 1.0)
    static public var tableHeaderBackgroundColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
    static public var tableHeaderTextColor = UIColor.white

    static public var interactivePrimaryColor = UIColor(red: 1.00, green: 0.57, blue: 0.00, alpha: 1.0)
    static public var interactiveSecondaryColor = backgroundColor

    static public var warningPrimaryColor = UIColor.tradeItDeepRoseColor()
    static public var warningSecondaryColor = UIColor.white

    static public var inputFrameColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.0)
}


@objc class TradeItThemeConfigurator: NSObject {
    static let ACCESSIBILITY_IDENTIFIERS_TO_HIGHLIGHT = [
        "STOCK_SYMBOL",
        "CHEVRON_UP",
        "CHEVRON_DOWN",
        "NATIVE_ARROW",
        "SELECTED_INDICATOR"
    ]

    static let CELL_ELEMENTS_TO_SKIP = [
        "POSITION_DETAILS_VIEW"
    ]

    static let BUTTON_TEXT_TO_HIGHLIGHT = [
        "Unlink Account"
    ]

    static func configure(view: UIView?) {
        guard let view = view else { return }
        view.backgroundColor = TradeItTheme.backgroundColor
        configureTheme(view: view)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    static func configureTableHeader(header: UIView?) {
        guard let header = header else { return }
        configureTableHeaderTheme(view: header)
    }

    static func configureTableCell(cell: UITableViewCell?) {
        guard let cell = cell else { return }
        cell.backgroundColor = TradeItTheme.tableBackgroundColor
        configureTableCellTheme(view: cell)
    }

    private static func configureTableHeaderTheme(view: UIView) {
        switch view {
        case let label as UILabel:
            label.textColor = TradeItTheme.tableHeaderTextColor
        default:
            view.backgroundColor = TradeItTheme.tableHeaderBackgroundColor
        }

        view.subviews.forEach { subview in
            configureTableHeaderTheme(view: subview)
        }
    }

    private static func configureTableCellTheme(view: UIView) {
        switch view {
        case let label as UILabel:
            if isViewToHighlight(label) {
                label.textColor = TradeItTheme.interactivePrimaryColor
            } else {
                label.textColor = TradeItTheme.tableHeaderTextColor
            }
        case let button as UIButton:
            styleButton(button)
        case let imageView as UIImageView:
            styleImage(imageView)
        case let input as UISwitch:
            styleSwitch(input)
        default:
            break
        }

        if !self.CELL_ELEMENTS_TO_SKIP.contains(view.accessibilityIdentifier ?? "") {
            view.subviews.forEach { subview in
                configureTableCellTheme(view: subview)
            }
        }
    }

    private static func configureTheme(view: UIView) {
        switch view {
        case let label as UILabel:
            label.textColor = TradeItTheme.textColor
        case let button as UIButton:
            styleButton(button)
        case let input as UITextField:
            input.backgroundColor = UIColor.clear
            input.layer.borderColor = TradeItTheme.inputFrameColor.cgColor
            input.layer.borderWidth = 1
            input.layer.cornerRadius = 4
            input.layer.masksToBounds = true
            input.textColor = TradeItTheme.textColor
            input.attributedPlaceholder = NSAttributedString(
                string: input.placeholder ?? "",
                attributes: [NSForegroundColorAttributeName: TradeItTheme.inputFrameColor]
            )
        case let input as UISwitch:
            styleSwitch(input)
        case let imageView as UIImageView:
            styleImage(imageView)
        case let tableView as UITableView:
            tableView.backgroundColor = TradeItTheme.tableBackgroundColor
        case let activityIndicator as UIActivityIndicatorView:
            activityIndicator.color = TradeItTheme.interactivePrimaryColor
        case is UITableViewCell:
            break
        default:
            break
        }

        view.subviews.forEach { subview in
            configureTheme(view: subview)
        }
    }

    private static func styleImage(_ imageView: UIImageView) {
        if isViewToHighlight(imageView) {
            let image = imageView.image?.withRenderingMode(.alwaysTemplate)
            imageView.image = image
            imageView.tintColor = TradeItTheme.interactivePrimaryColor
        }
    }

    private static func styleButton(_ button: UIButton) {
        if button.backgroundColor == UIColor.clear {
            button.setTitleColor(TradeItTheme.interactivePrimaryColor, for: .normal)
        } else if self.BUTTON_TEXT_TO_HIGHLIGHT.contains(button.title(for: .normal) ?? "") {
            button.setTitleColor(TradeItTheme.warningSecondaryColor, for: .normal)
            button.backgroundColor = TradeItTheme.warningPrimaryColor
        } else {
            button.setTitleColor(TradeItTheme.interactiveSecondaryColor, for: .normal)
            button.backgroundColor = TradeItTheme.interactivePrimaryColor
        }
    }

    private static func styleSwitch(_ input: UISwitch) {
        input.tintColor = TradeItTheme.interactivePrimaryColor
        input.onTintColor = TradeItTheme.interactivePrimaryColor
    }

    private static func isViewToHighlight(_ view: UIView) -> Bool {
        return self.ACCESSIBILITY_IDENTIFIERS_TO_HIGHLIGHT.contains(view.accessibilityIdentifier ?? "")
    }
}
