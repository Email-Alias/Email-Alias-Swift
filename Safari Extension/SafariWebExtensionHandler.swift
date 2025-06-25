//Add commentMore actions
//  SafariWebExtensionHandler.swift
//  Web Extension
//
//  Created by Sven Op de Hipt on 15.02.24.
//

import SafariServices
import SwiftData

class SafariWebExtensionHandler: NSObject, @MainActor NSExtensionRequestHandling {
    @MainActor
    func beginRequest(with context: NSExtensionContext) {
        let request = context.inputItems.first as? NSExtensionItem

        switch request?.userInfo?[SFExtensionMessageKey] as? String {
        case "getAliases":
            guard let aliases = getAliases() else {
                context.completeRequest(returningItems: nil)
                return
            }
            
            let response = NSExtensionItem()
            response.userInfo = [ SFExtensionMessageKey: aliases ]

            context.completeRequest(returningItems: [response])
        default:
            context.completeRequest(returningItems: nil)
        }
    }
}
