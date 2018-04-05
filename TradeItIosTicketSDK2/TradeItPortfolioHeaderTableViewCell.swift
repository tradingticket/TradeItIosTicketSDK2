class TradeItPortfolioHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var title: UILabel!

    func populate(linkedBroker: TradeItLinkedBroker?) {
        self.title.text = linkedBroker?.brokerLongName
        self.setFailureState()
        TradeItSDK.brokerLogoService.loadLogo(
            forBrokerId: linkedBroker?.brokerName,
            withSize: .small,
            onSuccess: { image in
                self.logo.image = image
                self.setSuccessfulState()
            }, onFailure: {
                self.setFailureState()
            }
        )
    }

    func setSuccessfulState() {
        self.logo.isHidden = false
        self.title.isHidden = true
    }

    func setFailureState() {
        self.logo.isHidden = true
        self.title.isHidden = false
    }
}
