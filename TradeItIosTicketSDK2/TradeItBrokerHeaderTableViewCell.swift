class TradeItBrokerHeaderTableViewCell: BrandedTableViewCell {
    func populate(linkedBroker: TradeItLinkedBroker?) {
        setBrokerNameAsTextState(brokerName: linkedBroker?.brokerLongName)
        TradeItSDK.brokerLogoService.loadLogo(
            forBrokerId: linkedBroker?.brokerName,
            withSize: .small,
            onSuccess: { image in
                self.setBrokerNameAsLogoState(logo: image)
            }, onFailure: { }
        )
    }
}
