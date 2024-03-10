//
//  SwiftData.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 15.02.24.
//

import Foundation
import SwiftData

let container = try! ModelContainer(
    for: Email.self,
    migrationPlan: EmailsMigrationPlan.self,
    configurations: ModelConfiguration(url: URL.storeURL(for: "group.com.opdehipt.Email-Alias", databaseName: "DataModel"))
)

private extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
