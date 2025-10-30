//
//  WebExtension.swift
//  Email Alias
//
//  Created by Sven on 18.06.25.
//

import Foundation
import SwiftData
#if os(iOS)
import UIKit
#endif

private let jsonEncoder = JSONEncoder()

func getAliases() async -> [String: Any]? {
    var emailFetchDescriptor = FetchDescriptor<Email>()
    emailFetchDescriptor.predicate = #Predicate { $0.active }
    emailFetchDescriptor.sortBy = [SortDescriptor(\.privateComment)]
    let json = await MainActor.run {
        var json: String? = nil
        
        if let emails = try? DataContainer.shared.container.mainContext.fetch(emailFetchDescriptor) {
            if let jsonData = try? jsonEncoder.encode(emails) {
                json = String(data: jsonData, encoding: .utf8)
            }
        }
        
        return json
    }
    guard let json else {
        return nil
    }
    
    #if os(iOS)
    let isPhone = await UIDevice.current.userInterfaceIdiom == .phone
    #else
    let isPhone = false
    #endif
    
    let (colorScheme, registered) = await MainActor.run {
        (UserDefaults.shared.integer(forKey: .colorScheme), UserDefaults.shared.bool(forKey: .registered))
    }
    
    return [
        "messages": [
            "copiedToClipboard": "copiedToClipboard".localized,
            "ok": "ok".localized,
            "register": "register".localized,
            "highlightedEmails": "highlightedEmails".localized,
            "remainingEmails": "remainingEmails".localized,
            "unregisteredTitle": "unregisteredTitle".localized,
            "registeredTitle": "registeredTitle".localized,
            "licenses": "licenses".localized,
        ],
        "colorScheme": colorScheme,
        "isPhone": isPhone,
        "registered": registered,
        "emails": json,
    ]
}
