//
//  SafariWebExtensionHandler.swift
//  Web Extension
//
//  Created by Sven Op de Hipt on 15.02.24.
//

import SafariServices
import SwiftData

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    static let jsonEncoder = JSONEncoder()

    @MainActor
    func beginRequest(with context: NSExtensionContext) {
        let request = context.inputItems.first as? NSExtensionItem

        switch request?.userInfo?[SFExtensionMessageKey] as? String {
        case "getAliases":
            var emailFetchDescriptor = FetchDescriptor<Email>()
            emailFetchDescriptor.predicate = #Predicate { $0.active }
            emailFetchDescriptor.sortBy = [SortDescriptor(\.privateComment)]
            guard let emails = try? container.mainContext.fetch(emailFetchDescriptor) else {
                context.completeRequest(returningItems: nil)
                return
            }
            
            guard let jsonData = try? SafariWebExtensionHandler.jsonEncoder.encode(emails) else {
                context.completeRequest(returningItems: nil)
                return
            }
            
            guard let json = String(data: jsonData, encoding: .utf8) else {
                context.completeRequest(returningItems: nil)
                return
            }
            
            #if os(iOS)
            let isPhone = UIDevice.current.userInterfaceIdiom == .phone
            #else
            let isPhone = false
            #endif
            
            let response = NSExtensionItem()
            response.userInfo = [ SFExtensionMessageKey: [
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
            ] ]

            context.completeRequest(returningItems: [response])
        default:
            context.completeRequest(returningItems: nil)
        }
    }

    
}
