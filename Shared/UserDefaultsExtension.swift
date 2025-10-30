//
//  UserDefaultsExtension.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 15.02.24.
//

import Foundation

extension UserDefaults {
    #if os(macOS)
    @MainActor
    static let shared = UserDefaults(suiteName: "BHUJ88RV68.com.opdehipt.Email-Alias")!
    #else
    @MainActor
    static let shared = UserDefaults(suiteName: "group.com.opdehipt.Email-Alias")!
    #endif
}
