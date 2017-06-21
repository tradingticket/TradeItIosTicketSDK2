@objc public class TradeItFxTradeService: NSObject {
    let session: TradeItSession

    init(session: TradeItSession) {
        self.session = session
    }

    func place(
        order: TradeItFxPlaceOrderRequest,
        onSuccess: @escaping (TradeItFxPlaceOrderResult) -> Void,
        onFailure: @escaping (TradeItErrorResult) -> Void
    ) -> Void {
        order.token = self.session.token!

        let request = TradeItRequestResultFactory.buildJsonRequest(
            for: order,
            emsAction: "order/placeFxOrder",
            environment: self.session.connector.environment
        )

        self.session.connector.sendEMSRequest(request, withCompletionBlock: { (result, jsonResponse) in
            guard let jsonResponse = jsonResponse as String? else {
                print("ERROR - call onFailure")
                return
            }
            print(result)
            print(jsonResponse)

            if (result?.status == "SUCCESS" ) {
                let placeFxOrderResult = TradeItFxPlaceOrderResult()
                TradeItRequestResultFactory.build(placeFxOrderResult, jsonString: jsonResponse)
                print(placeFxOrderResult)
//                onSuccess()
            }
        })
    }
}

//class TradeItFxOrderInfoInput: JSONModel {
//    let orderType: String
//    let orderExpiration: String
//    let orderLegs: [TradeItFxOrderLeg]
//
//    init(orderType: String, orderExpiration: String, orderLegs: [TradeItFxOrderLeg]) {
//        self.orderType = orderType
//        self.orderExpiration = orderExpiration
//        self.orderLegs = orderLegs
//        super.init()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    required init(data: Data!) throws {
//        fatalError("init(data:) has not been implemented")
//    }
//
//    required init(dictionary dict: [AnyHashable : Any]!) throws {
//        fatalError("init(dictionary:) has not been implemented")
//    }
//}

//class TradeItFxOrderLeg: JSONModel {
//    let priceType: String
//    let pair: String
//    let action: String
//    let amount: NSNumber
//
//    init(priceType: String, pair: String, action: String, amount: NSNumber) {
//        self.priceType = priceType
//        self.pair = pair
//        self.action = action
//        self.amount = amount
//        super.init()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    required init(data: Data!) throws {
//        fatalError("init(data:) has not been implemented")
//    }
//
//    required init(dictionary dict: [AnyHashable : Any]!) throws {
//        fatalError("init(dictionary:) has not been implemented")
//    }
//}

@objc public class TradeItFxPlaceOrderResult: TradeItResult {

}


//{
//"token":"756ed4564c9446338851d74a5a287177",
//"accountNumber":"0",
//"fxOrderInfoInput": {
//  "orderType": "SINGLE",
//  "orderExpiration": "DAY",
//  "orderLegs": [
//  {
//    "priceType": "MARKET",
//    "pair": "USD/CHF",
//    "action": "BUY",
//    "amount": 1000
//  }
//  ]
//}
//}
