//
//  StringExtension.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 12.06.24.
//

import Foundation

extension String {
    func localized() async -> String {
        #if os(macOS)
        let languageRaw = await MainActor.run {
            UserDefaults.shared.integer(forKey: .language)
        }
        if let language = Language(rawValue: languageRaw) {
            if let locale = language.locale?.language.languageCode?.identifier {
                if let path = Bundle.main.path(forResource: locale, ofType: "lproj") {
                    if let bundle = Bundle(path: path) {
                        return NSLocalizedString(self, tableName: localizationTableName, bundle: bundle, comment: "")
                    }
                }
            }
        }
        #endif
        return NSLocalizedString(self, tableName: localizationTableName, comment: "")
    }
}
