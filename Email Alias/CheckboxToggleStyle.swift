//
//  CheckboxToggleStyle.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 10.03.24.
//

import SwiftUI

#if !os(macOS)
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
            configuration.label
        }
    }
}
#endif
