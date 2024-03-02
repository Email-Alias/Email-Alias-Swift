//
//  ViewExtension.swift
//  Web Extension
//
//  Created by Sven Op de Hipt on 27.02.24.
//

import SwiftUI

extension View {
    func language(_ language: Int) -> some View {
        Group {
            if let locale = Language(rawValue: language)?.locale {
                self.environment(\.locale, locale)
            }
            else {
                self
            }
        }
    }
}
