class TradeItBrokerHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!

    func populate(linkedBroker: TradeItLinkedBroker?) {
        setBrokerNameAsTextState(brokerName: linkedBroker?.brokerLongName ?? "Unknown broker")
        TradeItSDK.brokerLogoService.loadLogo(
            forBrokerId: linkedBroker?.brokerName,
            withSize: .small,
            onSuccess: { image in
                self.setBrokerNameAsLogoState(logo: image)
            }, onFailure: { }
        )
    }

    private func setBrokerNameAsTextState(brokerName: String) {
        textLabel?.text = brokerName

        self.logo.isHidden = true
        textLabel?.isHidden = false
    }

    private func setBrokerNameAsLogoState(logo: UIImage) {
        let imageWidth = Double(logo.cgImage?.width ?? 1)
        let imageHeight = Double(logo.cgImage?.height ?? 1)
        self.logoWidthConstraint.constant = CGFloat(Double(14) * imageWidth / imageHeight)
        self.logo.image = logo

        self.logo.isHidden = false
        textLabel?.isHidden = true
    }
}
