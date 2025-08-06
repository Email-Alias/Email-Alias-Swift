//
//  KeychainService.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import Foundation

nonisolated func save(valueToKeychain value: String, withKey key: String) -> OSStatus {
    guard let data = value.data(using: .utf8) else {
        return errSecParam
    }
    
    let query = [
        kSecClass as String       : kSecClassGenericPassword,
        kSecAttrAccount as String : key,
        kSecValueData as String   : data
    ] as [String : Any]

    SecItemDelete(query as CFDictionary)

    return SecItemAdd(query as CFDictionary, nil)
}

nonisolated func loadFromKeychain(withKey key: String) -> String? {
    let query = [
        kSecClass as String       : kSecClassGenericPassword,
        kSecAttrAccount as String : key,
        kSecReturnData as String  : kCFBooleanTrue!,
        kSecMatchLimit as String  : kSecMatchLimitOne
    ] as [String : Any]

    var dataTypeRef: AnyObject? = nil

    let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

    if status == noErr, let data = dataTypeRef as? Data {
        return String(data: data, encoding: .utf8)
    } else {
        return nil
    }
}

nonisolated func removeFromKeychain(withKey key: String) -> OSStatus {
    let query = [
        kSecClass as String       : kSecClassGenericPassword,
        kSecAttrAccount as String : key
    ] as [String : Any]
    
    return SecItemDelete(query as CFDictionary)
}
