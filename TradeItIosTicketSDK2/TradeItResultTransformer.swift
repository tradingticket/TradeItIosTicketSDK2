class TradeItResultTransformer {
    static let JSON_ERROR = TradeItParseErrorResult.error(withSystemMessage: "Error parsing JSON response")

    static func transform<T: TradeItResult>(targetClassType: T.Type, json: String?) -> T? {
        var error: JSONModelError? = nil
        let result = T.init(string: json, error: &error)

        if let error = error {
            print("TradeItResultTransformer Error")
            print("Expected class: \(T.self)")
            print("JSONModel error: \(error)")
            print("Server response: \(String(describing: json))")
            return nil
        } else if let result = result {
            return result
        } else {
            print("TradeItResultTransformer Error")
            print("Expected class: \(T.self)")
            print("Server response: \(String(describing: json))")
            return nil
        }
    }
}
