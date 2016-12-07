import UIKit
import MBProgressHUD

class TradeItTradingTicketViewController: TradeItViewController, TradeItSymbolSearchViewControllerDelegate, TradeItAccountSelectionViewControllerDelegate {
    @IBOutlet weak var symbolView: TradeItSymbolView!
    @IBOutlet weak var tradingBrokerAccountView: TradeItTradingBrokerAccountView!
    @IBOutlet weak var orderActionButton: UIButton!
    @IBOutlet weak var orderTypeButton: UIButton!
    @IBOutlet weak var orderExpirationButton: UIButton!
    @IBOutlet weak var orderSharesInput: UITextField!
    @IBOutlet weak var orderTypeInput1: UITextField!
    @IBOutlet weak var orderTypeInput2: UITextField!
    @IBOutlet weak var estimatedChangeLabel: UILabel!
    @IBOutlet weak var previewOrderButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    static let BOTTOM_CONSTRAINT_CONSTANT = CGFloat(20)

    var alertManager = TradeItAlertManager()
    weak var delegate: TradeItTradingTicketViewControllerDelegate?
    
    var viewControllerProvider = TradeItViewControllerProvider()
    var marketDataService = TradeItLauncher.marketDataService
    var order = TradeItOrder()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let linkedBrokerAccount = self.order.linkedBrokerAccount else {
            assertionFailure("TradeItIosTicketSDK ERROR: TradeItTradingTicketViewController loaded without setting linkedBrokerAccount on order.")
            return
        }
        
        orderActionSelected(orderAction: TradeItOrderActionPresenter.labelFor(order.action))
        orderTypeSelected(orderType: TradeItOrderPriceTypePresenter.labelFor(order.type))
        orderExpirationSelected(orderExpiration: TradeItOrderExpirationPresenter.labelFor(order.expiration))

