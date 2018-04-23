class TradeItBrokerHeaderTableViewCell: BrandedTableViewCell {
    func populate(linkedBroker: TradeItLinkedBroker?) {
        setBrokerNameAsTextState(altTitleText: linkedBroker?.brokerLongName ?? "Unknown broker")
        TradeItSDK.brokerLogoService.loadLogo(
            forBrokerId: linkedBroker?.brokerName,
            withSize: .small,
            onSuccess: { image in
                self.setBrokerNameAsLogoState(logo: image)
            }, onFailure: { }
        )
    }
}
