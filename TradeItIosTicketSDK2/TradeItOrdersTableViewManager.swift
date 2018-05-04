import UIKit

class TradeItOrdersTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var noResultsBackgroundView: UIView
    private var _table: UITableView?
    private var refreshControl: UIRefreshControl?
    private let linkedBrokerAccount: TradeItLinkedBrokerAccount
    
    private static let SECTION_HEADER_HEIGHT = CGFloat(40)
    private static let GROUP_ORDER_HEADER_HEIGHT = CGFloat(30)

    var ordersTable: UITableView? {
        get {
            return _table
        }
        
        set(newTable) {
            if let newTable = newTable {
                newTable.dataSource = self
                newTable.delegate = self
                newTable.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: newTable.bounds.size.width, height: 16))
                addRefreshControl(toTableView: newTable)
                _table = newTable
            }
        }
    }
    
    private var orderSectionPresenters: [OrderSectionPresenter] = []
    
    weak var delegate: TradeItOrdersTableDelegate?
    
    init(noResultsBackgroundView: UIView, linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.noResultsBackgroundView = noResultsBackgroundView
        self.linkedBrokerAccount = linkedBrokerAccount
    }
    
    func initiateRefresh() {
        self.refreshControl?.beginRefreshing()
        self.delegate?.refreshRequested(
            onRefreshComplete: {
                self.refreshControl?.endRefreshing()
            }
        )
    }
    
    func updateOrders(_ orders: [TradeItOrderStatusDetails]) {
        self.orderSectionPresenters = []
        
        let openOrders = orders.filter { $0.belongsToOpenCategory()}
        if !openOrders.isEmpty {
            let openOrdersPresenter = getOrdersPresenter(orders: openOrders)
            self.orderSectionPresenters.append(
                OrderSectionPresenter(
                    ordersPresenter: openOrdersPresenter,
                    title: "Open Orders",
                    titleDate: "(Past 60 days)",
                    isCancelable: true
                )
            )
        }
        
        let partiallyFilledOrders = orders.filter { $0.belongsToPartiallyFilledCategory() }
        if !partiallyFilledOrders.isEmpty {
            let partiallyFilledOrdersPresenter = getOrdersPresenter(orders: partiallyFilledOrders)
            self.orderSectionPresenters.append(
                OrderSectionPresenter(
                    ordersPresenter: partiallyFilledOrdersPresenter,
                    title: "Partially Filled Orders",
                    titleDate: "(Today)",
                    isCancelable: true
                )
            )
        }
        
        let filledOrders = orders.filter { $0.belongsToFilledCategory() }
        if !filledOrders.isEmpty {
            let filledOrdersPresenter = getOrdersPresenter(orders: filledOrders)
            self.orderSectionPresenters.append(
                OrderSectionPresenter(
                    ordersPresenter: filledOrdersPresenter,
                    title: "Filled Orders",
                    titleDate: "(Today)"
                )
            )
        }

        let otherOrders = orders.filter { $0.belongsToOtherCategory() }
        if !otherOrders.isEmpty {
            let otherOrdersPresenter = getOrdersPresenter(orders: otherOrders)
            self.orderSectionPresenters.append(
                OrderSectionPresenter(
                    ordersPresenter: otherOrdersPresenter,
                    title: "Other Orders",
                    titleDate: "(Today)"
                )
            )
        }
        
        self.ordersTable?.backgroundView = self.orderSectionPresenters.isEmpty ? noResultsBackgroundView : nil
        self.ordersTable?.reloadData()
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getOrderSectionPresenter(forSection: section)?.title
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if Section(rawValue: section) == Section.accountInfo {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BRANDED_ACCOUNT_NAME_CELL_ID") as? TradeItPreviewBrandedAccountNameCell else {
                return UITableViewCell()
            }
            cell.populate(linkedBroker: linkedBrokerAccount)
            cell.backgroundColor = nil

            return cell
        }

        return getOrderSectionPresenter(forSection: section)?.header(forTableView: tableView)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if Section(rawValue: indexPath.section) == Section.accountInfo {
            return UITableViewCell()
        } else {
            return getOrderSectionPresenter(forSection: indexPath.section)?.cell(forTableView: tableView, andRow: indexPath.row) ?? UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Section(rawValue: section) == Section.accountInfo {
            return 0
        }

        guard let orderSectionPresenter = getOrderSectionPresenter(forSection: section) else { return 0 }
        return orderSectionPresenter.numberOfRows()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.orderSectionPresenters.isEmpty {
            return 0
        }

        return self.orderSectionPresenters.count + 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let orderPresenter = getOrderSectionPresenter(forSection: indexPath.section)?.ordersPresenter[safe: indexPath.row]
            , !orderPresenter.isGroupOrderHeader else {
            return TradeItOrdersTableViewManager.GROUP_ORDER_HEADER_HEIGHT
        }
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let orderPresenter = getOrderSectionPresenter(forSection: indexPath.section)?.ordersPresenter[safe: indexPath.row]
            , !orderPresenter.isGroupOrderHeader else {
                return TradeItOrdersTableViewManager.GROUP_ORDER_HEADER_HEIGHT
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TradeItOrdersTableViewManager.SECTION_HEADER_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let cancelAction = UITableViewRowAction(style: .normal, title: "Cancel") { (action, indexPath: IndexPath) in
            guard let orderPresenter = self.getOrderSectionPresenter(forSection: indexPath.section)?.ordersPresenter[safe: indexPath.row]
                , let ordernumber = orderPresenter.getOrderNumber() else {
                    return
            }
            self.delegate?.cancelActionWasTapped(
                forOrderNumber: ordernumber,
                title: orderPresenter.getCancelOrderPopupTitle(),
                message: orderPresenter.getCancelOrderPopupMessage())
        }
        cancelAction.backgroundColor = UIColor.tradeItCancelRoseColor
        return [cancelAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let orderPresenter = getOrderSectionPresenter(forSection: indexPath.section)?.ordersPresenter[safe: indexPath.row] else {
            return false
        }
        return orderPresenter.isCancelable()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // nothing to do but need to be defined to display the actions
    }

    // MARK: Private
    fileprivate enum Section: Int {
        case accountInfo = 0, firstOrderCategory
    }

    private func getOrderSectionPresenter(forSection section: Int) -> OrderSectionPresenter? {
        let indexOfOrderCategory = section - Section.firstOrderCategory.rawValue

        return orderSectionPresenters[safe: indexOfOrderCategory]
    }
    
    private func addRefreshControl(toTableView tableView: UITableView) {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl.addTarget(
            self,
            action: #selector(initiateRefresh),
            for: UIControlEvents.valueChanged
        )
        tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
    }
    
    /**
     * Buidling an array of  TradeItOrderStatusDetailsPresenter in order to add a row for group order header
    **/
    private func getOrdersPresenter(orders: [TradeItOrderStatusDetails], isGroupOrderChild: Bool = false) -> [TradeItOrderStatusDetailsPresenter] {
        var ordersPresenterInSection: [TradeItOrderStatusDetailsPresenter] = []
        orders.forEach { order in
            if let groupOrders = order.groupOrders, order.isGroupOrder() {
                ordersPresenterInSection.append(
                    TradeItOrderStatusDetailsPresenter(
                        orderStatusDetails: order,
                        orderLeg: nil,
                        isGroupOrderHeader: true
                    )
                )
                ordersPresenterInSection.append(contentsOf: getOrdersPresenter(orders: groupOrders, isGroupOrderChild: true))
            } else {
                if let orderLegs = order.orderLegs {
                    ordersPresenterInSection.append(contentsOf:
                        orderLegs.map { orderLeg in
                            return TradeItOrderStatusDetailsPresenter(
                                orderStatusDetails: order,
                                orderLeg: orderLeg,
                                isGroupOrderHeader: false,
                                isGroupOrderChild: isGroupOrderChild
                            )
                    })
                }
            }
        }
        return ordersPresenterInSection
    }
}

fileprivate class OrderSectionPresenter {
    
    let ordersPresenter: [TradeItOrderStatusDetailsPresenter]
    var title: String
    var titleDate: String
    var isCancelable: Bool = false
    
    init(ordersPresenter: [TradeItOrderStatusDetailsPresenter], title: String, titleDate: String = "", isCancelable: Bool = false) {
        self.ordersPresenter = ordersPresenter
        self.title = title
        self.titleDate = titleDate
        self.isCancelable = isCancelable
    }
    
    func numberOfRows() -> Int {
        return self.ordersPresenter.count
    }
    
    func cell(forTableView tableView: UITableView, andRow row: Int) -> UITableViewCell {
        guard let orderPresenter = self.ordersPresenter[safe: row] else {
            return UITableViewCell()
        }
        if orderPresenter.isGroupOrderHeader {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_GROUP_ORDER_HEADER_CELL_ID") as? TradeItGroupOrderHeaderTableViewCell else {
                return UITableViewCell()
            }
            cell.populate(withOrderStatusDetailsPresenter: orderPresenter)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_ORDER_CELL_ID") as? TradeItOrderTableViewCell else {
                return UITableViewCell()
            }
            cell.populate(withOrderStatusDetailsPresenter: orderPresenter)
            return cell
        }
    }
    
    func header(forTableView tableView: UITableView) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_ORDER_HEADER_ID") as? TradeItOrderTableViewHeader else {
            return  UITableViewHeaderFooterView()
        }
        cell.populate(title: self.title, titleDate: self.titleDate, isCancelable: self.isCancelable)
        let header = cell.contentView
        return header
    }
}


protocol TradeItOrdersTableDelegate: class {
    func refreshRequested(onRefreshComplete: @escaping () -> Void)
    func cancelActionWasTapped(forOrderNumber orderNumber: String, title: String, message: String)
}
