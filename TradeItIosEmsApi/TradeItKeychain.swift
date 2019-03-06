class TradeItKeychain: NSObject {

    static func save(_ inputString: String?, forKey account: String?) {
        assert(account != nil, "Invalid account")
        assert(inputString != nil, "Invalid string")
        
        var query: [AnyHashable : Any] = [:]
        
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrAccount] = account as NSString?
        query[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
        
        var error: OSStatus = SecItemCopyMatching(query as CFDictionary, nil)
        if error == errSecSuccess {
            // do update
            var attributesToUpdate: [AnyHashable : Any] = [:]
            if let data = (inputString as NSString?)?.data(using: String.Encoding.utf8.rawValue) {
                attributesToUpdate = [kSecValueData : data]
            }
            
            error = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            assert(error == errSecSuccess, String(format: "SecItemUpdate failed: %i", Int(error)))
        } else if error == errSecItemNotFound {
            // do add
            query[kSecValueData] = (inputString as NSString?)?.data(using: String.Encoding.utf8.rawValue)
            
            error = SecItemAdd(query as CFDictionary, nil)
            assert(error == errSecSuccess, String(format: "SecItemAdd failed: %i", Int(error)))
        } else {
            assert(false, String(format: "SecItemCopyMatching failed: %i", Int(error)))
        }
    }
    
    static func getStringForKey(_ account: String?) -> String? {
        assert(account != nil, "Invalid account")
        
        var query: [AnyHashable : Any] = [:]
        
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrAccount] = account as NSString?
        query[kSecReturnData] = kCFBooleanTrue
        
        var dataFromKeychain: CFTypeRef? = nil
        let error: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataFromKeychain)
        
        var stringToReturn: NSString? = nil
        if error == errSecSuccess {
            if let dataFromKeychain = dataFromKeychain as? NSData {
                stringToReturn = NSString(data: dataFromKeychain as Data, encoding: String.Encoding.utf8.rawValue)
            }
        }
        
        return stringToReturn as String?
    }
    
    static func deleteString(forKey account: String?) {
        assert(account != nil, "Invalid account")
        
        var query: [AnyHashable : Any] = [:]
        
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrAccount] = (account as NSString?)
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            print(String(format: "SecItemDelete failed: %i", Int(status)))
        }
    }
}
