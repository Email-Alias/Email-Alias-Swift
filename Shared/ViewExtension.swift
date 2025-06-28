//
//  ViewExtension.swift
//  Web Extension
//
//  Created by Sven Op de Hipt on 27.02.24.
//

import SwiftUI

#if os(macOS)
extension View {
    func language(_ language: Language) -> some View {
        Group {
            if let locale = language.locale {
                self.environment(\.locale, locale)
            }
            else {
                self
            }
        }
    }
}
#endif