        linkedBrokerAccount.linkedBroker.authenticateIfNeeded(onSuccess: {
            linkedBrokerAccount.getAccountOverview(onSuccess: {
                self.updateSymbolView()
                self.updateTradingBrokerAccountView()
            }, onFailure: { errorResult in
                print(errorResult)
            })
        }, onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelQuestion in
            self.alertManager.promptUserToAnswerSecurityQuestion(
                securityQuestion,
                onViewController: self,
                onAnswerSecurityQuestion: answerSecurityQuestion,
                onCancelSecurityQuestion: cancelQuestion
            )
        }, onFailure: { errorResult in
            print(errorResult)
        })

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
        registerTextFieldNotifications()
    
        guard let linkedBroker = self.order.linkedBrokerAccount?.linkedBroker, linkedBroker.isStillLinked() else {
            self.presentAccountSelectionScreen()
            return
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Text field change handlers

    func textFieldDidChange(_ textField: UITextField) {
        // TODO: Should probably check the order price type instead of placeholder text to determine which value changed
        if textField.placeholder == "Limit Price" {
            order.limitPrice = NSDecimalNumber(string: textField.text)
        } else if textField.placeholder == "Stop Price" {
            order.stopPrice = NSDecimalNumber(string: textField.text)
        } else if textField.placeholder == "Shares" {
            order.quantity = NSDecimalNumber(string: textField.text)
            updateEstimatedChangedLabel()
        }
        updatePreviewOrderButtonStatus()
    }

    // MARK: IBActions

    @IBAction func orderActionTapped(_ sender: UIButton) {
        presentOptions(
            title: "Order Action",
            options: TradeItOrderActionPresenter.labels(),
            sender: sender,
            handler: self.orderActionSelected
        )
    }

    @IBAction func orderTypeTapped(_ sender: UIButton) {
        presentOptions(
            title: "Order Type",
            options: TradeItOrderPriceTypePresenter.labels(),
            sender: sender,
            handler: self.orderTypeSelected
        )
    }

    @IBAction func orderExpirationTapped(_ sender: UIButton) {
        presentOptions(
            title: "Order Expiration",
            options: TradeItOrderExpirationPresenter.labels(),
            sender: sender,
            handler: self.orderExpirationSelected
        )
    }

    @IBAction func previewOrderTapped(_ sender: UIButton) {
        guard let linkedBroker = self.order.linkedBrokerAccount?.linkedBroker
            else { return }

        let activityView = MBProgressHUD.showAdded(to: self.view, animated: true)
        activityView.label.text = "Authenticating"

        linkedBroker.authenticateIfNeeded(
            onSuccess: {
                activityView.label.text = "Previewing Order"
                self.order.preview(onSuccess: { previewOrderResult, placeOrderCallback in
                    activityView.hide(animated: true)
                    self.delegate?.orderSuccessfullyPreviewed(onTradingTicketViewController: self,
                                                              withPreviewOrderResult: previewOrderResult,
                                                              placeOrderCallback: placeOrderCallback)
                }, onFailure: { error in
                    activityView.hide(animated: true)
                    self.alertManager.showRelinkError(
                        error,
                        withLinkedBroker: linkedBroker,
                        onViewController: self,
                        onFinished: {} // TODO: Retry?
                    )
                })
            },
            onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelSecurityQuestion in
                activityView.hide(animated: true)
                self.alertManager.promptUserToAnswerSecurityQuestion(
                    securityQuestion,
                    onViewController: self,
                    onAnswerSecurityQuestion: answerSecurityQuestion,
                    onCancelSecurityQuestion: cancelSecurityQuestion
                )
            },
            onFailure: { errorResult in
                activityView.hide(animated: true)
                self.alertManager.showRelinkError(errorResult,
                    withLinkedBroker: linkedBroker,
                    onViewController: self,
                    onFinished: {})
            }
        )
    }

    @IBAction func symbolButtonWasTapped(_ sender: AnyObject) {
        presentSymbolSelectionScreen()
    }

    @IBAction func accountButtonTapped(_ sender: UIButton) {
        presentAccountSelectionScreen()
    }

    // MARK: Private

    private func presentSymbolSelectionScreen() {
        let symbolSearchViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.symbolSearchView) as! TradeItSymbolSearchViewController

        symbolSearchViewController.delegate = self

        self.navigationController?.pushViewController(symbolSearchViewController, animated: true)
    }

    private func presentAccountSelectionScreen() {
        let accountSelectionViewController = self.viewControllerProvider.provideViewController(forStoryboardId: TradeItStoryboardID.accountSelectionView) as! TradeItAccountSelectionViewController

        accountSelectionViewController.delegate = self

        self.navigationController?.pushViewController(accountSelectionViewController, animated: true)
    }

    // MARK: TradeItSymbolSearchViewControllerDelegate

    func symbolSearchViewController(_ symbolSearchViewController: TradeItSymbolSearchViewController,
                                    didSelectSymbol selectedSymbol: String) {
        self.order.symbol = selectedSymbol
        updateSymbolView()
        updateTradingBrokerAccountView()
        _ = symbolSearchViewController.navigationController?.popViewController(animated: true)
    }

    // MARK: TradeItAccountSelectionViewControllerDelegate

    func accountSelectionViewController(_ accountSelectionViewController: TradeItAccountSelectionViewController,
                                        didSelectLinkedBrokerAccount linkedBrokerAccount: TradeItLinkedBrokerAccount) {
        self.order.linkedBrokerAccount = linkedBrokerAccount
        updateTradingBrokerAccountView()
        _ = accountSelectionViewController.navigationController?.popViewController(animated: true)
    }

    // MARK: Private - Order changed handlers

    private func orderActionSelected(_ action: UIAlertAction) {
        orderActionSelected(orderAction: action.title)
    }

    private func orderTypeSelected(action: UIAlertAction) {
        orderTypeSelected(orderType: action.title)
    }

    private func orderExpirationSelected(_ action: UIAlertAction) {
        orderExpirationSelected(orderExpiration: action.title)
    }

    private func orderActionSelected(orderAction: String!) {
        order.action = TradeItOrderActionPresenter.enumFor(orderAction)
        orderActionButton.setTitle(TradeItOrderActionPresenter.labelFor(order.action), for: UIControlState())

        if order.action == .buy {
            tradingBrokerAccountView.updatePresentationMode(.buyingPower)
        } else {
            tradingBrokerAccountView.updatePresentationMode(.sharesOwned)
        }
    }

    private func orderTypeSelected(orderType: String!) {
        order.type = TradeItOrderPriceTypePresenter.enumFor(orderType)
        orderTypeButton.setTitle(TradeItOrderPriceTypePresenter.labelFor(order.type), for: UIControlState())

        // Show/hide order expiration
        if order.requiresExpiration() {
            orderExpirationButton.superview?.isHidden = false
        } else {
            orderExpirationButton.superview?.isHidden = true
        }

        // Show/hide limit and/or stop
        var inputs = [orderTypeInput1, orderTypeInput2]

        inputs.forEach { input in
            input?.isHidden = true
            input?.text = nil
        }

        if order.requiresLimitPrice() {
            configureLimitInput(inputs.removeFirst()!)
        }

        if order.requiresStopPrice() {
            configureStopInput(inputs.removeFirst()!)
        }

        updatePreviewOrderButtonStatus()
    }

    private func orderExpirationSelected(orderExpiration: String!) {
        order.expiration = TradeItOrderExpirationPresenter.enumFor(orderExpiration)
        orderExpirationButton.setTitle(TradeItOrderExpirationPresenter.labelFor(order.expiration), for: UIControlState())
    }

    private func updatePreviewOrderButtonStatus() {
        if order.isValid() {
            previewOrderButton.isEnabled = true
            previewOrderButton.backgroundColor = UIColor.tradeItClearBlueColor()
        } else {
            previewOrderButton.isEnabled = false
            previewOrderButton.backgroundColor = UIColor.tradeItGreyishBrownColor()
        }
    }

    private func updateSymbolView() {
        guard let symbol = order.symbol else { return }

        symbolView.updateSymbol(symbol)
        symbolView.updateQuoteActivity(.loading)

        self.marketDataService?.getQuote(symbol, onSuccess: { quote in
            let presenter = TradeItQuotePresenter(quote)
            self.order.quoteLastPrice = presenter.getLastPriceValue()
            self.symbolView.updateQuote(quote)
            self.symbolView.updateQuoteActivity(.loaded)
            self.updateEstimatedChangedLabel()
        }, onFailure: { error in
            self.order.quoteLastPrice = nil
            self.symbolView.updateQuote(nil)
            self.symbolView.updateQuoteActivity(.loaded)
            self.updateEstimatedChangedLabel()
        })

        updateSharesOwnedLabel()
    }

    private func updateTradingBrokerAccountView() {
        guard let linkedBrokerAccount = order.linkedBrokerAccount else { return }

        linkedBrokerAccount.linkedBroker.authenticateIfNeeded(onSuccess: {
            linkedBrokerAccount.getAccountOverview(onSuccess: {
                self.tradingBrokerAccountView.updateBrokerAccount(linkedBrokerAccount)
                self.updateSharesOwnedLabel()
            }, onFailure: { errorResult in
                    print(errorResult)
            })
        }, onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelQuestion in
            self.alertManager.promptUserToAnswerSecurityQuestion(
                securityQuestion,
                onViewController: self,
                onAnswerSecurityQuestion: answerSecurityQuestion,
                onCancelSecurityQuestion: cancelQuestion
            )
        }, onFailure: { errorResult in
            print(errorResult)
        })


    }

    private func updateSharesOwnedLabel() {
        guard let symbol = order.symbol
            , let linkedBrokerAccount = order.linkedBrokerAccount
            else { return }

        linkedBrokerAccount.linkedBroker.authenticateIfNeeded(onSuccess: {
            linkedBrokerAccount.getPositions(onSuccess: { positions in
                let positionsMatchingSymbol = positions.filter { portfolioPosition in
                    TradeItPortfolioPositionPresenterFactory.forTradeItPortfolioPosition(portfolioPosition).getFormattedSymbol() == symbol
                }

                guard let position = positionsMatchingSymbol.first else { return }

                let presenter = TradeItPortfolioPositionPresenterFactory.forTradeItPortfolioPosition(position)
                self.tradingBrokerAccountView.updateSharesOwned(presenter)
            }, onFailure: { errorResult in
                print(errorResult)
            })
        }, onSecurityQuestion: { securityQuestion, answerSecurityQuestion, cancelQuestion in
            self.alertManager.promptUserToAnswerSecurityQuestion(
                securityQuestion,
                onViewController: self,
                onAnswerSecurityQuestion: answerSecurityQuestion,
                onCancelSecurityQuestion: cancelQuestion)
        }, onFailure: { errorResult in
            print(errorResult)
        })
    }

    // MARK: Private - Text view configurators

    private func registerTextFieldNotifications() {
        let orderTypeInputs = [orderSharesInput, orderTypeInput1, orderTypeInput2]

        orderTypeInputs.forEach { input in
            input?.addTarget(
                self,
                action: #selector(self.textFieldDidChange(_:)),
                for: UIControlEvents.editingChanged
            )
        }
    }

    private func configureLimitInput(_ input: UITextField) {
        input.placeholder = "Limit Price"
        input.isHidden = false
    }

    private func configureStopInput(_ input: UITextField) {
        input.placeholder = "Stop Price"
        input.isHidden = false
    }

    private func updateEstimatedChangedLabel() {
        if let estimatedChange = order.estimatedChange() {
            let formattedEstimatedChange = NumberFormatter.formatCurrency(estimatedChange, currencyCode: TradeItPresenter.DEFAULT_CURRENCY_CODE)
            if order.action == .buy {
                estimatedChangeLabel.text = "Est. Cost \(formattedEstimatedChange)"
            } else {
                estimatedChangeLabel.text = "Est. Proceeds \(formattedEstimatedChange)"
            }
        } else {
            estimatedChangeLabel.text = nil
        }
    }

    // MARK: Private - Keyboard event handlers

    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        let info = (notification as NSNotification).userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height + TradeItTradingTicketViewController.BOTTOM_CONSTRAINT_CONSTANT
        })
    }

    @objc private func keyboardWillHide(_: Notification) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.bottomConstraint.constant = TradeItTradingTicketViewController.BOTTOM_CONSTRAINT_CONSTANT
        })
    }

    // MARK: Private - Action sheet helper

    private func presentOptions(title: String, options: [String], sender: UIButton, handler: @escaping (UIAlertAction) -> Void) {
        let actionSheet: UIAlertController = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .actionSheet
        )

        actionSheet.popoverPresentationController?.sourceView = sender

        options.map { option in UIAlertAction(title: option, style: .default, handler: handler) }
            .forEach(actionSheet.addAction)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
    }
}

protocol TradeItTradingTicketViewControllerDelegate: class {
    func orderSuccessfullyPreviewed(onTradingTicketViewController tradingTicketViewController: TradeItTradingTicketViewController,
                                           withPreviewOrderResult previewOrderResult: TradeItPreviewOrderResult,
                                                                  placeOrderCallback: @escaping TradeItPlaceOrderHandlers)
}
