extension URLComponents {
    public func queryStringValue(forKey key: String) -> String? {
        if let queryItems = self.queryItems,
            let value = queryItems.filter({ $0.name == key }).first?.value {
            return value
        } else {
            return nil
        }
    }

    public mutating func addOrUpdateQueryStringValue(forKey key: String, value: String?) {
        var queryItems = self.queryItems ?? [URLQueryItem]()

        for (index, queryItem) in queryItems.enumerated() {
            if queryItem.name == key {
                if let value = value {
                    queryItems[index] = URLQueryItem(name: key, value: value)
                } else {
                    queryItems.remove(at: index)
                }

                self.queryItems = queryItems.count > 0 ? queryItems : nil

                return
            }
        }

        // Key doesn't exist if reaches here
        if let value = value {
            queryItems.append(URLQueryItem(name: key, value: value))
            self.queryItems = queryItems
        }
    }
}
