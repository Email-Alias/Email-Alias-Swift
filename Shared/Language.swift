//
//  Language.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 25.02.24.
//

import SwiftUI

enum Language: Int, CaseIterable {
    case system = 0
    case english
    case german
    
    var locale: Locale? {
        switch self {
        case .system:
            nil
        case .english:
            Locale(languageCode: .english)
        case .german:
            Locale(languageCode: .german)
        }
    }
}
