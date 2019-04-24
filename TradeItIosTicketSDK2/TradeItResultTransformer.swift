class TradeItResultTransformer {
    static func transform<T: JSONModel>(targetClassType: T.Type, json: String?) -> T? {
        var error: JSONModelError? = nil
        let result = T.init(string: json, error: &error)

        if let error = error {
            print("TradeItResultTransformer")
            print("- Expected class: \(T.self)")
            print("- Server response: \(json ?? "")")
            print("- JSONModel response: \(error)")
            return nil
        } else if let result = result {
            return result
        } else {
            print("TradeItResultTransformer")
            print("- Expected class: \(T.self)")
            print("- Server response: \(json ?? "")")
            return nil
        }
    }
}
