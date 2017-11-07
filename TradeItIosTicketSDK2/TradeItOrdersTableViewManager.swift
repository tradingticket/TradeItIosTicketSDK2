import UIKit

class TradeItOrdersTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var noResultsBackgroundView: UIView
    private var _table: UITableView?
    private var refreshControl: UIRefreshControl?
    
    private static let ORDER_CELL_HEIGHT = CGFloat(50)
    private static let SECTION_HEADER_HEIGHT = CGFloat(30)
    
    var ordersTable: UITableView? {
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
    
    private var orderSectionPresenters: [OrderSectionPresenter] = []
    
    weak var delegate: TradeItOrdersTableDelegate?
    
    init(noResultsBackgroundView: UIView) {
        self.noResultsBackgroundView = noResultsBackgroundView
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
        if openOrders.count > 0 {
            let openOrdersPresenter = getOrdersPresenter(orders: openOrders)
            self.orderSectionPresenters.append(
                OrderSectionPresenter(
                    ordersPresenter: openOrdersPresenter,
                    title: "Open Orders (Past 60 Days)",
                    isCancelable: true
                )
            )
        }
        
        let partiallyFilledOrders = orders.filter { $0.belongsToPartiallyFilledCategory() }
        if partiallyFilledOrders.count > 0 {
            let partiallyFilledOrdersPresenter = getOrdersPresenter(orders: partiallyFilledOrders)
            self.orderSectionPresenters.append(
                OrderSectionPresenter(
                    ordersPresenter: partiallyFilledOrdersPresenter,
                    title: "Partially Filled Orders (Today)",
                    isCancelable: true
                )
            )
        }
        
        let filledOrders = orders.filter { $0.belongsToFilledCategory() }
        if filledOrders.count > 0 {
            let filledOrdersPresenter = getOrdersPresenter(orders: filledOrders)
            self.orderSectionPresenters.append(
                OrderSectionPresenter(
                    ordersPresenter: filledOrdersPresenter,
                    title: "Filled Orders (Today)"
                )
            )
        }

        let otherOrders = orders.filter { $0.belongsToOtherCategory() }
        if otherOrders.count > 0 {
            let otherOrdersPresenter = getOrdersPresenter(orders: otherOrders)
            self.orderSectionPresenters.append(
                OrderSectionPresenter(
                    ordersPresenter: otherOrdersPresenter,
                    title: "Other Orders (Today)"
                )
            )
        }
        
        self.ordersTable?.backgroundView = self.orderSectionPresenters.isEmpty ? noResultsBackgroundView : nil
        self.ordersTable?.reloadData()
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.orderSectionPresenters[safe: section]?.title
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.orderSectionPresenters[safe: section]?.header(forTableView: tableView)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.orderSectionPresenters[safe: indexPath.section]?.cell(forTableView: tableView, andRow: indexPath.row) ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let orderSectionPresenter = self.orderSectionPresenters[safe: section] else { return 0 }
        return orderSectionPresenter.numberOfRows()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.orderSectionPresenters.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let orderPresenter = self.orderSectionPresenters[safe: indexPath.section]?.ordersPresenter[safe: indexPath.row]
            , !orderPresenter.isGroupOrderHeader else {
            return TradeItOrdersTableViewManager.SECTION_HEADER_HEIGHT
        }
        return TradeItOrdersTableViewManager.ORDER_CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let orderPresenter = self.orderSectionPresenters[safe: indexPath.section]?.ordersPresenter[safe: indexPath.row]
            , !orderPresenter.isGroupOrderHeader else {
                return TradeItOrdersTableViewManager.SECTION_HEADER_HEIGHT
        }
        return TradeItOrdersTableViewManager.ORDER_CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TradeItOrdersTableViewManager.SECTION_HEADER_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let cancelAction = UITableViewRowAction(style: .normal, title: "Cancel") { (action, indexPath: IndexPath) in
            guard let orderPresenter = self.orderSectionPresenters[safe: indexPath.section]?.ordersPresenter[safe: indexPath.row]
                , let ordernumber = orderPresenter.getOrderNumber() else {
                    return
            }
            var message = "Please confirm you are canceling this order."
            if orderPresenter.isGroupOrderHeader {
                message = "All orders in this group will be canceled."
            }
            self.delegate?.cancelActionWasTapped(forOrderNumber: ordernumber, message: message)
        }
        cancelAction.backgroundColor = UIColor.red
        return [cancelAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let orderPresenter = self.orderSectionPresenters[safe: indexPath.section]?.ordersPresenter[safe: indexPath.row] else {
            return false
        }
        return orderPresenter.isCancelable()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // nothing to do but need to be defined to display the actions
    }
    
    // MARK: Private
    
    private func addRefreshControl(toTableView tableView: UITableView) {
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
    var isCancelable: Bool = false
    
    init(ordersPresenter: [TradeItOrderStatusDetailsPresenter], title: String, isCancelable: Bool = false) {
        self.ordersPresenter = ordersPresenter
        self.title = title
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
            let cell = UITableViewCell()
            cell.textLabel?.text = orderPresenter.getGroupOrderHeaderTitle()
            TradeItThemeConfigurator.configureTableHeader(header: cell.contentView, groupedStyle: false)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TRADE_IT_ORDER_HEADER_ID") else {
            return  UITableViewCell()
        }
        let header = cell.contentView
        cell.textLabel?.text = self.title
        TradeItThemeConfigurator.configureTableHeader(header: header)
        if self.isCancelable {
            cell.detailTextLabel?.text = "Swipe to cancel"
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 9)
        } else {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
}


protocol TradeItOrdersTableDelegate: class {
    func refreshRequested(onRefreshComplete: @escaping () -> Void)
    func cancelActionWasTapped(forOrderNumber orderNumber:String, message:String)
}
