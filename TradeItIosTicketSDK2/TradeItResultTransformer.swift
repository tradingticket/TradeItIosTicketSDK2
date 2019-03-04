class TradeItResultTransformer {
    static let jsonDecoder = JSONDecoder()
    static func transform<T: Codable>(targetClassType: T.Type, json: String?) -> T? {
        do {
            guard let data = json?.data(using: .utf8) else {
                return nil
            }
            let result = try jsonDecoder.decode(targetClassType, from: data)
            return result
        } catch {
            print("TradeItResultTransformer")
            print("- Expected class: \(T.self)")
            print("- Server response: \(json ?? "")")
            print("- Json error: \(error)")
            return nil
        }
    }
}
