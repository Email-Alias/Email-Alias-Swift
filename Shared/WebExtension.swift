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

func getAliases() -> [String: Any]? {
    var emailFetchDescriptor = FetchDescriptor<Email>()
    emailFetchDescriptor.predicate = #Predicate { $0.active }
    emailFetchDescriptor.sortBy = [SortDescriptor(\.privateComment)]
    guard let emails = try? DataContainer.shared.container.mainContext.fetch(emailFetchDescriptor) else {
        return nil
    }
    
    guard let jsonData = try? jsonEncoder.encode(emails) else {
        return nil
    }
    
    guard let json = String(data: jsonData, encoding: .utf8) else {
        return nil
    }
    
    #if os(iOS)
    let isPhone = UIDevice.current.userInterfaceIdiom == .phone
    #else
    let isPhone = false
    #endif
    
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
        "colorScheme": UserDefaults.shared.integer(forKey: .colorScheme),
        "isPhone": isPhone,
        "registered": UserDefaults.shared.bool(forKey: .registered),
        "emails": json,
    ]
}
