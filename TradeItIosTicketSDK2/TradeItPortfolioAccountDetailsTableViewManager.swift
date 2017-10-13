import UIKit

class TradeItPortfolioAccountDetailsTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource, TradeItPortfolioPositionsTableViewCellDelegate {
    private enum SECTIONS: Int {
        case accountDetails = 0
        case positions
        case count
    }

    private enum ACCOUNT_DETAIL_ROWS: Int {
        case totalValue = 0
        case totalReturn
        case dayReturn
        case buyingPower
        case availableCash
    }

    private let ACCOUNT_DETAIL_ROW_HEIGHT: CGFloat = 32

    private var account: TradeItLinkedBrokerAccount?
    private var accountDetails: [ACCOUNT_DETAIL_ROWS] = []
    private var positions: [TradeItPortfolioPosition]? = []

    private var selectedPositionIndex = -1
    private var refreshControl: UIRefreshControl?

    private let warningImage = UIImage(
        named: "warning",
        in: Bundle(for: TradeItPortfolioAccountDetailsTableViewManager.self),
        compatibleWith: nil
    )

    private var _table: UITableView?
    var table: UITableView? {
        get {
            return _table
        }

        set(newTable) {
            if let newTable = newTable {
                newTable.dataSource = self
                newTable.delegate = self
                addRefreshControl(toTableView: newTable)
                _table = newTable
            }
        }
    }

    weak var delegate: TradeItPortfolioAccountDetailsTableDelegate?

    init(account: TradeItLinkedBrokerAccount) {
        self.account = account
    }

    func updateAccount(withAccount account: TradeItLinkedBrokerAccount?) {
        self.account = account
        guard let account = account else { return }
        let presenter = TradeItPortfolioBalanceEquityPresenter(account)
        self.accountDetails = [.totalValue]
        if presenter.hasTotalReturn() { self.accountDetails += [.totalReturn] }
        if presenter.hasDayReturn() { self.accountDetails += [.dayReturn] }
        if presenter.hasBuyingPower() { self.accountDetails += [.buyingPower] }
        if presenter.hasAvailableCash() { self.accountDetails += [.availableCash] }
    }

    func updatePositions(withPositions positions: [TradeItPortfolioPosition]?) {
        self.selectedPositionIndex = -1
        self.positions = positions
        self.table?.reloadData()
    }

    func initiateRefresh() {
        self.refreshControl?.beginRefreshing()
        self.delegate?.refreshRequested(
            onRefreshComplete: {
                self.refreshControl?.endRefreshing()
            }
        )
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if the user click on the already expanded row, deselect it
        if self.selectedPositionIndex == indexPath.row {
            self.selectedPositionIndex = -1
            self.reloadTableViewAtIndexPath([indexPath])
        } else if self.selectedPositionIndex != -1 {
            let prevPath = IndexPath(row: self.selectedPositionIndex, section: SECTIONS.positions.rawValue)
            self.selectedPositionIndex = indexPath.row
            guard let cell = self.table?.cellForRow(at: indexPath) as? TradeItPortfolioEquityPositionsTableViewCell else {
                return
            }
            cell.showSpinner()
            self.positions?[self.selectedPositionIndex].refreshQuote(onFinished: {
                cell.hideSpinner()
                self.reloadTableViewAtIndexPath([prevPath, indexPath])
            })
        } else {
            self.selectedPositionIndex = indexPath.row
            self.reloadTableViewAtIndexPath([indexPath])
            guard let cell = self.table?.cellForRow(at: indexPath) as? TradeItPortfolioEquityPositionsTableViewCell else {
                return
            }
            cell.showSpinner()
            self.positions?[self.selectedPositionIndex].refreshQuote(onFinished: {
                cell.hideSpinner()
                self.reloadTableViewAtIndexPath([indexPath])
            })
            
        }
    }
    
