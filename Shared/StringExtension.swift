//
//  StringExtension.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 12.06.24.
//

import Foundation

extension String {
    @MainActor
    var localized: String {
        #if os(macOS)
        if let language = Language(rawValue: UserDefaults.shared.integer(forKey: .language)) {
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
