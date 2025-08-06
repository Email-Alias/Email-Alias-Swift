//
//  SharedWatchUserDefaultKeys.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 23.02.24.
//

extension String {
    nonisolated static let domain = "domain"
    nonisolated static let email = "email"
    nonisolated static let apiKey = "apiKey"
    nonisolated static let nextID = "nextID"
    nonisolated static let registered = "registered"
    #if os(macOS)
    nonisolated static let language = "language"
    #endif
    nonisolated static let colorScheme = "colorScheme"
}