    private func reloadTableViewAtIndexPath(_ indexPaths: [IndexPath]) {
        self.table?.beginUpdates()
        self.table?.reloadRows(at: indexPaths, with: .automatic)
        self.table?.endUpdates()
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return SECTIONS.count.rawValue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTIONS.accountDetails.rawValue {
            guard let account = self.account else { return 0 }
            let presenter = TradeItPortfolioBalanceEquityPresenter(account)
            return presenter.numberOfRows()
        } else {
            guard let positions = self.positions else { return 1 }
            return positions.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == SECTIONS.accountDetails.rawValue {
            return nil
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PORTFOLIO_EQUITY_POSITIONS_HEADER_ID")
            let header = cell?.contentView
            TradeItThemeConfigurator.configureTableHeader(header: header)
            return header
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == SECTIONS.accountDetails.rawValue {
            return 0.0
        } else {
            return 36.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTIONS.accountDetails.rawValue {
            guard let account = self.account,
                let accountDetail = self.accountDetails[safe: indexPath.row]
                else { return UITableViewCell() }
            let presenter = TradeItPortfolioBalanceEquityPresenter(account)

            switch accountDetail {
            case .totalValue:
                return self.totalValueCell(forTableView: tableView)
            case .totalReturn:
                return self.accountDetailCell(
                    forTableView: tableView,
                    title: "Total return",
                    value: presenter.getFormattedTotalReturnValueWithPercentage(),
                    valueColor: presenter.getTotalReturnChangeColor()
                )
            case .dayReturn:
                return self.accountDetailCell(
                    forTableView: tableView,
                    title: "Day return",
                    value: presenter.getFormattedDayReturnWithPercentage(),
                    valueColor: presenter.getDayReturnChangeColor()
                )
            case .buyingPower:
                return self.accountDetailCell(
                    forTableView: tableView,
                    title: presenter.getFormattedBuyingPowerLabel(),
                    value: presenter.getFormattedBuyingPower()
                )
            case .availableCash:
                return self.accountDetailCell(
                    forTableView: tableView,
                    title: "Available cash",
                    value: presenter.getFormattedAvailableCash()
                )
            }
        } else {
            let position = self.positions?[safe: indexPath.row]
            let cell = self.positionCell(
                forTableView: tableView,
                forPortfolioPosition: position,
                selected: self.selectedPositionIndex == indexPath.row
            )
            return cell
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let buyAction = UITableViewRowAction(style: .normal, title: "BUY") { (action, indexPath: IndexPath) in
            let position = self.positions?[safe: indexPath.row]
            self.delegate?.tradeButtonWasTapped(forPortfolioPosition: position, orderAction: .buy)
        }
        buyAction.backgroundColor = UIColor.tradeItBuyGreenColor
        
        let sellAction = UITableViewRowAction(style: .normal, title: "SELL") { (action, indexPath: IndexPath) in
            let position = self.positions?[safe: indexPath.row]
            self.delegate?.tradeButtonWasTapped(forPortfolioPosition: position, orderAction: .sell)
        }
        sellAction.backgroundColor = UIColor.tradeItSellRedColor
        
        
        return [sellAction, buyAction]
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == SECTIONS.positions.rawValue &&
            self.positions?[safe: indexPath.row]?.position?.instrumentType() == .EQUITY_OR_ETF &&
            self.selectedPositionIndex != indexPath.row
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // nothing to do but need to be defined to display the actions
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == SECTIONS.accountDetails.rawValue && indexPath.row > ACCOUNT_DETAIL_ROWS.totalValue.rawValue {
            return self.ACCOUNT_DETAIL_ROW_HEIGHT
        }
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == SECTIONS.accountDetails.rawValue && indexPath.row > ACCOUNT_DETAIL_ROWS.totalValue.rawValue {
            return self.ACCOUNT_DETAIL_ROW_HEIGHT
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: TradeItPortfolioPositionsTableViewCellDelegate
    
    func tradeButtonWasTapped(forPortFolioPosition portfolioPosition: TradeItPortfolioPosition?, orderAction: TradeItOrderAction?) {
        self.delegate?.tradeButtonWasTapped(forPortfolioPosition: portfolioPosition, orderAction: orderAction)
    }

    // MARK: Private

    private func positionCell(
        forTableView tableView: UITableView,
        forPortfolioPosition position: TradeItPortfolioPosition?,
        selected: Bool = false) -> UITableViewCell {
        if let position = position {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PORTFOLIO_EQUITY_POSITIONS_CELL_ID") as! TradeItPortfolioEquityPositionsTableViewCell
            cell.delegate = self
            cell.populate(withPosition: position)
            cell.showPositionDetails(selected)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_PORTFOLIO_ACCOUNT_DETAILS_ERROR") ?? UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = "Positions"
            cell.detailTextLabel?.text = "Positions failed to load. Swipe down to retry."
            cell.accessoryView = UIImageView(image: warningImage)
            TradeItThemeConfigurator.configure(view: cell)
            return cell
        }
    }

    private func totalValueCell(forTableView tableView: UITableView) -> UITableViewCell {
        if let account = self.account {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_PORTFOLIO_ACCOUNT_DETAILS") as! TradeItPortfolioAccountDetailsTableViewCell
            cell.populate(withAccount: account)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_PORTFOLIO_ACCOUNT_DETAILS_ERROR") ?? UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = "Overview"
            cell.detailTextLabel?.text = "Overview failed to load. Swipe down to retry."
            cell.accessoryView = UIImageView(image: warningImage)
            TradeItThemeConfigurator.configure(view: cell)
            return cell
        }
    }

    private func accountDetailCell(forTableView tableView: UITableView, title: String, value: String?, valueColor: UIColor = TradeItSDK.theme.textColor) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PORTFOLIO_VALUE_ID") ?? UITableViewCell()
        TradeItThemeConfigurator.configure(view: cell)
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = value
        cell.detailTextLabel?.textColor = valueColor
        return cell
    }

    func addRefreshControl(toTableView tableView: UITableView) {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl.addTarget(
            self,
            action: #selector(initiateRefresh),
            for: UIControlEvents.valueChanged
        )
        TradeItThemeConfigurator.configure(view: refreshControl)
        tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
    }
}

protocol TradeItPortfolioAccountDetailsTableDelegate: class {
    func tradeButtonWasTapped(forPortfolioPosition portfolioPosition: TradeItPortfolioPosition?, orderAction: TradeItOrderAction?)
    func refreshRequested(onRefreshComplete: @escaping () -> Void)
}
