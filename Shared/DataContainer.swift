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
        #if os(macOS)
        let url = URL.storeURL(for: "BHUJ88RV68.com.opdehipt.Email-Alias", databaseName: "DataModel")
        #else
        let url = URL.storeURL(for: "group.com.opdehipt.Email-Alias", databaseName: "DataModel")
        #endif
        self.container = try! ModelContainer(
            for: Email.self,
            migrationPlan: EmailsMigrationPlan.self,
            configurations: ModelConfiguration(url: url)
        )
    }
}

private extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
