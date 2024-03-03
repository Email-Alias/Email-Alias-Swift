//
//  Toast.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 03.03.24.
//

import SwiftUI

struct Toast: ViewModifier {
    let message: LocalizedStringKey

    @Binding var isShowing: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
            toastView
        }
    }

    private var toastView: some View {
        VStack {
            Spacer()

            if isShowing {
                Group {
                    Text(message)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 30)
                }
                .background(Capsule().foregroundColor(.backgroundColor.opacity(0.85)))
                .onTapGesture {
                    isShowing = false
                }
                .task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    isShowing = false
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
        .animation(.linear(duration: 0.3), value: isShowing)
        .transition(.opacity)
    }
}

extension View {
    func toast(
        message: LocalizedStringKey,
        isShowing: Binding<Bool>
    ) -> some View {
        self.modifier(
            Toast(
                message: message,
                isShowing: isShowing
            )
        )
    }
}
