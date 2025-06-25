//
//  SwiftData.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 15.02.24.
//

import Foundation
import SwiftData

@MainActor
final class DataContainer {
    static let shared = DataContainer()
    let container: ModelContainer

    private init() {
        self.container = try! ModelContainer(
            for: Email.self,
            migrationPlan: EmailsMigrationPlan.self,
            configurations: ModelConfiguration(for: Email.self)
        )
    }
}
