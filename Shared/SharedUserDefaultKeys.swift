//
//  SharedWatchUserDefaultKeys.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 23.02.24.
//

extension String {
    static let domain = "domain"
    static let email = "email"
    static let apiKey = "apiKey"
    static let nextID = "nextID"
    static let registered = "registered"
    #if os(macOS)
    static let language = "language"
    #endif
    static let colorScheme = "colorScheme"
}
