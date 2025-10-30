//Add commentMore actions
//  SafariWebExtensionHandler.swift
//  Web Extension
//
//  Created by Sven Op de Hipt on 15.02.24.
//

import SafariServices
import SwiftData

final class ContextBox: @unchecked Sendable {
    private let context: NSExtensionContext
    init(_ context: NSExtensionContext) {
        self.context = context
    }

    func complete(_ payload: [String: Any]?) {
        if let payload {
            let item = NSExtensionItem()
            item.userInfo = [ SFExtensionMessageKey: payload ]
            context.completeRequest(returningItems: [item])
        }
        else {
            context.completeRequest(returningItems: nil)
        }
    }
}

class SafariWebExtensionHandler: NSObject, @MainActor NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        let request = context.inputItems.first as? NSExtensionItem

        switch request?.userInfo?[SFExtensionMessageKey] as? String {
        case "getAliases":
            let responder = ContextBox(context)
            Task {
                guard let aliases = await getAliases() else {
                    responder.complete([:])
                    return
                }

                responder.complete(aliases)
            }
        default:
            context.completeRequest(returningItems: nil)
        }
    }
}
