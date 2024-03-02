//
//  StringExtension.swift
//  Web Extension
//
//  Created by Sven Op de Hipt on 16.02.24.
//

import Foundation

extension String {
    var localized: String {
        if let language = Language(rawValue: UserDefaults.shared.integer(forKey: .language)) {
            if let locale = language.locale?.language.languageCode?.identifier {
                if let path = Bundle.main.path(forResource: locale, ofType: "lproj") {
                    if let bundle = Bundle(path: path) {
                        return NSLocalizedString(self, bundle: bundle, comment: "")
                    }
                }
            }
        }
        return NSLocalizedString(self, comment: "")
    }
}
